/* 
 *  Copyright 2023 BI X GmbH
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

using System;
using System.Collections;
using System.Collections.Generic;
using Manager;
using Recognissimo;
using Recognissimo.Components;
using TMPro;
using UnityEngine;

namespace SpeechRecognition
{
    public class VoskRecognizer : MonoBehaviour
    {
        [SerializeField]
        private SpeechRecognizer recognizer;

        [SerializeField]
        private StreamingAssetsLanguageModelProvider languageModelProvider;

        [SerializeField]
        private SystemLanguage _language;

        private AppManager _appManager;
        private bool _speechProcessing;

        [Header("Subtitles")]
        [SerializeField]
        private TMP_Text _subtitlesLeft;

        [SerializeField]
        private TMP_Text _subtitlesRight;

        private bool _speechRecognitionActive;

        private readonly List<AppManager.CurrentTest> _testsWithSubtitles =
            new()
            {
                AppManager.CurrentTest.Contrast,
                AppManager.CurrentTest.Distortion,
                AppManager.CurrentTest.Ipda,
                AppManager.CurrentTest.Settings,
            };

        private readonly Dictionary<AppManager.CurrentTest, List<string>> _vocabularyPerTestEn =
            new()
            {
                {
                    AppManager.CurrentTest.Contrast,
                    new()
                    {
                        "[unk]",
                        "zero",
                        "one",
                        "two",
                        "three",
                        "four",
                        "five",
                        "six",
                        "seven",
                        "eight",
                        "none",
                        "start",
                    }
                },
                {
                    AppManager.CurrentTest.Ipda,
                    new() { "[unk]", "one", "first", "two", "second", "three", "third", "start", }
                },
            };

        private readonly Dictionary<AppManager.CurrentTest, List<string>> _vocabularyPerTestDe =
            new()
            {
                {
                    AppManager.CurrentTest.Contrast,
                    new()
                    {
                        "[unk]",
                        "null",
                        "eins",
                        "einen",
                        "zwei",
                        "drei",
                        "vier",
                        "fünf",
                        "sechs",
                        "sieben",
                        "acht",
                        "keine",
                        "keinen",
                        "start",
                    }
                },
                {
                    AppManager.CurrentTest.Ipda,
                    new() { "[unk]", "eins", "erste", "zwei", "zweite", "drei", "dritte", "start", }
                },
            };

        private readonly Dictionary<string, List<string>> _mispronunciationsDe =
            new()
            {
                {
                    "start",
                    new() { "start", "staat", "stadt", "statt", }
                },
                {
                    "yes",
                    new() { "ja", "er", "der", "herr", "wir", }
                },
                {
                    "no",
                    new() { "nein", "neun", "beim", "mein", }
                },
            };

        private readonly Dictionary<string, List<string>> _mispronunciationsEn =
            new()
            {
                {
                    "start",
                    new() { "start", "thought", "that", "stark", "thirty", }
                },
                {
                    "yes",
                    new() { "yes", "yeah", }
                },
                {
                    "no",
                    new() { "no", "not", }
                },
            };

        private readonly List<List<string>> _readingSpeedPronunciationsDe =
            new()
            {
                {
                    new List<string>() { "rathaus", "rat haus", "rasmus", }
                },
                {
                    new List<string>()
                    {
                        "rechnung",
                        "rechnungen",
                        "rechnen",
                        "rechner",
                        "richtung",
                    }
                },
                {
                    new List<string>() { "tomate", "tomaten", "formate", }
                },
            };

        private readonly List<List<string>> _readingSpeedPronunciationsEn =
            new()
            {
                {
                    new List<string>() { "microphone", "microphones", }
                },
                {
                    new List<string>() { "apple", "apples", "epo", "epl", "upper", }
                },
                {
                    new List<string>()
                    {
                        "train",
                        "trained",
                        "trains",
                        "trying",
                        "drain",
                        "drained",
                    }
                },
            };

        private void Awake()
        {
            _appManager = AppManager.Instance;

            if (_appManager.activeLanguage == "de")
            {
                _language = SystemLanguage.German;
                if (!_vocabularyPerTestDe.ContainsKey(_appManager.CurrentActiveTest))
                {
                    recognizer.PartialResultReady.AddListener(OnPartialResult);
                }
                else
                {
                    recognizer.EnableDetails = true;
                    recognizer.ResultReady.AddListener(OnResult);
                    recognizer.Vocabulary = _vocabularyPerTestDe[_appManager.CurrentActiveTest];
                }
            }
            else if (_appManager.activeLanguage == "en")
            {
                _language = SystemLanguage.English;
                if (!_vocabularyPerTestEn.ContainsKey(_appManager.CurrentActiveTest))
                {
                    recognizer.PartialResultReady.AddListener(OnPartialResult);
                }
                else
                {
                    recognizer.EnableDetails = true;
                    recognizer.ResultReady.AddListener(OnResult);
                    recognizer.Vocabulary = _vocabularyPerTestEn[_appManager.CurrentActiveTest];
                }
            }
        }

        private void Start()
        {
            StartCoroutine(StartSpeechRecognitionWithDelay());
        }

        private void OnEnable()
        {
            // Make sure language models exists
            if (languageModelProvider.languageModels.Count == 0)
            {
                throw new InvalidOperationException("No language models.");
            }

            // Set default language
            languageModelProvider.language = _language;

            // Bind recognizer to event handlers
            recognizer.Started.AddListener(() =>
            {
                Debug.Log("recognizer started");
                recognizer.LanguageModelProvider.Model.Dispose();
            });

            recognizer.Finished.AddListener(() => Debug.Log("recognizer finished"));

            recognizer.InitializationFailed.AddListener(OnError);
            recognizer.RuntimeFailed.AddListener(OnError);

            AppSignals.SpeechRecognitionStop.AddListener(StopRecognizer);
            AppSignals.SpeechRecognitionActive.AddListener(SpeechRecognitionActiveState);
        }

        private void OnDisable()
        {
            AppSignals.SpeechRecognitionStop.RemoveListener(StopRecognizer);
            AppSignals.SpeechRecognitionActive.RemoveListener(SpeechRecognitionActiveState);
        }

        IEnumerator StartSpeechRecognitionWithDelay()
        {
            yield return new WaitForSeconds(1.0f);
            StartRecognizer();
        }

        private void SpeechRecognitionActiveState(bool state, bool hasDelay)
        {
            _speechRecognitionActive = state;
            float delay = hasDelay ? .25f : 0;
            StartCoroutine(ToggleMicrophone(delay, state));
        }

        private IEnumerator ToggleMicrophone(float delay, bool state)
        {
            yield return new WaitForSeconds(delay);
            (recognizer.SpeechSource as MicrophoneSpeechSource).IsPaused = !state;
        }

        private void StartRecognizer()
        {
            Debug.Log("StartRecognizer");
            if (_testsWithSubtitles.Contains(_appManager.CurrentActiveTest))
            {
                if (_appManager.debug)
                {
                    Debug.Log("Debug Mode enabled");
                    _subtitlesLeft.gameObject.SetActive(true);
                    _subtitlesRight.gameObject.SetActive(true);
                }
                else
                {
                    _subtitlesLeft.gameObject.SetActive(false);
                    _subtitlesRight.gameObject.SetActive(false);
                }
            }
            _speechProcessing = false;
            recognizer.StartProcessing();
            AppSignals.SpeechRecognitionStarted.Dispatch();
        }

        private void StopRecognizer()
        {
            Debug.Log("StopRecognizer");
            recognizer.StopProcessing();
        }

        private void RecognizeText(string text)
        {
            if (!_speechRecognitionActive)
                return;
            if (_testsWithSubtitles.Contains(_appManager.CurrentActiveTest) && _appManager.debug)
            {
                SetSubtitles(text);
            }
            switch (_appManager.CurrentActiveTest)
            {
                case AppManager.CurrentTest.Ipda:
                    ProcessRecognizedIpda(text);
                    break;
                case AppManager.CurrentTest.Distortion:
                    ProcessRecognizedDistortionTest(text);
                    break;
                case AppManager.CurrentTest.Contrast:
                    ProcessRecognizedContrastTest(text);
                    break;
                case AppManager.CurrentTest.ReadingSpeed:
                    ProcessRecognizedReadingSpeedTest(text);
                    break;
            }
        }

        private void OnPartialResult(PartialResult partial)
        {
            RecognizeText(partial.partial);
        }

        private void OnResult(Result result)
        {
            RecognizeText(result.text);
        }

        private void SetSubtitles(string text)
        {
            _subtitlesLeft.text = text;
            _subtitlesRight.text = text;
        }

        private void OnError(SpeechProcessorException exception)
        {
            Debug.Log(exception.Message);
        }

        #region Reco handling test specific

        /// <summary>
        /// Process Recognized Ipda
        /// </summary>
        private void ProcessRecognizedIpda(string text)
        {
            if (_speechProcessing)
                return;

            switch (_appManager.activeLanguage)
            {
                case "de":
                    if (text.Contains("start"))
                    {
                        DetectStart();
                    }
                    else if (text.Contains("eins") || text.Contains("erste"))
                    {
                        DetectNumber(1);
                    }
                    else if (text.Contains("zwei") || text.Contains("zweite"))
                    {
                        DetectNumber(2);
                    }
                    else if (text.Contains("drei") || text.Contains("dritte"))
                    {
                        DetectNumber(3);
                    }
                    break;
                case "en":
                    if (text.Contains("start"))
                    {
                        DetectStart();
                    }
                    else if (text.Contains("one") || text.Contains("first"))
                    {
                        DetectNumber(1);
                    }
                    else if (text.Contains("two") || text.Contains("second"))
                    {
                        DetectNumber(2);
                    }
                    else if (text.Contains("three") || text.Contains("third"))
                    {
                        DetectNumber(3);
                    }
                    break;
            }
        }

        /// <summary>
        /// Process Recognized Contrast Test
        /// </summary>
        private void ProcessRecognizedContrastTest(string text)
        {
            if (_speechProcessing)
                return;

            switch (_appManager.activeLanguage)
            {
                case "de":
                    if (text.Contains("start"))
                    {
                        DetectStart();
                    }
                    else if (
                        text.Contains("keine") || text.Contains("keinen") || text.Contains("null")
                    )
                    {
                        DetectNumber(0);
                    }
                    else if (text.Contains("eins") || text.Contains("einen"))
                    {
                        DetectNumber(1);
                    }
                    else if (text.Contains("zwei"))
                    {
                        DetectNumber(2);
                    }
                    else if (text.Contains("drei"))
                    {
                        DetectNumber(3);
                    }
                    else if (text.Contains("vier"))
                    {
                        DetectNumber(4);
                    }
                    else if (text.Contains("fünf"))
                    {
                        DetectNumber(5);
                    }
                    else if (text.Contains("sechs"))
                    {
                        DetectNumber(6);
                    }
                    else if (text.Contains("sieben"))
                    {
                        DetectNumber(7);
                    }
                    else if (text.Contains("acht"))
                    {
                        DetectNumber(8);
                    }
                    break;
                case "en":
                    if (text.Contains("start"))
                    {
                        DetectStart();
                    }
                    else if (text.Contains("none") || text.Contains("zero"))
                    {
                        DetectNumber(0);
                    }
                    else if (text.Contains("one"))
                    {
                        DetectNumber(1);
                    }
                    else if (text.Contains("two"))
                    {
                        DetectNumber(2);
                    }
                    else if (text.Contains("three"))
                    {
                        DetectNumber(3);
                    }
                    else if (text.Contains("four"))
                    {
                        DetectNumber(4);
                    }
                    else if (text.Contains("five"))
                    {
                        DetectNumber(5);
                    }
                    else if (text.Contains("six"))
                    {
                        DetectNumber(6);
                    }
                    else if (text.Contains("seven"))
                    {
                        DetectNumber(7);
                    }
                    else if (text.Contains("eight"))
                    {
                        DetectNumber(8);
                    }
                    break;
            }
        }

        /// <summary>
        /// Process Recognized Distortion Test
        /// </summary>
        private void ProcessRecognizedDistortionTest(string text)
        {
            if (_speechProcessing)
                return;

            switch (_appManager.activeLanguage)
            {
                case "de":
                    if (TryDetectPhrase(text, _mispronunciationsDe["yes"]))
                    {
                        DetectBool(true);
                    }
                    else if (TryDetectPhrase(text, _mispronunciationsDe["no"]))
                    {
                        DetectBool(false);
                    }
                    else if (TryDetectPhrase(text, _mispronunciationsDe["start"]))
                    {
                        DetectStart();
                    }
                    break;
                case "en":
                    if (TryDetectPhrase(text, _mispronunciationsEn["yes"]))
                    {
                        DetectBool(true);
                    }
                    else if (TryDetectPhrase(text, _mispronunciationsEn["no"]))
                    {
                        DetectBool(false);
                    }
                    else if (TryDetectPhrase(text, _mispronunciationsEn["start"]))
                    {
                        DetectStart();
                    }
                    break;
            }
        }

        /// <summary>
        /// Process Recognized Reading Speed Test
        /// </summary>
        private void ProcessRecognizedReadingSpeedTest(string text)
        {
            if (_speechProcessing)
                return;

            Debug.Log(text);

            switch (_appManager.activeLanguage)
            {
                case "de":
                    if (TryDetectPhrase(text, _mispronunciationsDe["start"]))
                    {
                        DetectStart();
                    }
                    else if (
                        ProcessTriggerWordPronunciations(_readingSpeedPronunciationsDe, text)
                        || text.Contains("test beenden")
                    )
                    {
                        DetectReadingSpeechEnd();
                    }
                    break;
                case "en":
                    if (TryDetectPhrase(text, _mispronunciationsEn["start"]))
                    {
                        DetectStart();
                    }
                    else if (
                        ProcessTriggerWordPronunciations(_readingSpeedPronunciationsEn, text)
                        || text.Contains("end test")
                        || text.Contains("and test")
                        || text.Contains("finish test")
                        || text.Contains("exit test")
                    )
                    {
                        DetectReadingSpeechEnd();
                    }
                    break;
            }
        }

        private bool ProcessTriggerWordPronunciations(
            List<List<string>> triggerWordPronunciations,
            string recognizedText
        )
        {
            foreach (string word1 in triggerWordPronunciations[0])
            {
                if (!recognizedText.Contains(word1))
                    continue;
                foreach (string word2 in triggerWordPronunciations[1])
                {
                    if (!recognizedText.Contains(word2))
                        continue;
                    foreach (string word3 in triggerWordPronunciations[2])
                    {
                        if (!recognizedText.Contains(word3))
                            continue;
                        if (recognizedText.Contains($"{word1} {word2} {word3}"))
                        {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        #endregion

        #region Speech Recognition KeyWords

        private void DetectReadingSpeechEnd()
        {
            Debug.Log("Speech -> End Test");
            AppSignals.SpeechRecognitionTestEnd.Dispatch();
            _speechProcessing = true;
            StartCoroutine(ProcessingSpeechRecognition());
        }

        private void DetectNumber(int number)
        {
            Debug.Log($"Speech -> {number}");
            AppSignals.SpeechRecognitionNumber.Dispatch(number);
            _speechProcessing = true;
            StartCoroutine(ProcessingSpeechRecognition());
        }

        private void DetectStart()
        {
            Debug.Log("Speech -> START");
            AppSignals.SpeechRecognitionStart.Dispatch();
            _speechProcessing = true;
            StartCoroutine(ProcessingSpeechRecognition());
        }

        private void DetectBool(bool answer)
        {
            Debug.Log($"Speech -> {answer}");
            AppSignals.SpeechRecognitionBool.Dispatch(answer);
            _speechProcessing = true;
            StartCoroutine(ProcessingSpeechRecognition());
        }

        private bool TryDetectPhrase(string transcript, List<string> pronunciations)
        {
            bool ContainsPronunciation(string pronunciation)
            {
                return transcript.Contains(pronunciation);
            }
            return pronunciations.Exists(ContainsPronunciation);
        }

        #endregion

        IEnumerator ProcessingSpeechRecognition()
        {
            if (_appManager.CurrentActiveTest == AppManager.CurrentTest.ReadingSpeed)
            {
                yield return new WaitForSeconds(1f);
            }
            else
            {
                yield return new WaitForSeconds(.5f);
            }
            _speechProcessing = false;
        }
    }
}
