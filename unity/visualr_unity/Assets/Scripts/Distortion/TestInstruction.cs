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
using Audio;
using Manager;
using TMPro;
using UnityEngine;

namespace Distortion
{
    public class TestInstruction : MonoBehaviour
    {
        [Header("Cardboard Elements")]
        public GameObject centerLine;

        [Header("Pause Timer")]
        public GameObject pauseTimerLeft;
        public GameObject pauseTimerRight;

        [Header("Focus Point")]
        public GameObject focusPointLeft;
        public GameObject focusPointRight;

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
        public AudioClip countDown;
        public AudioClip postVoiceResponse;
        public AudioClip testEndResponse;
        public AudioClip flashingLine;

        [Header("Audio Player")]
        public AudioPlayer audioPlayer;

        /// <summary>
        /// Pause after each voice over in instruction
        /// </summary>
        private readonly float _voiceOverPause = 2f;

        //

        private TestDistortion _testDistortion;
        private int _currentStep;
        private bool _answerLogged;
        private bool _startLogged;
        private bool _noInstruction;
        private bool _testAnswerLogged;
        private bool _speechRecognitionStarted;

        private AppManager _appManager;

        private void Awake()
        {
            _testDistortion = GetComponent<TestDistortion>();
            _appManager = AppManager.Instance;
        }

        private void OnEnable()
        {
            AppSignals.SpeechRecognitionBool.AddListener(UserAnswer);
            AppSignals.SpeechRecognitionStart.AddListener(UserStart);
            AppSignals.SpeechRecognitionStarted.AddListener(SpeechRecognitionStarted);
            AppSignals.DistortionTestEnd.AddListener(TestEndMessage);
            AppSignals.DistortionTestPause.AddListener(TestPauseMessage);
            AppSignals.DistortionTestShowQuestion.AddListener(ShowTestQuestionMessage);
            AppSignals.DistortionTestHideQuestion.AddListener(HideTestQuestionMessage);
            AppSignals.DistortionTestInstructions.AddListener(InstructionsStart);

            AppSignals.DistortionTestNoInstructions.AddListener(NoInstructionsStart);
            AppSignals.DistortionTesFocusPointVisibility.AddListener(ShowFocusPoint);
        }

        private void OnDisable()
        {
            AppSignals.SpeechRecognitionBool.RemoveListener(UserAnswer);
            AppSignals.SpeechRecognitionStart.RemoveListener(UserStart);
            AppSignals.SpeechRecognitionStarted.RemoveListener(SpeechRecognitionStarted);
            AppSignals.DistortionTestEnd.RemoveListener(TestEndMessage);
            AppSignals.DistortionTestPause.RemoveListener(TestPauseMessage);
            AppSignals.DistortionTestShowQuestion.RemoveListener(ShowTestQuestionMessage);
            AppSignals.DistortionTestHideQuestion.RemoveListener(HideTestQuestionMessage);
            AppSignals.DistortionTestInstructions.RemoveListener(InstructionsStart);

            AppSignals.DistortionTestNoInstructions.RemoveListener(NoInstructionsStart);
            AppSignals.DistortionTesFocusPointVisibility.RemoveListener(ShowFocusPoint);
        }

        #region Instruction Flow

        /// <summary>
        /// init instruction
        /// </summary>
        /// <param name="message"></param>
        private void InstructionsStart()
        {
            AppSignals.SpeechRecognitionActive.Dispatch(true, false);
            if (!_appManager.useInstructions)
                return;

            Debug.Log("Instruction Start");

            if (_appManager.distortionPart == 1)
            {
                Debug.Log("Part 1 - step 1 " + _currentStep);
                //reset parameters
                _testDistortion.testActive = false;

                _currentStep = 0;
                _answerLogged = false;
                _startLogged = false;

                //Show Step Start Message and wait for speech recognition "start"
                ShowTextMessage(
                    false,
                    true,
                    1,
                    0,
                    _appManager.instructionData.instructions[0].text,
                    TextAlignmentOptions.Center
                );
            }
            else if (_appManager.distortionPart == 2)
            {
                while (true)
                {
                    if (_speechRecognitionStarted)
                        break;
                }
                Invoke(nameof(Start2ndPart), 2f);
            }
        }

        private void Start2ndPart()
        {
            Debug.Log("Part 2 - step 1a " + _currentStep);
            //reset parameters
            _testDistortion.testActive = false;

            _currentStep = 0;
            _answerLogged = true;
            _startLogged = false;
            ShowTextMessage(
                true,
                false,
                0,
                6,
                _appManager.instructionData.instructions[0].text,
                TextAlignmentOptions.Left
            );
            if (_appManager.activeLanguage == "de")
            {
                StartCoroutine(WaitForNextStep(11f + _voiceOverPause));
            }
            else if (_appManager.activeLanguage == "en")
            {
                StartCoroutine(WaitForNextStep(8f + _voiceOverPause));
            }
        }

