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
using UnityEngine;

namespace Distortion
{
    public class TestDistortion : MonoBehaviour
    {
        [Header("Audio Player")]
        public AudioPlayer audioPlayer;

        [Header("Flutter Messages")]
        public DistortionMessages distortionMessages;

        [Header("Additional Audios")]
        public AudioClip postVoiceResponse;
        public AudioClip flashingLine;

        [Header("Position Data")]
        public DottedLine CurrentLine;

        [Header("Reference Camera")]
        public Camera LeftEyeCam;
        public Camera RighEyeCam;

        [Header("Dot Prefab")]
        public GameObject DotPrefab;

        public Transform CenterLeftEye;
        public Transform CenterRightEye;

        [Header("Calibrate View Area")]
        public GameObject LeftEyeRedicle;
        public GameObject RightEyeRedicle;

        [Header("Device Parameters")]
        public double screenToLensDistance;

        public bool testActive;
        private bool _testFlowActive;

        //iphone 12 pro = 71,374 mm (2.81 inch)
        //google cardboard screen to lens = 39.3 mm

        private AppManager _appManager;

        private void Awake()
        {
            _appManager = AppManager.Instance;
        }

        private void Start()
        {
            Debug.Log("Device Orientation: " + Input.deviceOrientation);
        }

        public void StartDistortionTest()
        {
            // send distortion test ready to flutter
            testActive = true;
            //Test
            //StartCoroutine(distortionMessages.TestDistortionDD());
            //Production
            distortionMessages.DistortionTestReady();
        }

        /// <summary>
        ///
        /// </summary>
        public void ShowRedicleUi(bool isTestFlow)
        {
            AppSignals.SpeechRecognitionActive.Dispatch(false, false);
            _testFlowActive = isTestFlow;
            LeftEyeRedicle.SetActive(true);
            RightEyeRedicle.SetActive(true);

            StartCoroutine(ShowLineWithDelay());
        }

        IEnumerator ShowLineWithDelay()
        {
            yield return new WaitForSeconds(1f);
            LeftEyeRedicle.SetActive(false);
            RightEyeRedicle.SetActive(false);

            yield return new WaitForSeconds(.25f);
            GenerateLine();
        }

        /// <summary>
        ///
        /// </summary>
        private void GenerateLine()
        {
            for (int x = 0; x < CurrentLine.coordinates.Count; x++)
            {
                GenerateDot(
                    CurrentLine.coordinates[x].x / _appManager.arcMinutesPerPixel,
                    CurrentLine.coordinates[x].y / _appManager.arcMinutesPerPixel
                );
            }

            if (_testFlowActive)
            {
                Debug.Log("Test Flow Active");
                StartCoroutine(ClearDotsAndShowQuestion(.5f));
            }
            else
            {
                StartCoroutine(ClearDotsAndShowQuestion(.25f));
            }
        }

        IEnumerator ClearDotsAndShowQuestion(float displayTime)
        {
            //Show line
            StartCoroutine(audioPlayer.PlayClip(flashingLine, 0));

            yield return new WaitForSeconds(displayTime);

            ClearAllDots();

            yield return new WaitForSeconds(.5f);

            if (testActive)
            {
                AppSignals.SpeechRecognitionActive.Dispatch(true, false);
                AppSignals.DistortionTestShowQuestion.Dispatch();
            }
        }

