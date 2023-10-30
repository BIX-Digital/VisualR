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
using Manager;
using UnityEngine;

namespace Ipd
{
    public class ScreenParameters : MonoBehaviour
    {
        private float _screenDpi;
        private float _screenHeight;
        private float _screenWidth;
        private float _screenPhyHeight;
        private float _screenPhyWidth;

        //
        [Header("Ruler Ui 50mm")]
        public RectTransform posA50Mm;
        public RectTransform posB50Mm;
        public RectTransform centerLine50Mm;

        //
        [Header("Ruler Ui 75mm")]
        public RectTransform posA75Mm;
        public RectTransform posB75Mm;
        public RectTransform centerLine75Mm;

        public ScreenValues ScreenValues;

        // 1 inch -> 25,4 mm
        private const float INCH_IN_MM = 25.4f;

        private AppManager _appManager;

        private void Awake()
        {
            _appManager = AppManager.Instance;
        }

        private void Start()
        {
            StartCoroutine(GetScreenParameters());
        }

        /// <summary>
        /// get Screen Parameter from device and calc physical dimensions
        /// </summary>
        /// <returns></returns>
        IEnumerator GetScreenParameters()
        {
            yield return new WaitForSeconds(.25f);
            _screenDpi = Screen.dpi;

#if UNITY_EDITOR
            //iphone 13 pro max - test data 458dpi
            _screenDpi = 458f;
#endif
            _screenHeight = _appManager.screenHeight;
            _screenWidth = Screen.width;

            // 1 inch -> 25,4 mm
            _screenPhyHeight = _screenHeight / _screenDpi * INCH_IN_MM;
            _screenPhyWidth = _screenWidth / _screenDpi * INCH_IN_MM;
            //SetRuler(_screenPhyWidth);

            ScreenValues ScreenValues =
                new()
                {
                    dpi = _screenDpi,
                    pixelHeight = _screenHeight,
                    pixelWidth = _screenWidth,
                    mmHeight = _screenPhyHeight,
                    mmWidth = _screenPhyWidth
                };

            Debug.Log(
                "Screen Parameters: "
                    + _screenDpi
                    + " - "
                    + _screenHeight
                    + " - "
                    + _screenWidth
                    + " - in mm: "
                    + _screenPhyHeight
                    + " - "
                    + _screenPhyWidth
            );
        }

        /// <summary>
        /// get pixel from millimeter values  based on device parameter
        /// </summary>
        /// <param name="mm"></param>
        /// <returns></returns>
        public float GetPixelFromMillimeter(float mm)
        {
            var pixel = _screenDpi * mm / INCH_IN_MM;
            return pixel;
        }

        public object GetScreenValues()
        {
            return ScreenValues;
        }
    }

    public class ScreenValues
    {
        public float dpi;
        public float pixelHeight;
        public float pixelWidth;
        public float mmHeight;
        public float mmWidth;
    }
}