        /// <summary>
        /// init instruction
        /// </summary>
        /// <param name="message"></param>
        private void NoInstructionsStart()
        {
            AppSignals.SpeechRecognitionActive.Dispatch(true, false);
            if (_appManager.distortionPart == 1)
            {
                //reset parameters
                _testDistortion.testActive = false;
                _noInstruction = true;

                _currentStep = 0;
                _answerLogged = false;
                _startLogged = false;

                Debug.Log("Start without instructions - part 1");
                //Show Step Start Message and wait for speech recognition "start"
                ShowTextMessage(
                    false,
                    false,
                    1,
                    0,
                    _appManager.instructionData.instructions[0].text
                );
            }
            else
            {
                Debug.Log("Start without instructions - part 2");

                //reset parameters
                _testDistortion.testActive = false;
                //disable speech recognition
                _answerLogged = true;
                _currentStep = 0;
                _answerLogged = false;
                _startLogged = false;

                MessageBoxLeftEye.SetActive(false);
                MessageBoxRightEye.SetActive(false);
                _testDistortion.StartDistortionTest();
            }
        }

        /// <summary>
        /// process next instruction message
        /// </summary>
        private void NextStep()
        {
            AppSignals.SpeechRecognitionActive.Dispatch(false, false);
            _currentStep++;
            Debug.Log("Current Step: " + _currentStep);

            if (_appManager.distortionPart == 1)
            {
                switch (_currentStep)
                {
                    case 1:
                        Debug.Log("step 2a " + _currentStep);
                        //disable speech recognition
                        _answerLogged = true;
                        centerLine.SetActive(false);
                        ShowTextMessage(
                            true,
                            true,
                            2,
                            0,
                            _appManager.instructionData.instructions[1].text
                        );
                        MessageLeftEye.verticalAlignment = VerticalAlignmentOptions.Top;
                        MessageRightEye.verticalAlignment = VerticalAlignmentOptions.Top;
                        if (_appManager.activeLanguage == "de")
                        {
                            StartCoroutine(WaitForNextStep(13 + _voiceOverPause));
                        }
                        else if (_appManager.activeLanguage == "en")
                        {
                            StartCoroutine(WaitForNextStep(13 + _voiceOverPause));
                        }
                        break;
                    case 2:
                        //show focus point
                        Debug.Log("step 2b - show focus point " + _currentStep);
                        MessageBoxLeftEye.SetActive(false);
                        MessageBoxRightEye.SetActive(false);
                        focusPointLeft.SetActive(true);
                        focusPointRight.SetActive(true);
                        StartCoroutine(WaitForNextStep(1f));
                        break;
                    case 3:
                        Debug.Log("step 2c - show straight line " + _currentStep);
                        focusPointLeft.SetActive(false);
                        focusPointRight.SetActive(false);
                        //show line straight
                        MessageBoxLeftEye.SetActive(false);
                        MessageBoxRightEye.SetActive(false);
                        StartCoroutine(ShowLine(0, 1f));
                        StartCoroutine(WaitForNextStep(2f));
                        break;
                    case 4:
                        Debug.Log("step 3a" + _currentStep);
                        focusPointLeft.SetActive(false);
                        focusPointRight.SetActive(false);

                        MessageBoxLeftEye.SetActive(true);
                        MessageBoxRightEye.SetActive(true);
                        ShowTextMessage(
                            true,
                            true,
                            3,
                            1,
                            _appManager.instructionData.instructions[2].text,
                            TextAlignmentOptions.Center
                        );
                        if (_appManager.activeLanguage == "de")
                        {
                            StartCoroutine(WaitForNextStep(11f + _voiceOverPause));
                        }
                        else if (_appManager.activeLanguage == "en")
                        {
                            StartCoroutine(WaitForNextStep(8f + _voiceOverPause));
                        }
                        break;
                    case 5:
                        //show focus point
                        Debug.Log("step 3b - show focus point " + _currentStep);
                        MessageBoxLeftEye.SetActive(false);
                        MessageBoxRightEye.SetActive(false);
                        focusPointLeft.SetActive(true);
                        focusPointRight.SetActive(true);
                        StartCoroutine(WaitForNextStep(1f));
                        //wait 2sec before step 3
                        break;
                    case 6:
                        Debug.Log("step 3c - show distorted line" + _currentStep);
                        //show line distorted
                        focusPointLeft.SetActive(false);
                        focusPointRight.SetActive(false);
                        MessageBoxLeftEye.SetActive(false);
                        MessageBoxRightEye.SetActive(false);
                        StartCoroutine(ShowLine(1, 1f));
                        StartCoroutine(WaitForNextStep(2f));
                        break;
                    case 7:
                        Debug.Log("step 4a " + _currentStep);
                        MessageBoxLeftEye.SetActive(true);
                        MessageBoxRightEye.SetActive(true);
                        ShowTextMessage(
                            true,
                            true,
                            4,
                            2,
                            _appManager.instructionData.instructions[3].text
                        );
                        if (_appManager.activeLanguage == "de")
                        {
                            StartCoroutine(WaitForNextStep(13f + _voiceOverPause));
                        }
                        else if (_appManager.activeLanguage == "en")
                        {
                            StartCoroutine(WaitForNextStep(8.75f + _voiceOverPause));
                        }
                        break;
                    case 8:
                        Debug.Log("step 4b - show focus point " + _currentStep);
                        MessageBoxLeftEye.SetActive(false);
                        MessageBoxRightEye.SetActive(false);
                        focusPointLeft.SetActive(true);
                        focusPointRight.SetActive(true);
                        StartCoroutine(WaitForNextStep(1f));
                        break;
                    case 9:
                        Debug.Log("step 4c - show straight line" + _currentStep);
                        //show line distorted
                        focusPointLeft.SetActive(false);
                        focusPointRight.SetActive(false);
                        StartCoroutine(ShowLine(1, 1f));
                        StartCoroutine(WaitForNextStep(2f));
                        break;
                    case 10:
                        Debug.Log("step 4d - show question" + _currentStep);
                        MessageBoxLeftEye.SetActive(true);
                        MessageBoxRightEye.SetActive(true);
                        ShowTextMessage(
                            true,
                            false,
                            4,
                            3,
                            _appManager.instructionData.text.question,
                            TextAlignmentOptions.Center
                        );
                        //wait for answer y/n
                        StartCoroutine(ActivateRecognitionWithDelay(3f));
                        break;
                    case 11:
                        Debug.Log("step 4e - show answer" + _currentStep);
                        MessageBoxLeftEye.SetActive(true);
                        MessageBoxRightEye.SetActive(true);
                        ShowTextMessage(
                            true,
                            false,
                            5,
                            4,
                            _appManager.instructionData.text.understood,
                            TextAlignmentOptions.Center
                        );
                        StartCoroutine(WaitForNextStep(3f));
                        break;
                    case 12:
                        Debug.Log("step 5 " + _currentStep);
                        MessageBoxLeftEye.SetActive(true);
                        MessageBoxRightEye.SetActive(true);
                        ShowTextMessage(
                            true,
                            true,
                            5,
                            5,
                            _appManager.instructionData.instructions[4].text
                        );
                        StartCoroutine(InstructionDone(6.5f));
                        break;
                }
            }
            else if (_appManager.distortionPart == 2)
            {
                switch (_currentStep)
                {
                    case 1:
                        //show focus point
                        Debug.Log("Part 2 - step 1b - show focus point " + _currentStep);
                        MessageBoxLeftEye.SetActive(false);
                        MessageBoxRightEye.SetActive(false);
                        focusPointLeft.SetActive(true);
                        focusPointRight.SetActive(true);
                        StartCoroutine(WaitForNextStep(1f));
                        break;
                    case 2:
                        Debug.Log("Part 2 - step 1c - show distored line with dots" + _currentStep);
                        //show line distorted
                        focusPointLeft.SetActive(false);
                        focusPointRight.SetActive(false);
                        MessageBoxLeftEye.SetActive(false);
                        MessageBoxRightEye.SetActive(false);
                        StartCoroutine(ShowLine(2, 1f));
                        StartCoroutine(WaitForNextStep(2f));
                        break;
                    case 3:
                        Debug.Log("Part 2 - step 2 " + _currentStep);
                        MessageBoxLeftEye.SetActive(true);
                        MessageBoxRightEye.SetActive(true);
                        ShowTextMessage(
                            true,
                            false,
                            0,
                            7,
                            _appManager.instructionData.instructions[1].text
                        );
                        //yield return new WaitForSeconds(10.25f);
                        if (_appManager.activeLanguage == "de")
                        {
                            StartCoroutine(WaitForNextStep(9f + _voiceOverPause));
                        }
                        else if (_appManager.activeLanguage == "en")
                        {
                            StartCoroutine(WaitForNextStep(9f + _voiceOverPause));
                        }
                        break;
                    case 4:
                        Debug.Log("Part 2 - step 2 - Pause " + _currentStep);
                        MessageBoxLeftEye.SetActive(false);
                        MessageBoxRightEye.SetActive(false);
                        pauseTimerLeft.SetActive(true);
                        pauseTimerRight.SetActive(true);
                        StartCoroutine(WaitForNextStep(10.25f));
                        break;
                    case 5:
                        Debug.Log("Part 2 - step 3 " + _currentStep);
                        MessageBoxLeftEye.SetActive(true);
                        MessageBoxRightEye.SetActive(true);
                        pauseTimerLeft.SetActive(false);
                        pauseTimerRight.SetActive(false);
                        ShowTextMessage(
                            true,
                            false,
                            0,
                            8,
                            _appManager.instructionData.instructions[2].text
                        );
                        if (_appManager.activeLanguage == "de")
                        {
                            StartCoroutine(InstructionDone(7.25f + _voiceOverPause));
                        }
                        else if (_appManager.activeLanguage == "en")
                        {
                            StartCoroutine(InstructionDone(5f + _voiceOverPause));
                        }
                        break;
                }
            }
        }

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