        /// <summary>
        /// draw dot on x,y pos
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        private void GenerateDot(double x, double y)
        {
            if (_testFlowActive)
            {
                //for the instruction mode we display the line on booth eyes simultaneously
                var dotLeft = Instantiate(DotPrefab, CenterLeftEye, false);
                var dotRight = Instantiate(DotPrefab, CenterRightEye, false);

                //left
                //radius
                dotLeft.GetComponent<RectTransform>().sizeDelta = new Vector2(
                    (float)(_appManager.dotSize / _appManager.arcMinutesPerPixel),
                    (float)(_appManager.dotSize / _appManager.arcMinutesPerPixel)
                );
                //position
                var posLeft = dotLeft.GetComponent<RectTransform>().anchoredPosition;
                posLeft.x = (float)x;
                posLeft.y = (float)y;
                dotLeft.GetComponent<RectTransform>().anchoredPosition = posLeft;

                //right
                //radius
                dotRight.GetComponent<RectTransform>().sizeDelta = new Vector2(
                    (float)(_appManager.dotSize / _appManager.arcMinutesPerPixel),
                    (float)(_appManager.dotSize / _appManager.arcMinutesPerPixel)
                );
                //position
                var posRight = dotRight.GetComponent<RectTransform>().anchoredPosition;
                posRight.x = (float)x;
                posRight.y = (float)y;
                dotRight.GetComponent<RectTransform>().anchoredPosition = posRight;

                //dotLeft.transform.position = LeftEyeCam.ScreenToWorldPoint(new Vector3((float) (_renderImageCenter+x),(float) (_renderImageCenter+y),LeftEyeCam.nearClipPlane));
                //dotRight.transform.position = RighEyeCam.ScreenToWorldPoint(new Vector3((float) (_renderImageCenter+x),(float) (_renderImageCenter+y),LeftEyeCam.nearClipPlane));
            }
            else
            {
                if (CurrentLine.eye == "left")
                {
                    var dot = Instantiate(DotPrefab, CenterLeftEye, false);

                    //radius
                    dot.GetComponent<RectTransform>().sizeDelta = new Vector2(
                        (float)(_appManager.dotSize / _appManager.arcMinutesPerPixel),
                        (float)(_appManager.dotSize / _appManager.arcMinutesPerPixel)
                    );

                    //position
                    var pos = dot.GetComponent<RectTransform>().anchoredPosition;
                    pos.x = (float)x;
                    pos.y = (float)y;
                    dot.GetComponent<RectTransform>().anchoredPosition = pos;

                    //dot.GetComponent<Disc>().Radius = (float)(AppManager.Instance.dotSize / arcMinutesPerPixel);
                    //dot.transform.position = LeftEyeCam.ScreenToWorldPoint(new Vector3((float) (_renderImageCenter+x),(float) (_renderImageCenter+y),LeftEyeCam.nearClipPlane));
                }
                else
                {
                    var dot = Instantiate(DotPrefab, CenterRightEye, false);
                    //radius
                    dot.GetComponent<RectTransform>().sizeDelta = new Vector2(
                        (float)(_appManager.dotSize / _appManager.arcMinutesPerPixel),
                        (float)(_appManager.dotSize / _appManager.arcMinutesPerPixel)
                    );
                    //position
                    var pos = dot.GetComponent<RectTransform>().anchoredPosition;
                    pos.x = (float)x;
                    pos.y = (float)y;
                    dot.GetComponent<RectTransform>().anchoredPosition = pos;

                    //dot.GetComponent<Disc>().Radius = (float)(AppManager.Instance.dotSize / arcMinutesPerPixel);
                    //dot.transform.position = RighEyeCam.ScreenToWorldPoint(new Vector3((float) (_renderImageCenter+x),(float) (_renderImageCenter+y),LeftEyeCam.nearClipPlane));
                }
            }
        }

        /// <summary>
        /// Remove last line
        /// </summary>
        public void ClearAllDots()
        {
            foreach (Transform child in CenterLeftEye.transform)
            {
                Destroy(child.gameObject);
            }

            foreach (Transform child in CenterRightEye.transform)
            {
                Destroy(child.gameObject);
            }
        }
    }

    /// <summary>
    /// Coordinates and line information
    /// </summary>
    [Serializable]
    public class Coordinate
    {
        public double x;
        public double y;
    }

    [Serializable]
    public class DottedLine
    {
        public string eye;
        public List<Coordinate> coordinates;
    }
}
