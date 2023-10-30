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
using System.Collections.Generic;
using Audio;
using Manager;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

namespace Ipd
{
    public class IpdSetup : MonoBehaviour
    {
        [Header("Screen Parameters")]
        public ScreenParameters screenParameters;

        public GameObject LeftEyePosition;
        public GameObject RightEyePosition;

        [Header("Step Images")]
        public Sprite Step1;
        public Sprite Step2;
        public Sprite Step3;

        public GameObject Step4TextLeft;
        public GameObject Step4TextRight;

        [Header("IPD Steps")]
        public GameObject IpdImageLeft;
        public GameObject IpdImageRight;

        public GameObject IpdImageFileLeft;
        public GameObject IpdImageFileRight;

        public TextMeshProUGUI IpdImageLeftText;
        public TextMeshProUGUI IpdImageRightText;

        [Header("Rect Transform Eye Position")]
        private RectTransform _leftEyeTransform;
        private RectTransform _rightEyeTransform;

        [Header("Text Messages")]
        public GameObject MessageBoxLeftEye;
        public GameObject MessageBoxRightEye;
        public TextMeshProUGUI MessageLeftEye;
        public TextMeshProUGUI MessageRightEye;

        [Header("Voice Over DE")]
        public AudioClip VoiceDeIntro;
        public AudioClip VoiceDeQuestion;
        public AudioClip[] VoiceDeConfirmations;
        public AudioClip VoiceDeDone;

        [Header("Voice Over EN")]
        public AudioClip VoiceEnIntro;
        public AudioClip VoiceEnQuestion;
        public AudioClip[] VoiceEnConfirmations;
        public AudioClip VoiceEnDone;

        [Header("Additional Audios")]
        public AudioClip postVoiceResponse;
        public AudioClip PresentItem;

        [Header("Audio Player")]
        public AudioPlayer audioPlayer;

        public IpdMessage ipdMessage;

        private bool _activeSpeechRecognition = false;
        public bool started;

        private AppManager _appManager;

        private void Awake()
        {
            _appManager = AppManager.Instance;
        }

        private void OnEnable()
        {
            _leftEyeTransform = LeftEyePosition.GetComponent<RectTransform>();
            _rightEyeTransform = RightEyePosition.GetComponent<RectTransform>();
            AppSignals.SpeechRecognitionStart.AddListener(UserStart);
            AppSignals.SpeechRecognitionNumber.AddListener(ShowConfirmation);
        }

        private void OnDisable()
        {
            AppSignals.SpeechRecognitionStart.RemoveListener(UserStart);
            AppSignals.SpeechRecognitionNumber.RemoveListener(ShowConfirmation);
        }

        private void Start()
        {
            StartCoroutine(InitWithDelay());
        }

        private IEnumerator InitWithDelay()
        {
            IpdImageLeft.SetActive(false);
            IpdImageRight.SetActive(false);

            AppSignals.SpeechRecognitionActive.Dispatch(true, false);
            _activeSpeechRecognition = true;
            yield return new WaitForSeconds(0.5f);
            StartIpdSetup();
        }

        private void StartIpdSetup()
        {
            ShowTextMessage(_appManager.instructionDataIpd.instructions[0].text);

            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);
        }

        public void GenerateStep(IpdStep ipdStep)
        {
            AppSignals.SpeechRecognitionActive.Dispatch(false, false);
            switch (ipdStep.step)
            {
                case 1:
                    StartCoroutine(GenerateImageSequence(Step1, ipdStep.ipdValues));
                    break;
                case 2:
                    StartCoroutine(GenerateImageSequence(Step2, ipdStep.ipdValues));
                    break;
                case 3:
                    StartCoroutine(GenerateImageSequence(Step3, ipdStep.ipdValues));
                    break;
                case 4:
                    StartCoroutine(GenerateTextSequence(ipdStep.ipdValues));
                    break;
            }
        }

        public IEnumerator GenerateImageSequence(Sprite sprite, List<double> ipdValues)
        {
            IpdImageFileLeft.SetActive(true);
            IpdImageFileRight.SetActive(true);

            IpdImageFileLeft.GetComponent<Image>().sprite = sprite;
            IpdImageFileRight.GetComponent<Image>().sprite = sprite;

            MessageBoxLeftEye.SetActive(false);
            MessageBoxRightEye.SetActive(false);

            yield return new WaitForSeconds(0.5f);
            for (int i = 0; i < ipdValues.Count; i++)
            {
                IpdImageLeftText.text = $"{i + 1}";
                IpdImageLeft.SetActive(true);
                IpdImageRightText.text = $"{i + 1}";
                IpdImageRight.SetActive(true);

                SetPupillaryDistance(ipdValues[i]);
                StartCoroutine(audioPlayer.PlayClip(PresentItem, 0.05f));
                yield return new WaitForSeconds(3f);
            }
            IpdImageLeft.SetActive(false);
            IpdImageRight.SetActive(false);
            ShowQuestion();
        }