        private IEnumerator ShowLine(int distortedVariant, float time)
        {
            string instructionLine1 =
                "{ \"eye\": \"right\", \"coordinates\": [ { \"x\": 0.0, \"y\": -360.0 }, { \"x\": 0.0, \"y\": -354.0 }, { \"x\": 0.0, \"y\": -348.0 }, { \"x\": 0.0, \"y\": -342.0 }, { \"x\": 0.0, \"y\": -336.0 }, { \"x\": 0.0, \"y\": -330.0 }, { \"x\": 0.0, \"y\": -324.0 }, { \"x\": 0.0, \"y\": -318.0 }, { \"x\": 0.0, \"y\": -312.0 }, { \"x\": 0.0, \"y\": -306.0 }, { \"x\": 0.0, \"y\": -300.0 }, { \"x\": 0.0, \"y\": -294.0 }, { \"x\": 0.0, \"y\": -288.0 }, { \"x\": 0.0, \"y\": -282.0 }, { \"x\": 0.0, \"y\": -276.0 }, { \"x\": 0.0, \"y\": -270.0 }, { \"x\": 0.0, \"y\": -264.0 }, { \"x\": 0.0, \"y\": -258.0 }, { \"x\": 0.0, \"y\": -252.0 }, { \"x\": 0.0, \"y\": -246.0 }, { \"x\": 0.0, \"y\": -240.0 }, { \"x\": 0.0, \"y\": -234.0 }, { \"x\": 0.0, \"y\": -228.0 }, { \"x\": 0.0, \"y\": -222.0 }, { \"x\": 0.0, \"y\": -216.0 }, { \"x\": 0.0, \"y\": -210.0 }, { \"x\": 0.0, \"y\": -204.0 }, { \"x\": 0.0, \"y\": -198.0 }, { \"x\": 0.0, \"y\": -192.0 }, { \"x\": 0.0, \"y\": -186.0 }, { \"x\": 0.0, \"y\": -180.0 }, { \"x\": 0.0, \"y\": -174.0 }, { \"x\": 0.0, \"y\": -168.0 }, { \"x\": 0.0, \"y\": -162.0 }, { \"x\": 0.0, \"y\": -156.0 }, { \"x\": 0.0, \"y\": -150.0 }, { \"x\": 0.0, \"y\": -144.0 }, { \"x\": 0.0, \"y\": -138.0 }, { \"x\": 0.0, \"y\": -132.0 }, { \"x\": 0.0, \"y\": -126.0 }, { \"x\": 0.0, \"y\": -120.0 }, { \"x\": 0.0, \"y\": -114.0 }, { \"x\": 0.0, \"y\": -108.0 }, { \"x\": 0.0, \"y\": -102.0 }, { \"x\": 0.0, \"y\": -96.0 }, { \"x\": 0.0, \"y\": -90.0 }, { \"x\": 0.0, \"y\": -84.0 }, { \"x\": 0.0, \"y\": -78.0 }, { \"x\": 0.0, \"y\": -72.0 }, { \"x\": 0.0, \"y\": -66.0 }, { \"x\": 0.0, \"y\": -60.0 }, { \"x\": 0.0, \"y\": -54.0 }, { \"x\": 0.0, \"y\": -48.0 }, { \"x\": 0.0, \"y\": -42.0 }, { \"x\": 0.0, \"y\": -36.0 }, { \"x\": 0.0, \"y\": -30.0 }, { \"x\": 0.0, \"y\": -24.0 }, { \"x\": 0.0, \"y\": -18.0 }, { \"x\": 0.0, \"y\": -12.0 }, { \"x\": 0.0, \"y\": -6.0 }, { \"x\": 0.0, \"y\": 0.0 }, { \"x\": 0.0, \"y\": 6.0 }, { \"x\": 0.0, \"y\": 12.0 }, { \"x\": 0.0, \"y\": 18.0 }, { \"x\": 0.0, \"y\": 24.0 }, { \"x\": 0.0, \"y\": 30.0 }, { \"x\": 0.0, \"y\": 36.0 }, { \"x\": 0.0, \"y\": 42.0 }, { \"x\": 0.0, \"y\": 48.0 }, { \"x\": 0.0, \"y\": 54.0 }, { \"x\": 0.0, \"y\": 60.0 }, { \"x\": 0.0, \"y\": 66.0 }, { \"x\": 0.0, \"y\": 72.0 }, { \"x\": 0.0, \"y\": 78.0 }, { \"x\": 0.0, \"y\": 84.0 }, { \"x\": 0.0, \"y\": 90.0 }, { \"x\": 0.0, \"y\": 96.0 }, { \"x\": 0.0, \"y\": 102.0 }, { \"x\": 0.0, \"y\": 108.0 }, { \"x\": 0.0, \"y\": 114.0 }, { \"x\": 0.0, \"y\": 120.0 }, { \"x\": 0.0, \"y\": 126.0 }, { \"x\": 0.0, \"y\": 132.0 }, { \"x\": 0.0, \"y\": 138.0 }, { \"x\": 0.0, \"y\": 144.0 }, { \"x\": 0.0, \"y\": 150.0 }, { \"x\": 0.0, \"y\": 156.0 }, { \"x\": 0.0, \"y\": 162.0 }, { \"x\": 0.0, \"y\": 168.0 }, { \"x\": 0.0, \"y\": 174.0 }, { \"x\": 0.0, \"y\": 180.0 }, { \"x\": 0.0, \"y\": 186.0 }, { \"x\": 0.0, \"y\": 192.0 }, { \"x\": 0.0, \"y\": 198.0 }, { \"x\": 0.0, \"y\": 204.0 }, { \"x\": 0.0, \"y\": 210.0 }, { \"x\": 0.0, \"y\": 216.0 }, { \"x\": 0.0, \"y\": 222.0 }, { \"x\": 0.0, \"y\": 228.0 }, { \"x\": 0.0, \"y\": 234.0 }, { \"x\": 0.0, \"y\": 240.0 }, { \"x\": 0.0, \"y\": 246.0 }, { \"x\": 0.0, \"y\": 252.0 }, { \"x\": 0.0, \"y\": 258.0 }, { \"x\": 0.0, \"y\": 264.0 }, { \"x\": 0.0, \"y\": 270.0 }, { \"x\": 0.0, \"y\": 276.0 }, { \"x\": 0.0, \"y\": 282.0 }, { \"x\": 0.0, \"y\": 288.0 }, { \"x\": 0.0, \"y\": 294.0 }, { \"x\": 0.0, \"y\": 300.0 }, { \"x\": 0.0, \"y\": 306.0 }, { \"x\": 0.0, \"y\": 312.0 }, { \"x\": 0.0, \"y\": 318.0 }, { \"x\": 0.0, \"y\": 324.0 }, { \"x\": 0.0, \"y\": 330.0 }, { \"x\": 0.0, \"y\": 336.0 }, { \"x\": 0.0, \"y\": 342.0 }, { \"x\": 0.0, \"y\": 348.0 }, { \"x\": 0.0, \"y\": 354.0 }, { \"x\": 0.0, \"y\": 360.0 } ] }";
            string instructionLine2 =
                "{ \"eye\": \"left\", \"coordinates\": [  { \"x\": 0.0, \"y\": -360.0 },  { \"x\": 0.0, \"y\": -354.0 },  { \"x\": 0.0, \"y\": -348.0 },  { \"x\": 0.0, \"y\": -342.0 },  { \"x\": 0.0, \"y\": -336.0 },  { \"x\": 0.0, \"y\": -330.0 },  { \"x\": 0.0, \"y\": -324.0 },  { \"x\": 0.0, \"y\": -318.0 },  { \"x\": 0.0, \"y\": -312.0 },  { \"x\": 0.0, \"y\": -306.0 },  { \"x\": 0.0, \"y\": -300.0 },  { \"x\": 0.0, \"y\": -294.0 },  { \"x\": 0.0, \"y\": -288.0 },  { \"x\": 0.0, \"y\": -282.0 },  { \"x\": 0.0, \"y\": -276.0 },  { \"x\": 0.0, \"y\": -270.0 },  { \"x\": 0.0, \"y\": -264.0 },  { \"x\": 0.0, \"y\": -258.0 },  { \"x\": 0.0, \"y\": -252.0 },  { \"x\": 0.0, \"y\": -246.0 },  { \"x\": 0.0, \"y\": -240.0 },  { \"x\": 0.0, \"y\": -234.0 },  { \"x\": 0.0, \"y\": -228.0 },  { \"x\": 0.0, \"y\": -222.0 },  { \"x\": 0.0, \"y\": -216.0 },  { \"x\": 0.0, \"y\": -210.0 },  { \"x\": 0.0, \"y\": -204.0 },  { \"x\": 0.0, \"y\": -198.0 },  { \"x\": 0.0, \"y\": -192.0 },  { \"x\": 0.0, \"y\": -186.0 },  { \"x\": 0.0, \"y\": -180.0 },  { \"x\": 0.0, \"y\": -174.0 },  { \"x\": 0.0, \"y\": -168.0 },  { \"x\": 0.0, \"y\": -162.0 },  { \"x\": 0.0, \"y\": -156.0 },  { \"x\": 0.0, \"y\": -150.0 },  { \"x\": 0.0, \"y\": -144.0 },  { \"x\": 0.0, \"y\": -138.0 },  { \"x\": 0.0, \"y\": -132.0 },  { \"x\": 0.0, \"y\": -126.0 },  { \"x\": 0.0, \"y\": -120.0 },  { \"x\": 0.0, \"y\": -114.0 },  { \"x\": 0.0, \"y\": -108.0 },  { \"x\": 0.0, \"y\": -102.0 },  { \"x\": 0.0, \"y\": -96.0 },  { \"x\": 0.0, \"y\": -90.0 },  { \"x\": 0.0, \"y\": -84.0 },  { \"x\": 0.0, \"y\": -78.0 },  { \"x\": 0.0, \"y\": -72.0 },  { \"x\": 0.0, \"y\": -66.0 },  { \"x\": 7.224833323743058, \"y\": -60.0 },  { \"x\": 13.473912872931145, \"y\": -54.0 },  { \"x\": 17.903265827101247, \"y\": -48.0 },  { \"x\": 19.91468352590069, \"y\": -42.0 },  { \"x\": 19.236512863456383, \"y\": -36.0 },  { \"x\": 15.960344545604793, \"y\": -30.0 },  { \"x\": 10.528643257547115, \"y\": -24.0 },  { \"x\": 3.6749903563314072, \"y\": -18.0 },  { \"x\": -3.6749903563314024, \"y\": -12.0 },  { \"x\": -10.52864325754711, \"y\": -6.0 },  { \"x\": -15.960344545604787, \"y\": 0.0 },  { \"x\": -19.23651286345638, \"y\": 6.0 },  { \"x\": -19.914683525900692, \"y\": 12.0 },  { \"x\": -17.903265827101244, \"y\": 18.0 },  { \"x\": -13.473912872931141, \"y\": 24.0 },  { \"x\": -7.224833323743061, \"y\": 30.0 },  { \"x\": -4.898587196589413e-15, \"y\": 36.0 },  { \"x\": 7.22483332374305, \"y\": 42.0 },  { \"x\": 13.473912872931136, \"y\": 48.0 },  { \"x\": 17.90326582710124, \"y\": 54.0 },  { \"x\": 19.91468352590069, \"y\": 60.0 },  { \"x\": 19.236512863456383, \"y\": 66.0 },  { \"x\": 15.960344545604784, \"y\": 72.0 },  { \"x\": 10.528643257547126, \"y\": 78.0 },  { \"x\": 3.6749903563314037, \"y\": 84.0 },  { \"x\": -3.674990356331389, \"y\": 90.0 },  { \"x\": -10.528643257547113, \"y\": 96.0 },  { \"x\": -15.960344545604796, \"y\": 102.0 },  { \"x\": -19.23651286345638, \"y\": 108.0 },  { \"x\": -19.91468352590069, \"y\": 114.0 },  { \"x\": -17.903265827101254, \"y\": 120.0 },  { \"x\": -13.473912872931146, \"y\": 126.0 },  { \"x\": -7.224833323743049, \"y\": 132.0 },  { \"x\": 0.0, \"y\": 138.0 },  { \"x\": 0.0, \"y\": 144.0 },  { \"x\": 0.0, \"y\": 150.0 },  { \"x\": 0.0, \"y\": 156.0 },  { \"x\": 0.0, \"y\": 162.0 },  { \"x\": 0.0, \"y\": 168.0 },  { \"x\": 0.0, \"y\": 174.0 },  { \"x\": 0.0, \"y\": 180.0 },  { \"x\": 0.0, \"y\": 186.0 },  { \"x\": 0.0, \"y\": 192.0 },  { \"x\": 0.0, \"y\": 198.0 },  { \"x\": 0.0, \"y\": 204.0 },  { \"x\": 0.0, \"y\": 210.0 },  { \"x\": 0.0, \"y\": 216.0 },  { \"x\": 0.0, \"y\": 222.0 },  { \"x\": 0.0, \"y\": 228.0 },  { \"x\": 0.0, \"y\": 234.0 },  { \"x\": 0.0, \"y\": 240.0 },  { \"x\": 0.0, \"y\": 246.0 },  { \"x\": 0.0, \"y\": 252.0 },  { \"x\": 0.0, \"y\": 258.0 },  { \"x\": 0.0, \"y\": 264.0 },  { \"x\": 0.0, \"y\": 270.0 },  { \"x\": 0.0, \"y\": 276.0 },  { \"x\": 0.0, \"y\": 282.0 },  { \"x\": 0.0, \"y\": 288.0 },  { \"x\": 0.0, \"y\": 294.0 },  { \"x\": 0.0, \"y\": 300.0 },  { \"x\": 0.0, \"y\": 306.0 },  { \"x\": 0.0, \"y\": 312.0 },  { \"x\": 0.0, \"y\": 318.0 },  { \"x\": 0.0, \"y\": 324.0 },  { \"x\": 0.0, \"y\": 330.0 },  { \"x\": 0.0, \"y\": 336.0 },  { \"x\": 0.0, \"y\": 342.0 },  { \"x\": 0.0, \"y\": 348.0 },  { \"x\": 0.0, \"y\": 354.0 },  { \"x\": 0.0, \"y\": 360.0 }]}";
            string instructionLine3 =
                "{ \"eye\": \"left\", \"coordinates\": [  {\"x\":0.0,\"y\":-360.0},  {\"x\":0.0,\"y\":-300.0},  {\"x\":0.0,\"y\":-240.0},  {\"x\":0.0,\"y\":-180.0},  {\"x\":0.0,\"y\":-120.0},  {\"x\":0.0,\"y\":-60.0},  {\"x\":0.0,\"y\":0.0},  {\"x\":0.0,\"y\":60.0},  {\"x\":0.0,\"y\":120.0},  {\"x\":0.0,\"y\":180.0},  {\"x\":0.0,\"y\":240.0},  {\"x\":0.0,\"y\":300.0},  {\"x\":0.0,\"y\":360.0}]}";

            DottedLine line = new();

            switch (distortedVariant)
            {
                case 0:
                    line = JsonUtility.FromJson<DottedLine>(instructionLine1);
                    break;
                case 1:
                    line = JsonUtility.FromJson<DottedLine>(instructionLine2);
                    break;
                case 2:
                    line = JsonUtility.FromJson<DottedLine>(instructionLine3);
                    break;
            }

            Debug.Log("Show Lines: " + time);

            _testDistortion.CurrentLine = line;
            _testDistortion.ShowRedicleUi(true);
            yield return new WaitForSeconds(time);
        }

