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

using Lean.Gui;
using Manager;
using UnityEngine;
using UnityEngine.UI;

namespace Contrast
{
    public class TestContrast : MonoBehaviour
    {
        [Header("Background Color")]
        public Image Background;
        public Camera LeftEyeCamera;
        public Camera RightEyeCamera;
        public Image LeftEyeBgr;
        public Image RightEyeBgr;

        [Header("Additional Audios")]
        public AudioClip flashingDots;

        [Header("Flutter Messages")]
        public ContrastMessages contrastMessages;

        [Header("Prefab")]
        public GameObject discPrefab;

        [Header("Device Parameters")]
        public double screenToLensDistance;

        [Header("Center Points")]
        public GameObject CenterPointLeft;
        public GameObject CenterPointRight;
        public Transform CenterLeftEye;
        public Transform CenterRightEye;

        [Header("Reference Camera")]
        public Camera LeftEyeCam;
        public Camera RighEyeCam;

        public ContrastTestItem contrastTestItem;

        public bool testActive;

        private AppManager _appManager;

        private void Awake()
        {
            _appManager = AppManager.Instance;
        }

        //iphone 12 pro = 71,374 mm (2.81 inch)
        //google cardboard screen to lens = 39.3 mm
        private void Start()
        {
            Background.color = AppManager.Instance.backgroundColor;
        }

        public void StartContrastTest()
        {
            // send distortion test ready to flutter
            testActive = true;
            // activate speech recognition
            AppSignals.SpeechRecognitionActive.Dispatch(true, false);
            //Test
            //StartCoroutine(distortionMessages.TestDistortionDD());
            //Production
            contrastMessages.ContrastTestReady();
        }

        /// <summary>
        /// generate dots/rings from test sequence
        /// </summary>
        public void GenerateTestSequence()
        {
            for (int i = 0; i < contrastTestItem.coordinates.Count; i++)
            {
                GenerateDots(
                    contrastTestItem.coordinates[i].x / _appManager.arcMinutesPerPixel,
                    contrastTestItem.coordinates[i].y / _appManager.arcMinutesPerPixel,
                    contrastTestItem.diameter.outer / _appManager.arcMinutesPerPixel,
                    contrastTestItem.diameter.inner / _appManager.arcMinutesPerPixel,
                    contrastTestItem.color.r,
                    contrastTestItem.color.g,
                    contrastTestItem.color.b
                );
            }

            //Show Question - dots/rings are displayed
            AppSignals.ContrastTestShowQuestion.Dispatch();
        }

        /// <summary>
        /// Drow dots or rings
        /// </summary>
        /// <param name="x"></param>
        /// <param name="y"></param>
        /// <param name="outer"></param>
        /// <param name="inner"></param>
        /// <param name="r"></param>
        /// <param name="g"></param>
        /// <param name="b"></param>
        private void GenerateDots(
            double x,
            double y,
            double outer,
            double inner,
            int r,
            int g,
            int b
        )
        {
            var thickness = (outer - inner) / 2;

            if (contrastTestItem.eye == "left")
            {
                var dot = Instantiate(discPrefab, CenterLeftEye, false);
                dot.name = "dot";
                //radius
                dot.GetComponent<RectTransform>().sizeDelta = new Vector2(
                    (float)outer,
                    (float)outer
                );
                //thickness
                dot.GetComponent<LeanCircle>().Thickness = (float)thickness;
                //color
                dot.GetComponent<LeanCircle>().color = new Color(r / 255f, g / 255f, b / 255f);
                //position
                var pos = dot.GetComponent<RectTransform>().anchoredPosition;
                pos.x = (float)x;
                pos.y = (float)y;
                dot.GetComponent<RectTransform>().anchoredPosition = pos;
            }
            else
            {
                var dot = Instantiate(discPrefab, CenterRightEye, false);
                dot.name = "dot";
                //radius
                dot.GetComponent<RectTransform>().sizeDelta = new Vector2(
                    (float)outer,
                    (float)outer
                );
                //thickness
                dot.GetComponent<LeanCircle>().Thickness = (float)thickness;
                //color
                dot.GetComponent<LeanCircle>().color = new Color(r / 255f, g / 255f, b / 255f);
                //position
                var pos = dot.GetComponent<RectTransform>().anchoredPosition;
                pos.x = (float)x;
                pos.y = (float)y;
                dot.GetComponent<RectTransform>().anchoredPosition = pos;
            }
        }

        /// <summary>
        /// Clear and distroy all dots/rings
        /// </summary>
        public void ClearAllDots()
        {
            if (contrastTestItem.eye == "left")
            {
                foreach (Transform child in CenterLeftEye.transform)
                {
                    Destroy(child.gameObject);
                }
            }
            else
            {
                foreach (Transform child in CenterRightEye.transform)
                {
                    Destroy(child.gameObject);
                }
            }
        }
    }
}