        public IEnumerator GenerateTextSequence(List<double> ipdValues)
        {
            IpdImageFileLeft.SetActive(false);
            IpdImageFileRight.SetActive(false);

            Step4TextLeft.GetComponent<TextMeshProUGUI>().text = _appManager
                .instructionDataIpd
                .text
                .text;
            Step4TextRight.GetComponent<TextMeshProUGUI>().text = _appManager
                .instructionDataIpd
                .text
                .text;

            Step4TextLeft.SetActive(true);
            Step4TextRight.SetActive(true);

            MessageBoxLeftEye.SetActive(false);
            MessageBoxRightEye.SetActive(false);

            yield return new WaitForSeconds(0.5f);
            for (int i = 0; i < ipdValues.Count; i++)
            {
                IpdImageLeftText.text = $"{i + 1}";
                IpdImageLeft.SetActive(true);
                IpdImageRightText.text = $"{i + 1}";
                IpdImageRight.SetActive(true);

                SetPupillaryDistance(ipdValues[i]);
                StartCoroutine(audioPlayer.PlayClip(PresentItem, 0.05f));
                yield return new WaitForSeconds(3f);
            }
            IpdImageLeft.SetActive(false);
            IpdImageRight.SetActive(false);
            ShowQuestion();
        }

        private void ShowQuestion()
        {
            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);
            ShowTextMessage(
                _appManager.instructionDataIpd.text.question,
                TextAlignmentOptions.Center
            );

            if (_appManager.activeLanguage == "de")
            {
                StartCoroutine(audioPlayer.PlayClip(VoiceDeQuestion, 0.05f, true));
            }
            else if (_appManager.activeLanguage == "en")
            {
                StartCoroutine(audioPlayer.PlayClip(VoiceEnQuestion, 0.05f, true));
            }
            _activeSpeechRecognition = true;
        }

        public IEnumerator IpdSetupDone()
        {
            ShowTextMessage(_appManager.instructionDataIpd.text.end, TextAlignmentOptions.Center);

            if (_appManager.activeLanguage == "de")
            {
                StartCoroutine(audioPlayer.PlayClip(VoiceDeDone, 0.05f));
            }
            else if (_appManager.activeLanguage == "en")
            {
                StartCoroutine(audioPlayer.PlayClip(VoiceEnDone, 0.05f));
            }

            yield return new WaitForSeconds(4.5f);
            yield return new WaitForSeconds(0.25f);
            _appManager.TestDone = true;
            SceneManager.LoadScene("idle");
        }

        private void ShowConfirmation(int? answer)
        {
            if (!started)
                return;
            if (!_activeSpeechRecognition)
                return;
            AppSignals.SpeechRecognitionActive.Dispatch(false, false);
            _activeSpeechRecognition = false;
            StartCoroutine(ProcessUserAnswerWithDelay(answer.GetValueOrDefault()));
        }

        private IEnumerator ProcessUserAnswerWithDelay(int answer)
        {
            StartCoroutine(audioPlayer.PlayClip(postVoiceResponse, 0));
            yield return new WaitForSeconds(1);
            ShowTextMessage(
                string.Format(_appManager.instructionDataIpd.text.understood, answer),
                TextAlignmentOptions.Center
            );

            if (_appManager.activeLanguage == "de")
            {
                StartCoroutine(audioPlayer.PlayClip(VoiceDeConfirmations[answer - 1], 0.05f));
            }
            else if (_appManager.activeLanguage == "en")
            {
                StartCoroutine(audioPlayer.PlayClip(VoiceEnConfirmations[answer - 1], 0.05f));
            }
            yield return new WaitUntil(() => audioPlayer.audioSource.isPlaying == false);
            AppSignals.IPDAAnswer.Dispatch(answer);
        }

        private void UserStart()
        {
            if (started)
                return;
            if (!_activeSpeechRecognition)
                return;
            _activeSpeechRecognition = false;
            started = true;
            AppSignals.IPDAReady.Dispatch();
        }

        private void ShowTextMessage(
            string message,
            TextAlignmentOptions textAlignmentOptions = TextAlignmentOptions.TopLeft
        )
        {
            MessageLeftEye.alignment = textAlignmentOptions;
            MessageRightEye.alignment = textAlignmentOptions;

            MessageLeftEye.text = message;
            MessageRightEye.text = message;
        }

        private void SetPupillaryDistance(double ipdValue)
        {
            float distanceInMm = (float)(ipdValue / 2);
            Debug.Log("distance in mm (from center): " + distanceInMm);
            float distance = screenParameters.GetPixelFromMillimeter(distanceInMm);
            Debug.Log("distance in pixel (from center): " + distance);

            var leftEyePosition = _leftEyeTransform.anchoredPosition;
            leftEyePosition.x = -distance;
            _leftEyeTransform.anchoredPosition = leftEyePosition;

            var rightEyePosition = _rightEyeTransform.anchoredPosition;
            rightEyePosition.x = distance;
            _rightEyeTransform.anchoredPosition = rightEyePosition;
        }
    }
}
