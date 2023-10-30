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

using System.Collections;
using Audio;
using Manager;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Reading
{
    public class TestReadingInstruction : MonoBehaviour
    {
        // 0 - instruction 1 2d
        // 1 - instruction start 3d
        // 2 - eye change 3d
        // 3 - test end 3d
        [Header("Audio CountDown")]
        public AudioClip countDown;

        [Header("Instruction Audios de")]
        public AudioClip[] voiceOverAudios;
        public AudioClip[] voiceOverInstructionAudios;

        [Header("Instruction Audios en")]
        public AudioClip[] voiceOverAudiosEn;
        public AudioClip[] voiceOverInstructionAudiosEn;

        [Header("Audio Player")]
        public AudioPlayer audioPlayer;

        [Header("UI Message Box 2d")]
        public TextMeshProUGUI textMessageLeftEye;
        public TextMeshProUGUI textMessageRightEye;

        public TextMeshPro leftEyeText;
        public TextMeshPro rightEyeText;

        [Header("Head Black Masks / RAW Images Eyes")]
        public GameObject[] blackMasks;
        public GameObject[] eyeRawImages;

        [Header("3d Info Text (Left Eye)")]
        public TextMeshPro leftEyeLookLeft;
        public TextMeshPro leftEyeLookRight;
        public TextMeshPro leftEyeEndTestInfo;

        [Header("3d Info Text (Right Eye)")]
        public TextMeshPro rightEyeLookLeft;
        public TextMeshPro rightEyeLookRight;
        public TextMeshPro rightEyeEndTestInfo;

        [Header("Unity Module")]
        public ReadingMessages readingMessages;

        [Header("Spinner")]
        public GameObject spinnerLeft;
        public GameObject spinnerRight;

        private AppManager _appManager;

        private int _currentRound;
        private int _startEye;
        private bool _speechRecognitionActive;
        private bool _started;

        private int _instructionStartCount;

        private void Awake()
        {
            _appManager = AppManager.Instance;
        }

        private void OnEnable()
        {
            AppSignals.SpeechRecognitionStart.AddListener(UserStart);
            AppSignals.SpeechRecognitionTestEnd.AddListener(UserTestEnd);
            AppSignals.ReadingSpeedTestEndScreen.AddListener(ShowEndScreen);
            AppSignals.ReadingSpeedTestErrorScreen.AddListener(ShowErrorScreen);
        }

        private void OnDisable()
        {
            AppSignals.SpeechRecognitionStart.RemoveListener(UserStart);
            AppSignals.SpeechRecognitionTestEnd.RemoveListener(UserTestEnd);
            AppSignals.ReadingSpeedTestEndScreen.RemoveListener(ShowEndScreen);
            AppSignals.ReadingSpeedTestErrorScreen.RemoveListener(ShowErrorScreen);
        }

        private void Start()
        {
            InstructionsStart();
        }

        /// <summary>
        /// Instruction start
        /// </summary>
        private void InstructionsStart()
        {
            StartCoroutine(Init3dViewWithDelay());
        }

        private IEnumerator Init3dViewWithDelay()
        {
            //reset values
            _instructionStartCount = 0;

            //set wall info label
            leftEyeLookLeft.text = _appManager.instructionDataReading.text.infoSignText;
            leftEyeLookRight.text = _appManager.instructionDataReading.text.infoSignText;
            rightEyeLookLeft.text = _appManager.instructionDataReading.text.infoSignText;
            rightEyeLookRight.text = _appManager.instructionDataReading.text.infoSignText;

            //set end test info
            leftEyeEndTestInfo.text = _appManager.instructionDataReading.text.endTestInstruction;
            rightEyeEndTestInfo.text = _appManager.instructionDataReading.text.endTestInstruction;

            //yield return new WaitForSeconds(9.75f);
            EnableEyeRendering();
            yield return new WaitForSeconds(0.25f);

            //show start message in 3d
            leftEyeText.alignment = TextAlignmentOptions.Center;
            rightEyeText.alignment = TextAlignmentOptions.Center;

            leftEyeText.text = SetTextWithSpacing(
                _appManager.instructionDataReading.instructions[0].text
            );
            rightEyeText.text = SetTextWithSpacing(
                _appManager.instructionDataReading.instructions[0].text
            );

            yield return new WaitForSeconds(.5f);
            // init speech recognition
            AppSignals.SpeechRecognitionActive.Dispatch(true, false);
            _speechRecognitionActive = true;
            //init gyro
            yield return new WaitForSeconds(0.25f);
        }

        #region Instruction Handling

        /// <summary>
        /// Start Instruction flow
        /// </summary>
        private void StartInstruction()
        {
            // stop speech recognition
            _speechRecognitionActive = false;
            AppSignals.SpeechRecognitionActive.Dispatch(false, false);

            //show start message in 3d
            leftEyeText.alignment = TextAlignmentOptions.Center;
            rightEyeText.alignment = TextAlignmentOptions.Center;

            leftEyeText.text = SetTextWithSpacing(
                _appManager.instructionDataReading.instructions[1].text
            );
            rightEyeText.text = SetTextWithSpacing(
                _appManager.instructionDataReading.instructions[1].text
            );

            //play instructions sound id 0

            if (_appManager.activeLanguage == "de")
            {
                StartCoroutine(audioPlayer.PlayClip(voiceOverInstructionAudios[0], 0.05f));
            }
            else if (_appManager.activeLanguage == "en")
            {
                StartCoroutine(audioPlayer.PlayClip(voiceOverInstructionAudiosEn[0], 0.05f));
            }

            Invoke(nameof(ShowInstructionExampleWords), 8);
        }

        private void ShowInstructionExampleWords()
        {
            leftEyeText.alignment = TextAlignmentOptions.Left;
            rightEyeText.alignment = TextAlignmentOptions.Left;
            leftEyeText.text = SetTextWithSpacing(
                _appManager.instructionDataReading.text.instructionWords
            );
            rightEyeText.text = SetTextWithSpacing(
                _appManager.instructionDataReading.text.instructionWords
            );
            Invoke(nameof(ShowInstructionStartText), 10);
        }

        private void ShowInstructionStartText()
        {
            leftEyeText.alignment = TextAlignmentOptions.Center;
            rightEyeText.alignment = TextAlignmentOptions.Center;

            leftEyeText.text = SetTextWithSpacing(
                _appManager.instructionDataReading.instructions[2].text
            );
            rightEyeText.text = SetTextWithSpacing(
                _appManager.instructionDataReading.instructions[2].text
            );

            //play instructions sound id 1

            if (_appManager.activeLanguage == "de")
            {
                StartCoroutine(audioPlayer.PlayClip(voiceOverInstructionAudios[1], 0.05f));
                Invoke(
                    nameof(InitRecognitionAfterInstructionStartText),
                    voiceOverInstructionAudios[1].length + 0.25f
                );
            }
            else if (_appManager.activeLanguage == "en")
            {
                StartCoroutine(audioPlayer.PlayClip(voiceOverInstructionAudiosEn[1], 0.05f));
                Invoke(
                    nameof(InitRecognitionAfterInstructionStartText),
                    voiceOverInstructionAudiosEn[1].length + 0.25f
                );
            }
        }

        private void InitRecognitionAfterInstructionStartText()
        {
            Debug.Log("InitRecognitionAfterInstructionStartText");
            _instructionStartCount = 1;
            _speechRecognitionActive = true;
            AppSignals.SpeechRecognitionActive.Dispatch(true, false);
        }

        #endregion


        private IEnumerator StartCountDown()
        {
            AppSignals.SpeechRecognitionActive.Dispatch(false, false);
            _started = true;
            //send flutter reading test ready
            readingMessages.ReadingTestReady();
            yield return new WaitForSeconds(.25f);
            _currentRound++;
            leftEyeText.text = "";
            rightEyeText.text = "";
            leftEyeText.alignment = TextAlignmentOptions.Center;
            rightEyeText.alignment = TextAlignmentOptions.Center;
            StartCoroutine(audioPlayer.PlayClip(countDown, 0));
            yield return new WaitForSeconds(.5f);
            leftEyeText.text = "3";
            rightEyeText.text = "3";
            yield return new WaitForSeconds(.75f);
            leftEyeText.text = "2";
            rightEyeText.text = "2";
            yield return new WaitForSeconds(.75f);
            leftEyeText.text = "1";
            rightEyeText.text = "1";
            yield return new WaitForSeconds(.75f);
            leftEyeText.text = "";
            rightEyeText.text = "";
            //show text on random eye
            leftEyeText.alignment = TextAlignmentOptions.Left;
            rightEyeText.alignment = TextAlignmentOptions.Left;

            if (_startEye == 0)
            {
                leftEyeText.text = SetTextWithSpacing(_appManager.readingSpeedWords);
                rightEyeText.text = "";
                _startEye++;
            }
            else
            {
                leftEyeText.text = "";
                rightEyeText.text = SetTextWithSpacing(_appManager.readingSpeedWords);
                _startEye--;
            }

            //init recognition and call flutter start record
            readingMessages.StartRecord();
            AppSignals.SpeechRecognitionActive.Dispatch(true, false);
            _speechRecognitionActive = true;
        }

        private IEnumerator ShowSecondEyeInfo()
        {
            AppSignals.SpeechRecognitionActive.Dispatch(false, false);
            _speechRecognitionActive = false;
            leftEyeText.text = "";
            rightEyeText.text = "";
            yield return new WaitForSeconds(.25f);
            leftEyeText.text = SetTextWithSpacing(_appManager.instructionDataReading.text.repeat);
            rightEyeText.text = SetTextWithSpacing(_appManager.instructionDataReading.text.repeat);
            //play instructions sound repeat
            if (_appManager.activeLanguage == "de")
            {
                StartCoroutine(audioPlayer.PlayClip(voiceOverInstructionAudios[2], 0.05f));
                yield return new WaitForSeconds(voiceOverInstructionAudios[2].length);
            }
            else if (_appManager.activeLanguage == "en")
            {
                StartCoroutine(audioPlayer.PlayClip(voiceOverInstructionAudiosEn[2], 0.05f));
                yield return new WaitForSeconds(voiceOverInstructionAudiosEn[2].length);
            }

            //start countdown
            StartCoroutine(StartCountDown());
        }

        private void EnableEyeRendering()
        {
            foreach (var eyeRawImage in eyeRawImages)
            {
                eyeRawImage.SetActive(true);
            }

            foreach (var blackMask in blackMasks)
            {
                blackMask.SetActive(false);
            }
        }

        private void DisableEyeRendering()
        {
            foreach (var eyeRawImage in eyeRawImages)
            {
                eyeRawImage.SetActive(false);
            }

            foreach (var blackMask in blackMasks)
            {
                blackMask.SetActive(true);
            }
        }

        /// <summary>
        /// Call Unity Flutter Message to close Unity Module after given time in sec
        /// </summary>
        /// <param name="time"></param>
        /// <returns></returns>
        private IEnumerator CloseUnityWithDelay(float time)
        {
            yield return new WaitForSeconds(time);
            AppManager.Instance.TestDone = true;
            SceneManager.LoadScene("idle");
        }

        private void ShowEndScreen()
        {
            leftEyeText.text = "";
            rightEyeText.text = "";

            spinnerLeft.SetActive(false);
            spinnerRight.SetActive(false);

            //play instructions sound end
            if (_appManager.activeLanguage == "de")
            {
                StartCoroutine(audioPlayer.PlayClip(voiceOverAudios[3], 0.05f));
            }
            else if (_appManager.activeLanguage == "en")
            {
                StartCoroutine(audioPlayer.PlayClip(voiceOverAudiosEn[3], 0.05f));
            }
            leftEyeText.text = SetTextWithSpacing(_appManager.instructionDataReading.text.end);
            rightEyeText.text = SetTextWithSpacing(_appManager.instructionDataReading.text.end);
            StartCoroutine(CloseUnityWithDelay(5f));
        }

        private void ShowErrorScreen()
        {
            spinnerLeft.SetActive(false);
            spinnerRight.SetActive(false);

            leftEyeText.alignment = TextAlignmentOptions.Center;
            rightEyeText.alignment = TextAlignmentOptions.Center;

            leftEyeText.text = SetTextWithSpacing(_appManager.instructionDataReading.text.error);
            rightEyeText.text = SetTextWithSpacing(_appManager.instructionDataReading.text.error);

            StartCoroutine(CloseUnityWithDelay(5f));
        }

        private string SetTextWithSpacing(string text, double spacing = 0.05, int lineHeight = 80)
        {
            return $"<line-height={lineHeight}%><cspace=-{spacing}em>{text}</cspace=-{spacing}em></line-height={lineHeight}%>";
        }

        #region Speech Recognition

        private void UserTestEnd()
        {
            if (!_speechRecognitionActive)
                return;

            //Call Flutter End Record
            readingMessages.EndRecord();

            if (_currentRound == 1)
            {
                StartCoroutine(ShowSecondEyeInfo());
            }
            else if (_currentRound >= 2)
            {
                leftEyeText.text = "";
                rightEyeText.text = "";

                leftEyeText.alignment = TextAlignmentOptions.Center;
                rightEyeText.alignment = TextAlignmentOptions.Center;

                leftEyeText.text = SetTextWithSpacing(
                    _appManager.instructionDataReading.text.processing
                );
                rightEyeText.text = SetTextWithSpacing(
                    _appManager.instructionDataReading.text.processing
                );

                spinnerLeft.SetActive(true);
                spinnerRight.SetActive(true);
            }
        }

        private void UserStart()
        {
            if (_started)
                return;
            if (!_speechRecognitionActive)
                return;

            Debug.Log("Speech Start");
            InitGyro();

            //start instruction in 3d

            if (_appManager.instructions)
            {
                if (_instructionStartCount == 0)
                {
                    Debug.Log("Start Instruction");
                    StartInstruction();
                }
                else if (_instructionStartCount == 1)
                {
                    Debug.Log("Start count down after instruction");
                    StartCoroutine(StartCountDown());
                }
            }
            else
            {
                Debug.Log("Start Test directly");
                StartCoroutine(StartCountDown());
            }
        }

        #endregion

        #region Gyro Handling

        private void InitGyro()
        {
            //init gyro
            Debug.Log("Init Gyro");
            AppSignals.ReadingSpeedTestInitGyro.Dispatch();
        }

        #endregion
    }
}
