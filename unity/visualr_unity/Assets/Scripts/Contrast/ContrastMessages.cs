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
using Audio;
using Manager;
using Newtonsoft.Json.Linq;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Contrast
{
    public class ContrastMessages : MonoBehaviour
    {
        [Header("Audio Player")]
        public AudioPlayer audioPlayer;

        [Header("Additional Audios")]
        public AudioClip postVoiceResponse;

        public TestContrast testContrast;
        public TestContrastInstruction testContrastInstruction;

        private UnityMessageManager _unityMessageManager;

        private bool _blockAnswerMessaging;

        private void Start()
        {
            //prevent screen to sleep
            Screen.sleepTimeout = SleepTimeout.NeverSleep;

            _unityMessageManager = GetComponent<UnityMessageManager>();

            //
            //Test remove this
            //Debug.LogError("Remove this - before release");
            //ContrastTestReady();
            //return;

            if (AppManager.Instance.instructions)
            {
                OpenInstructions();
            }
            else
            {
                AppSignals.ContrastTestNoInstructions.Dispatch();
            }
        }

        private void OnEnable()
        {
            AppSignals.SpeechRecognitionNumber.AddListener(UserAnswer);
        }

        private void OnDisable()
        {
            AppSignals.SpeechRecognitionNumber.RemoveListener(UserAnswer);
        }

        /// <summary>
        /// Send Flutter UnityInstructionsReady to Init Distortion Test Instruction
        /// </summary>
        public void OpenInstructions()
        {
            AppSignals.ContrastTestInstructions.Dispatch();
        }

        #region FLutter Communication

        /// <summary>
        /// receive contrast dots from flutter
        /// </summary>
        /// <param name="message"></param>
        public void ContrastTest(string message)
        {
            //New dots/rings - stop all previous coroutines
            StopAllCoroutines();
            _blockAnswerMessaging = false;

            if (string.IsNullOrEmpty(message))
            {
                Debug.Log("Error: No dots data");
            }
            else
            {
                testContrast.contrastTestItem = null;

                Debug.Log("New dots: " + message);

                //new test content from flutter - here we receive a new test dot package
                var dots = JsonUtility.FromJson<ContrastTestItem>(message);

                testContrast.contrastTestItem = dots;
                testContrast.GenerateTestSequence();
            }
        }

        /// <summary>
        /// Unity send Ready to Flutter
        /// </summary>
        public void ContrastTestReady()
        {
            Debug.Log("Unity to Flutter Contrast Test Ready");

            UnityMessage msg = new() { name = "ContrastReady", data = null };
            _unityMessageManager.SendMessageToFlutter(msg);
        }

        /// <summary>
        /// Flutter send End Message
        /// </summary>
        public void ContrastEnd()
        {
            Debug.Log("Flutter to Unity send Contrast End");
            testContrast.testActive = false;

            //Call close unity module with delay
            AppSignals.ContrastTestEnd.Dispatch();

            //Call "UnityClose" after 5 sec
            StartCoroutine(CloseUnityWithDelay(5f));
        }

        /// <summary>
        /// Call Unity Flutter Message to close Unity Module after given time in sec
        /// </summary>
        /// <param name="time"></param>
        /// <returns></returns>
        private IEnumerator CloseUnityWithDelay(float time)
        {
            yield return new WaitForSeconds(time);
            //Stop all coroutines
            testContrastInstruction.StopAllProcesses();

            yield return new WaitForSeconds(0.25f);
            AppManager.Instance.TestDone = true;
            SceneManager.LoadScene("idle");
        }

        #endregion

        #region Speech Recognition Answer

        /// <summary>
        /// user give answer - process user answer as flutter response
        /// </summary>
        public void UserAnswer(int? message)
        {
            if (_blockAnswerMessaging)
                return;

            _blockAnswerMessaging = true;

            if (!testContrast.testActive)
                return;

            AppSignals.ContrastTestHideQuestion.Dispatch();
            StartCoroutine(ContinueAnswerProcess(message));
        }

        /// <summary>
        /// Continue Speech Recognition Answer
        /// </summary>
        /// <param name="answer"></param>
        /// <returns></returns>
        private IEnumerator ContinueAnswerProcess(int? answer)
        {
            //Remove existing dots/rings
            testContrast.ClearAllDots();
            //play post voice response
            StartCoroutine(audioPlayer.PlayClip(postVoiceResponse, 0));
            //clear and hidden text box
            AppSignals.ContrastTestHideConfirmation.Dispatch();
            //delay for post voice audio
            yield return new WaitForSeconds(0f);
            //send user answer to flutter
            Debug.Log("send user answer to flutter: " + answer);
            ContrastUserAnswer userAnswer = new() { answer = answer ?? 0 };

            UnityMessage msg =
                new() { name = "ContrastAnswer", data = JObject.FromObject(userAnswer) };
            _unityMessageManager.SendMessageToFlutter(msg);
        }

        #endregion
    }

    [Serializable]
    public class ContrastUserAnswer
    {
        public int answer;
    }

    /// <summary>
    /// Coordinates and dot information
    /// </summary>
    ///

    [Serializable]
    public class ColorValue
    {
        public int r;
        public int g;
        public int b;
    }

    [Serializable]
    public class ContrastTestItem
    {
        public string eye;
        public ColorValue color;
        public Diameter diameter;
        public List<Coordinate> coordinates;
    }

    [Serializable]
    public class Diameter
    {
        public double outer;
        public double inner;
    }

    [Serializable]
    public class Coordinate
    {
        public double x;
        public double y;
    }
}
