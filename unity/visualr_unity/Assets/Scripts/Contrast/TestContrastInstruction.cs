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

namespace Contrast
{
    public class TestContrastInstruction : MonoBehaviour
    {
        [Header("Dots Instruction Examples")]
        public GameObject DotsExampleLeft;
        public GameObject DotsExampleRight;

        [Header("Cardboard Elements")]
        public GameObject centerLine;

        [Header("Text Messages")]
        public GameObject MessageBoxLeftEye;
        public GameObject MessageBoxRightEye;
        public TMP_Text MessageLeftEye;
        public TMP_Text MessageRightEye;
        public TMP_Text StepsRightEye;
        public TMP_Text StepsLeftEye;

        [Header("Instruction Audios de")]
        public AudioClip[] voiceOverAudios;

        [Header("Instruction Audios en")]
        public AudioClip[] voiceOverAudiosEn;

        [Header("Additional Audios")]
        public AudioClip postVoiceResponse;
        public AudioClip testEndResponse;
        public AudioClip flashingDots;

        [Header("Audio Player")]
        public AudioPlayer audioPlayer;

        private TestContrast testContrast;
        private int _currentStep;
        private AudioClip _currentClip;
        private bool _answerLogged;
        private bool _startLogged;
        private bool _noInstruction;
        private bool _testAnswerLogged;
        private AppManager _appManager;

        private void Awake()
        {
            testContrast = GetComponent<TestContrast>();
            _appManager = AppManager.Instance;
        }

        private void OnEnable()
        {
            AppSignals.SpeechRecognitionStart.AddListener(UserStart);
            AppSignals.SpeechRecognitionNumber.AddListener(UserAnswer);

            AppSignals.ContrastTestEnd.AddListener(TestEndMessage);
            AppSignals.ContrastTestShowQuestion.AddListener(ShowTestQuestionMessage);
            AppSignals.ContrastTestHideQuestion.AddListener(HideTestQuestionMessage);
            AppSignals.ContrastTestInstructions.AddListener(InstructionsStart);
            AppSignals.ContrastTestShowConfirmation.AddListener(ShowConfirmationMessage);
            AppSignals.ContrastTestHideConfirmation.AddListener(HideConfirmationMessage);
            AppSignals.ContrastTestNoInstructions.AddListener(NoInstructionsStart);
        }

        private void OnDisable()
        {
            AppSignals.SpeechRecognitionStart.RemoveListener(UserStart);
            AppSignals.SpeechRecognitionNumber.RemoveListener(UserAnswer);

            AppSignals.ContrastTestEnd.RemoveListener(TestEndMessage);
            AppSignals.ContrastTestShowQuestion.RemoveListener(ShowTestQuestionMessage);
            AppSignals.ContrastTestHideQuestion.RemoveListener(HideTestQuestionMessage);
            AppSignals.ContrastTestInstructions.RemoveListener(InstructionsStart);
            AppSignals.ContrastTestShowConfirmation.RemoveListener(ShowConfirmationMessage);
            AppSignals.ContrastTestHideConfirmation.RemoveListener(HideConfirmationMessage);
            AppSignals.ContrastTestNoInstructions.RemoveListener(NoInstructionsStart);
        }

        #region InstructionFlow

        /// <summary>
        /// start contrast test with instruction
        /// </summary>
        private void InstructionsStart()
        {
            AppSignals.SpeechRecognitionActive.Dispatch(true, false);
            //set message boxes as active
            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);

            //reset parameters
            testContrast.testActive = false;

            _currentStep = 0;
            _answerLogged = false;
            _startLogged = false;
            centerLine.SetActive(true);
            //Show Step Start Message and wait for speech recognition "start"
            ShowTextMessage(
                "1 / 5",
                _appManager.instructionData.instructions[_currentStep].text,
                TextAlignmentOptions.Center
            );
        }

        /// <summary>
        /// start contrast test without instruction
        /// </summary>
        private void NoInstructionsStart()
        {
            AppSignals.SpeechRecognitionActive.Dispatch(true, false);
            //set message boxes as active
            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);

            //reset parameters
            testContrast.testActive = false;
            _noInstruction = true;