        private IEnumerator WaitForNextStep(float time)
        {
            yield return new WaitForSeconds(time);
            NextStep();
        }

        /// <summary>
        ///
        /// </summary>
        /// <param name="time"></param>
        /// <returns></returns>
        private IEnumerator InstructionDone(float time)
        {
            Debug.Log("Instruction Done");
            yield return new WaitForSeconds(time);
            StartCoroutine(audioPlayer.PlayClip(countDown, 0));
            ShowTextMessage(false, false, 0, 0, "3", TextAlignmentOptions.Center);
            yield return new WaitForSeconds(1);
            ShowTextMessage(false, false, 0, 0, "2", TextAlignmentOptions.Center);
            yield return new WaitForSeconds(1);
            ShowTextMessage(false, false, 0, 0, "1", TextAlignmentOptions.Center);
            yield return new WaitForSeconds(0.25f);
            MessageLeftEye.text = string.Empty;
            MessageRightEye.text = string.Empty;

            MessageBoxLeftEye.SetActive(false);
            MessageBoxRightEye.SetActive(false);
            _testDistortion.StartDistortionTest();
        }

        /// <summary>
        /// show instruction message
        /// </summary>
        /// <param name="useAudio"></param>
        /// <param name="showStep"></param>
        /// <param name="step"></param>
        /// <param name="message"></param>
        /// <param name="textAlignmentOptions"></param>
        private void ShowTextMessage(
            bool useAudio,
            bool showStep,
            int step,
            int audioPart,
            string message,
            TextAlignmentOptions textAlignmentOptions = TextAlignmentOptions.Left
        )
        {
            Debug.Log("Part 2 - show text");
            MessageLeftEye.alignment = textAlignmentOptions;
            MessageRightEye.alignment = textAlignmentOptions;

            MessageLeftEye.text = message;
            MessageRightEye.text = message;

            if (showStep)
            {
                if (string.IsNullOrEmpty(message))
                {
                    StepsLeftEye.text = string.Empty;
                    StepsRightEye.text = string.Empty;
                }
                else
                {
                    StepsLeftEye.text =
                        $"{step} / {_appManager.instructionData.instructions.Count}";
                    StepsRightEye.text =
                        $"{step} / {_appManager.instructionData.instructions.Count}";
                }
            }
            else
            {
                StepsLeftEye.text = string.Empty;
                StepsRightEye.text = string.Empty;
            }

            if (useAudio)
            {
                if (_appManager.activeLanguage == "de")
                {
                    StartCoroutine(audioPlayer.PlayClip(voiceOverAudios[audioPart], 0.05f));
                }
                else if (_appManager.activeLanguage == "en")
                {
                    StartCoroutine(audioPlayer.PlayClip(voiceOverAudiosEn[audioPart], 0.05f));
                }
            }
        }

