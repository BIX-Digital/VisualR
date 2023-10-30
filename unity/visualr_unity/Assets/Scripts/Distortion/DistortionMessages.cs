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
using Newtonsoft.Json.Linq;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Distortion
{
    public class DistortionMessages : MonoBehaviour
    {
        [Header("Audio Player")]
        public AudioPlayer audioPlayer;

        [Header("Additional Audios")]
        public AudioClip postVoiceResponse;

        public TestDistortion _testDistortion;
        public TestInstruction testInstruction;

        private UnityMessageManager _unityMessageManager;
        private string _messagePart2;

        private bool _blockAnswerMessaging;

        public enum PossibleUserAnswers
        {
            Yes,
            No,
            NoAnswer
        }

        private void Start()
        {
            InitTest();
        }

        private void OnEnable()
        {
            AppSignals.SpeechRecognitionBool.AddListener(UserAnswer);
            AppSignals.SpeechRecognitionActive.AddListener(BlockAnswer);
        }

        private void OnDisable()
        {
            AppSignals.SpeechRecognitionBool.RemoveListener(UserAnswer);
            AppSignals.SpeechRecognitionActive.RemoveListener(BlockAnswer);
        }

        private void InitTest()
        {
            //prevent screen to sleep
            Screen.sleepTimeout = SleepTimeout.NeverSleep;

            _unityMessageManager = GetComponent<UnityMessageManager>();

            if (AppManager.Instance.instructions)
            {
                OpenInstructions();
            }
            else
            {
                AppSignals.DistortionTestNoInstructions.Dispatch();
            }
        }

        /// <summary>
        /// Testing
        /// </summary>
        /// <returns></returns>
        public IEnumerator TestDistortionDD()
        {
            AppManager.Instance.ipd = 62;
            AppManager.Instance.dotSize = 6;

            yield return new WaitForSeconds(0.5f);

            _testDistortion.testActive = true;
            string test =
                "{ \"eye\": \"right\", \"coordinates\": [ { \"x\": 0.0, \"y\": -360.0 }, { \"x\": 0.0, \"y\": -354.0 }, { \"x\": 0.0, \"y\": -348.0 }, { \"x\": 0.0, \"y\": -342.0 }, { \"x\": 0.0, \"y\": -336.0 }, { \"x\": 0.0, \"y\": -330.0 }, { \"x\": 0.0, \"y\": -324.0 }, { \"x\": 0.0, \"y\": -318.0 }, { \"x\": 0.0, \"y\": -312.0 }, { \"x\": 0.0, \"y\": -306.0 }, { \"x\": 0.0, \"y\": -300.0 }, { \"x\": 0.0, \"y\": -294.0 }, { \"x\": 0.0, \"y\": -288.0 }, { \"x\": 0.0, \"y\": -282.0 }, { \"x\": 0.0, \"y\": -276.0 }, { \"x\": 0.0, \"y\": -270.0 }, { \"x\": 0.0, \"y\": -264.0 }, { \"x\": 0.0, \"y\": -258.0 }, { \"x\": 0.0, \"y\": -252.0 }, { \"x\": 0.0, \"y\": -246.0 }, { \"x\": 0.0, \"y\": -240.0 }, { \"x\": 0.0, \"y\": -234.0 }, { \"x\": 0.0, \"y\": -228.0 }, { \"x\": 0.0, \"y\": -222.0 }, { \"x\": 0.0, \"y\": -216.0 }, { \"x\": 0.0, \"y\": -210.0 }, { \"x\": 0.0, \"y\": -204.0 }, { \"x\": 0.0, \"y\": -198.0 }, { \"x\": 0.0, \"y\": -192.0 }, { \"x\": 0.0, \"y\": -186.0 }, { \"x\": 0.0, \"y\": -180.0 }, { \"x\": 0.0, \"y\": -174.0 }, { \"x\": 0.0, \"y\": -168.0 }, { \"x\": 0.0, \"y\": -162.0 }, { \"x\": 0.0, \"y\": -156.0 }, { \"x\": 0.0, \"y\": -150.0 }, { \"x\": 0.0, \"y\": -144.0 }, { \"x\": 0.0, \"y\": -138.0 }, { \"x\": 0.0, \"y\": -132.0 }, { \"x\": 0.0, \"y\": -126.0 }, { \"x\": 0.0, \"y\": -120.0 }, { \"x\": 0.0, \"y\": -114.0 }, { \"x\": 0.0, \"y\": -108.0 }, { \"x\": 0.0, \"y\": -102.0 }, { \"x\": 0.0, \"y\": -96.0 }, { \"x\": 0.0, \"y\": -90.0 }, { \"x\": 0.0, \"y\": -84.0 }, { \"x\": 0.0, \"y\": -78.0 }, { \"x\": 0.0, \"y\": -72.0 }, { \"x\": 0.0, \"y\": -66.0 }, { \"x\": 0.0, \"y\": -60.0 }, { \"x\": 0.0, \"y\": -54.0 }, { \"x\": 0.0, \"y\": -48.0 }, { \"x\": 0.0, \"y\": -42.0 }, { \"x\": 0.0, \"y\": -36.0 }, { \"x\": 0.0, \"y\": -30.0 }, { \"x\": 0.0, \"y\": -24.0 }, { \"x\": 0.0, \"y\": -18.0 }, { \"x\": 0.0, \"y\": -12.0 }, { \"x\": 0.0, \"y\": -6.0 }, { \"x\": 0.0, \"y\": 0.0 }, { \"x\": 0.0, \"y\": 6.0 }, { \"x\": 0.0, \"y\": 12.0 }, { \"x\": 0.0, \"y\": 18.0 }, { \"x\": 0.0, \"y\": 24.0 }, { \"x\": 0.0, \"y\": 30.0 }, { \"x\": 0.0, \"y\": 36.0 }, { \"x\": 0.0, \"y\": 42.0 }, { \"x\": 0.0, \"y\": 48.0 }, { \"x\": 0.0, \"y\": 54.0 }, { \"x\": 0.0, \"y\": 60.0 }, { \"x\": 0.0, \"y\": 66.0 }, { \"x\": 0.0, \"y\": 72.0 }, { \"x\": 0.0, \"y\": 78.0 }, { \"x\": 0.0, \"y\": 84.0 }, { \"x\": 0.0, \"y\": 90.0 }, { \"x\": 0.0, \"y\": 96.0 }, { \"x\": 0.0, \"y\": 102.0 }, { \"x\": 0.0, \"y\": 108.0 }, { \"x\": 0.0, \"y\": 114.0 }, { \"x\": 0.0, \"y\": 120.0 }, { \"x\": 0.0, \"y\": 126.0 }, { \"x\": 0.0, \"y\": 132.0 }, { \"x\": 0.0, \"y\": 138.0 }, { \"x\": 0.0, \"y\": 144.0 }, { \"x\": 0.0, \"y\": 150.0 }, { \"x\": 0.0, \"y\": 156.0 }, { \"x\": 0.0, \"y\": 162.0 }, { \"x\": 0.0, \"y\": 168.0 }, { \"x\": 0.0, \"y\": 174.0 }, { \"x\": 0.0, \"y\": 180.0 }, { \"x\": 0.0, \"y\": 186.0 }, { \"x\": 0.0, \"y\": 192.0 }, { \"x\": 0.0, \"y\": 198.0 }, { \"x\": 0.0, \"y\": 204.0 }, { \"x\": 0.0, \"y\": 210.0 }, { \"x\": 0.0, \"y\": 216.0 }, { \"x\": 0.0, \"y\": 222.0 }, { \"x\": 0.0, \"y\": 228.0 }, { \"x\": 0.0, \"y\": 234.0 }, { \"x\": 0.0, \"y\": 240.0 }, { \"x\": 0.0, \"y\": 246.0 }, { \"x\": 0.0, \"y\": 252.0 }, { \"x\": 0.0, \"y\": 258.0 }, { \"x\": 0.0, \"y\": 264.0 }, { \"x\": 0.0, \"y\": 270.0 }, { \"x\": 0.0, \"y\": 276.0 }, { \"x\": 0.0, \"y\": 282.0 }, { \"x\": 0.0, \"y\": 288.0 }, { \"x\": 0.0, \"y\": 294.0 }, { \"x\": 0.0, \"y\": 300.0 }, { \"x\": 0.0, \"y\": 306.0 }, { \"x\": 0.0, \"y\": 312.0 }, { \"x\": 0.0, \"y\": 318.0 }, { \"x\": 0.0, \"y\": 324.0 }, { \"x\": 0.0, \"y\": 330.0 }, { \"x\": 0.0, \"y\": 336.0 }, { \"x\": 0.0, \"y\": 342.0 }, { \"x\": 0.0, \"y\": 348.0 }, { \"x\": 0.0, \"y\": 354.0 }, { \"x\": 0.0, \"y\": 360.0 } ] }";
            DistortionTest(test);
        }

        /// <summary>
        /// Open Distortion Test  part 2 - from flutter
        /// </summary>
        /// <param name="message"></param>
        public void OpenDistortionPart2(string message)
        {
            Debug.Log("Flutter Message OpenDistortion part 2 call: ");
            _messagePart2 = message;
            StartCoroutine(CloseUnityWithDelay(.5f, false));
        }

        /// <summary>
        /// Send Flutter UnityInstructionsReady to Init Distortion Test Instruction
        /// </summary>
        public void OpenInstructions()
        {
            AppSignals.DistortionTestInstructions.Dispatch();
        }

        #region Messages from Flutter

        /// <summary>
        /// recieve a generated line from flutter
        /// </summary>
        /// <param name="message"></param>
        public void DistortionTest(string message)
        {
            Debug.Log("Load Line data " + message);
            //New dots stop all previous coroutines
            StopAllCoroutines();
            _blockAnswerMessaging = false;

            if (string.IsNullOrEmpty(message))
            {
                Debug.Log("Error: No line data");
            }
            else
            {
                _testDistortion.CurrentLine = null;

                //new test content from flutter - here we recieve a new test dot package
                var line = JsonUtility.FromJson<DottedLine>(message);

                _testDistortion.CurrentLine = line;
                _testDistortion.ShowRedicleUi(false);
            }
        }

        /// <summary>
        /// Flutter Call to show Unity Distortion Pause Message
        /// </summary>
        public void DistortionPause()
        {
            Debug.Log("Unity Distortion Pause");
            //deactivate test
            _testDistortion.testActive = false;

            //call pause view
            AppSignals.DistortionTestPause.Dispatch();
        }

        /// <summary>
        /// Flutter Call to show Unity Distortion End Message
        /// </summary>
        public void DistortionEnd()
        {
            Debug.Log("Unity Distortion Test End");
            //deactivate test
            _testDistortion.testActive = false;

            //call close unity module with delay
            AppSignals.DistortionTestEnd.Dispatch();

            //Call "UnityClose" after 5 sec
            StartCoroutine(CloseUnityWithDelay(5f, true));
        }

        /// <summary>
        /// Call Unity Flutter Message to close Unity Module after given time in sec
        /// </summary>
        /// <param name="time"></param>
        /// <param name="testFinished"></param>
        /// <returns></returns>
        private IEnumerator CloseUnityWithDelay(float time, bool testFinished)
        {
            yield return new WaitForSeconds(time);

            AppManager.Instance.TestDone = testFinished;

            //part 2 will be called - test is not finished
            if (!testFinished)
            {
                AppManager.Instance.DistortionPart2 = true;
                AppManager.Instance.DistortionMessagePart2 = _messagePart2;
            }
            SceneManager.LoadScene("idle");
        }

        #endregion

        /// <summary>
        /// Unity Send Ready to Flutter
        /// </summary>
        public void DistortionTestReady()
        {
            Debug.Log("Unity to Flutter Distortion Test Ready");
            UnityMessage msg = new() { name = "DistortionReady", data = null };
            _unityMessageManager.SendMessageToFlutter(msg);
        }

        public void BlockAnswer(bool state, bool hasDelay)
        {
            _blockAnswerMessaging = !state;
        }

        /// <summary>
        /// user give answer yes - process user answer as flutter response
        /// </summary>
        public void UserAnswer(bool? answer)
        {
            switch (answer)
            {
                case true:
                    ProcessUserAnswer(PossibleUserAnswers.Yes);
                    break;
                case false:
                    ProcessUserAnswer(PossibleUserAnswers.No);
                    break;
                case null:
                    ProcessUserAnswer(PossibleUserAnswers.NoAnswer);
                    break;
            }
        }

        public void ProcessUserAnswer(PossibleUserAnswers answer)
        {
            if (!_testDistortion.testActive)
                return;

            if (_blockAnswerMessaging)
                return;

            _blockAnswerMessaging = true;

            AppSignals.DistortionTestHideQuestion.Dispatch();
            StartCoroutine(ContinueAnswerProcess(answer));
        }

        /// <summary>
        /// Continue Speech Recognition Answer
        /// </summary>
        /// <param name="answer"></param>
        /// <returns></returns>
        private IEnumerator ContinueAnswerProcess(PossibleUserAnswers answer)
        {
            StartCoroutine(audioPlayer.PlayClip(postVoiceResponse, 0));
            yield return new WaitForSeconds(0f);
            AppSignals.DistortionTestHideConfirmation.Dispatch();

            //send user answer no to flutter
            UnityMessage msg = new() { name = "DistortionAnswer", };

            DistortionUserAnswer userAnswer = new();

            switch (answer)
            {
                case PossibleUserAnswers.Yes:
                    userAnswer.answer = "Yes";
                    msg.data = JObject.FromObject(userAnswer);
                    _unityMessageManager.SendMessageToFlutter(msg);
                    break;
                case PossibleUserAnswers.No:
                    userAnswer.answer = "No";
                    msg.data = JObject.FromObject(userAnswer);
                    _unityMessageManager.SendMessageToFlutter(msg);
                    break;
                case PossibleUserAnswers.NoAnswer:
                    userAnswer.answer = "NoAnswer";
                    msg.data = JObject.FromObject(userAnswer);
                    _unityMessageManager.SendMessageToFlutter(msg);
                    break;
            }
        }
    }

    [Serializable]
    public class DistortionUserAnswer
    {
        public string answer;
    }
}
