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

using Manager;
using UnityEngine;

namespace Ipd
{
    public class SetIpd : MonoBehaviour
    {
        private float _screenDpi;

        public RectTransform eye;

        public enum Eye
        {
            Left,
            Right
        }

        public Eye currentEye;

        // 1 inch -> 25,4 mm
        private const float INCH_IN_MM = 25.4f;

        private void Start()
        {
            GetScreenParameters();
        }

        /// <summary>
        /// get Screen Parameter from device and calc physical dimensions
        /// </summary>
        /// <returns></returns>
        private void GetScreenParameters()
        {
            _screenDpi = Screen.dpi;

#if UNITY_EDITOR
            //iphone 12 pro max - test data 458dpi
            _screenDpi = 460f;
            AppManager.Instance.ipd = 60f;
#endif
            if (currentEye == Eye.Left)
            {
                var eyePos = eye.anchoredPosition;
                eyePos.x = GetPixelFromMillimeter(-AppManager.Instance.ipd / 2);
                eye.anchoredPosition = eyePos;
            }
            else if (currentEye == Eye.Right)
            {
                var eyePos = eye.anchoredPosition;
                eyePos.x = GetPixelFromMillimeter(AppManager.Instance.ipd / 2);
                eye.anchoredPosition = eyePos;
            }
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
    }
}