        #endregion


        #region Speech Recognition

        private void SpeechRecognitionStarted()
        {
            _speechRecognitionStarted = true;
        }

        /// <summary>
        /// Voice command - start
        /// </summary>
        private void UserStart()
        {
            if (_startLogged)
                return;

            if (_testDistortion.testActive)
                return;

            AppSignals.SpeechRecognitionActive.Dispatch(false, false);

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
        /// voice command - yes
        /// </summary>
        private void UserAnswer(bool? answer)
        {
            if (!_startLogged)
                return;

            if (_testDistortion.testActive)
                return;

            if (_answerLogged)
                return;

            //play response sound
            StartCoroutine(audioPlayer.PlayClip(postVoiceResponse, 0));
            StartCoroutine(ProcessUserAnswerWithDelay());
        }

        /// <summary>
        /// process user answer
        /// </summary>
        /// <returns></returns>
        IEnumerator ProcessUserAnswerWithDelay()
        {
            _answerLogged = true;
            yield return new WaitForSeconds(1);
            NextStep();
        }

        #endregion

        /// <summary>
        /// show focus point in ui
        /// </summary>
        /// <param name="visibility"></param>
        private void ShowFocusPoint(bool visibility)
        {
            focusPointLeft.SetActive(visibility);
            focusPointRight.SetActive(visibility);
        }

        #region Message Distortion Test

        /// <summary>
        /// Show Test Question
        /// </summary>
        private void ShowTestQuestionMessage()
        {
            _testAnswerLogged = false;
            //start 5 sec timer to wait on user answer
            StartCoroutine(WaitForUserAnswer());
            ShowTextMessage(
                false,
                false,
                0,
                0,
                _appManager.instructionData.text.question,
                TextAlignmentOptions.Center
            );
            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);
        }