            _currentStep = 0;
            _answerLogged = false;
            _startLogged = false;
            centerLine.SetActive(true);
            //Show Step Start Message and wait for speech recognition "start"
            ShowTextMessage(
                "",
                _appManager.instructionData.instructions[_currentStep].text,
                TextAlignmentOptions.Center
            );
        }

        /// <summary>
        /// process next instruction message
        /// </summary>
        private void NextStep()
        {
            AppSignals.SpeechRecognitionActive.Dispatch(false, false);
            _currentStep++;
            //Debug.Log("Current Step: " + _currentStep);
            if (_appManager.activeLanguage == "de")
            {
                _currentClip = voiceOverAudios[_currentStep];
            }
            else if (_appManager.activeLanguage == "en")
            {
                _currentClip = voiceOverAudiosEn[_currentStep];
            }

            switch (_currentStep)
            {
                case 1:
                    //don't enable recognition
                    DotsExampleLeft.SetActive(true);
                    DotsExampleRight.SetActive(true);
                    _answerLogged = true;
                    centerLine.SetActive(false);
                    ShowTextMessageWithAudio(
                        "2 / 5",
                        _currentClip,
                        _appManager.instructionData.instructions[_currentStep].text,
                        TextAlignmentOptions.Left
                    );
                    StartCoroutine(WaitForNextStep(_currentClip.length + 2f));
                    break;
                case 2:
                    ShowTextMessageWithAudio(
                        "3 / 5",
                        _currentClip,
                        _appManager.instructionData.instructions[_currentStep].text,
                        TextAlignmentOptions.Center
                    );
                    //Wait for recognition and enable it
                    StartCoroutine(ActivateRecognitionWithDelay(_currentClip.length + 1f));
                    break;
                case 3:
                    DotsExampleLeft.SetActive(false);
                    DotsExampleRight.SetActive(false);
                    ShowTextMessageWithAudio(
                        "4 / 5",
                        _currentClip,
                        _appManager.instructionData.instructions[_currentStep].text,
                        TextAlignmentOptions.Center
                    );
                    StartCoroutine(WaitForNextStep(_currentClip.length + 2f));
                    break;
                case 4:
                    ShowTextMessageWithAudio(
                        "5 / 5",
                        _currentClip,
                        _appManager.instructionData.instructions[_currentStep].text,
                        TextAlignmentOptions.Center
                    );
                    Debug.Log("Start Test");
                    StartCoroutine(InstructionDone(_currentClip.length + 2f));
                    break;
            }
        }

        /// <summary>
        /// execute next step with delay
        /// </summary>
        /// <param name="time"></param>
        /// <returns></returns>
        private IEnumerator WaitForNextStep(float time)
        {
            yield return new WaitForSeconds(time);
            NextStep();
        }

        /// <summary>
        /// execute instruction done with delay
        /// </summary>
        /// <param name="time"></param>
        /// <returns></returns>
        private IEnumerator InstructionDone(float time)
        {
            yield return new WaitForSeconds(time);

            StepsLeftEye.text = "";
            StepsRightEye.text = "";
            MessageLeftEye.text = "";
            MessageRightEye.text = "";
            //Debug.Log("start test sequence");
            MessageBoxLeftEye.SetActive(false);
            MessageBoxRightEye.SetActive(false);
            testContrast.StartContrastTest();
        }

        private void ShowTextMessage(
            string stepText,
            string message,
            TextAlignmentOptions textAlignmentOptions = TextAlignmentOptions.TopLeft
        )
        {
            MessageLeftEye.alignment = textAlignmentOptions;
            MessageRightEye.alignment = textAlignmentOptions;

            MessageLeftEye.text = message;
            MessageRightEye.text = message;

            StepsLeftEye.text = stepText;
            StepsRightEye.text = stepText;
        }

        /// <summary>
        /// show instruction message
        /// </summary>
        /// <param name="stepText"></param>
        /// <param name="clip"></param>
        /// <param name="message"></param>
        /// <param name="textAlignmentOptions"></param>
        private void ShowTextMessageWithAudio(
            string stepText,
            AudioClip clip,
            string message,
            TextAlignmentOptions textAlignmentOptions = TextAlignmentOptions.TopLeft
        )
        {
            MessageLeftEye.alignment = textAlignmentOptions;
            MessageRightEye.alignment = textAlignmentOptions;

            MessageLeftEye.text = message;
            MessageRightEye.text = message;

            StepsLeftEye.text = stepText;
            StepsRightEye.text = stepText;
            StartCoroutine(audioPlayer.PlayClip(clip, 0.05f));
        }

        #endregion

        /// <summary>
        /// Enable answer recognition for yes and no
        /// </summary>
        /// <param name="time"></param>
        /// <returns></returns>
        private IEnumerator ActivateRecognitionWithDelay(float time)
        {
            yield return new WaitForSeconds(time);
            // enable recognition
            AppSignals.SpeechRecognitionActive.Dispatch(true, false);
            _answerLogged = false;
        }

        /// <summary>
        /// Show Confirmation Message
        /// Verstanden Danke
        /// </summary>
        private void ShowConfirmationMessage()
        {
            //Verstanden. Danke.
            ShowTextMessage("", ""); //if we need again a text feedback - _appManager.instructionData.text.understood
            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);
        }

        /// <summary>
        /// Hide Confirmation Message
        /// Verstanden Danke
        /// </summary>
        private void HideConfirmationMessage()
        {
            ShowTextMessage("", ""); // clear text box
            MessageBoxLeftEye.SetActive(false);
            MessageBoxRightEye.SetActive(false);
        }

        /// <summary>
        /// Show Test Question or play flashing dots/ring audio
        /// </summary>
        private void ShowTestQuestionMessage()
        {
            Debug.Log("Show Question");
            _testAnswerLogged = false;
            //start 10 sec timer to wait on user answer
            StartCoroutine(WaitForUserAnswer());
            StartCoroutine(audioPlayer.PlayClip(flashingDots, 0));
            // we dont show any text message to the user
            //ShowTextMessage(false,"",0, _appManager.instructionData.text.question, true, HorizontalAlignmentOptions.Center, VerticalAlignmentOptions.Top);
            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);
        }

        /// <summary>
        /// Hide Test Question - after user gives answer within 10sec
        /// </summary>
        private void HideTestQuestionMessage()
        {
            Debug.Log("Stop Timer - when user give answer before 10sec");
            _testAnswerLogged = true;

            StopAllCoroutines();

            ShowTextMessage("", "");
            MessageBoxLeftEye.SetActive(false);
            MessageBoxRightEye.SetActive(false);
        }

        /// <summary>
        /// Wait for user answer after 10 sec
        /// </summary>
        /// <returns></returns>
        private IEnumerator WaitForUserAnswer()
        {
            yield return new WaitForSeconds(10f);
            //when no user answer - next item
            if (!_testAnswerLogged)
            {
                Debug.Log("Timer done ");
                //send no user answer to flutter
                AppSignals.SpeechRecognitionNumber.Dispatch(null);
            }
        }

        /// <summary>
        /// Init Test End
        /// </summary>
        private void TestEndMessage()
        {
            StartCoroutine(ShowTestEndMessageWithDelay());
        }

        /// <summary>
        /// Show Test End Message
        /// </summary>
        /// <returns></returns>
        IEnumerator ShowTestEndMessageWithDelay()
        {
            yield return new WaitForSeconds(2f);
            //Der Test ist beendet. Bitte nehmen Sie die VR Brille ab.
            StartCoroutine(audioPlayer.PlayClip(testEndResponse, 0));
            ShowTextMessage("", _appManager.instructionData.text.end, TextAlignmentOptions.Center);
            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);
        }

        #region Speech Recognition

        /// <summary>
        /// Vosk Speech Recognition - START
        /// </summary>
        private void UserStart()
        {
            if (_startLogged)
                return;

            if (testContrast.testActive)
                return;

            if (_startLogged)
                return;

            if (_noInstruction)
            {
                StartCoroutine(InstructionDone(0));
                _noInstruction = false;
            }
            else
            {
                NextStep();
            }

            _startLogged = true;
        }

        /// <summary>
        /// VOSK Speech Recognition - Handling Number detection
        /// </summary>
        private void UserAnswer(int? answer)
        {
            if (!_startLogged)
                return;

            if (testContrast.testActive)
                return;

            if (_answerLogged)
                return;

            //play response sound
            StartCoroutine(audioPlayer.PlayClip(postVoiceResponse, 0));
            StartCoroutine(ProcessUserAnswerWithDelay());
        }

        /// <summary>
        /// Process User answer with delay
        /// </summary>
        /// <returns></returns>
        IEnumerator ProcessUserAnswerWithDelay()
        {
            _answerLogged = true;
            yield return new WaitForSeconds(1);
            NextStep();
        }

        #endregion


        public void StopAllProcesses()
        {
            StopAllCoroutines();
        }
    }
}