        /// <summary>
        /// Hide Test Question
        /// </summary>
        private void HideTestQuestionMessage()
        {
            Debug.Log("Stop Timer User Answer");
            _testAnswerLogged = true;

            StopAllCoroutines();

            //Debug.Log("Hide Test Question");
            ShowTextMessage(false, false, 0, 0, "");
            MessageBoxLeftEye.SetActive(false);
            MessageBoxRightEye.SetActive(false);
        }

        /// <summary>
        /// Wait for user answer 5 sec and continoue
        /// </summary>
        /// <returns></returns>
        private IEnumerator WaitForUserAnswer()
        {
            Debug.Log("Start Timer");
            yield return new WaitForSeconds(5);
            //when no user answer - next item
            if (!_testAnswerLogged)
            {
                //send NoAnswer to flutter
                AppSignals.SpeechRecognitionBool.Dispatch(null);
            }
        }

        /// <summary>
        /// Execute Test End Message from flutter
        /// </summary>
        private void TestEndMessage()
        {
            StartCoroutine(ShowTestEndMessageWithDelay());
        }

        IEnumerator ShowTestEndMessageWithDelay()
        {
            yield return new WaitForSeconds(2f);
            StartCoroutine(audioPlayer.PlayClip(testEndResponse, 0));
            ShowTextMessage(
                false,
                false,
                0,
                0,
                _appManager.instructionData.text.end,
                TextAlignmentOptions.Center
            );
            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);
        }

        /// <summary>
        /// Execute Test Pause Message from flutter
        /// </summary>
        private void TestPauseMessage()
        {
            StartCoroutine(ShowTestPauseMessageWithDelay());
        }

        /// <summary>
        /// Pause Message Start
        /// </summary>
        /// <returns></returns>
        IEnumerator ShowTestPauseMessageWithDelay()
        {
            Debug.Log("show pause message");
            yield return new WaitForSeconds(.25f);
            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);
            ShowTextMessage(
                true,
                false,
                0,
                9,
                _appManager.instructionData.text.pause,
                TextAlignmentOptions.Center
            );
            if (_appManager.activeLanguage == "de")
            {
                yield return new WaitForSeconds(6.25f + _voiceOverPause);
            }
            else if (_appManager.activeLanguage == "en")
            {
                yield return new WaitForSeconds(4.25f + _voiceOverPause);
            }
            StartCoroutine(ShowPauseAnimation());
        }

        /// <summary>
        /// show pause animation
        /// </summary>
        /// <returns></returns>
        IEnumerator ShowPauseAnimation()
        {
            MessageBoxLeftEye.SetActive(false);
            MessageBoxRightEye.SetActive(false);
            //start timer animation
            pauseTimerLeft.SetActive(true);
            pauseTimerRight.SetActive(true);
            yield return new WaitForSeconds(10.25f);
            StartCoroutine(ShowTestPauseEndMessageWithDelay());
        }

        /// <summary>
        /// Pause Message End
        /// </summary>
        /// <returns></returns>
        IEnumerator ShowTestPauseEndMessageWithDelay()
        {
            Debug.Log("show pause end message");
            yield return new WaitForSeconds(.25f);
            pauseTimerLeft.SetActive(false);
            pauseTimerRight.SetActive(false);

            MessageBoxLeftEye.SetActive(true);
            MessageBoxRightEye.SetActive(true);
            ShowTextMessage(
                true,
                false,
                0,
                10,
                _appManager.instructionData.text.pauseEnd,
                TextAlignmentOptions.Center
            );
            if (_appManager.activeLanguage == "de")
            {
                //wait for end of sound
                yield return new WaitForSeconds(6.75f + _voiceOverPause);
            }
            else if (_appManager.activeLanguage == "en")
            {
                yield return new WaitForSeconds(5.75f + _voiceOverPause);
            }

            StartCoroutine(InstructionDone(0));
        }
        #endregion
    }
}
