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
using TMPro;
using UnityEngine;

namespace AngleValidation
{
    public class AngleValidation : MonoBehaviour
    {
        public TMP_Text text;
        public RectTransform Dot1;
        public RectTransform Dot2;
        public RectTransform Dot3;
        public RectTransform Dot4;
        public RectTransform RedDot;

        [Header("Device Parameters")]
        public double screenToLensDistance;

        public enum SelectedEye
        {
            Left,
            Right
        }

        public SelectedEye CurrentEye;

        private AppManager _appManager;

        private void Awake()
        {
            _appManager = AppManager.Instance;
        }

        //iphone 12 pro = 71,374 mm (2.81 inch)
        //google cardboard screen to lens = 39.3 mm

        private void Start()
        {
            text.text = _appManager.angleValidationText;
            SetDotsPosition();
        }

        private void SetDotsPosition()
        {
            Dot1.anchoredPosition = UpdatePosition(Dot1, 120f);
            Dot2.anchoredPosition = UpdatePosition(Dot2, -120f);
            Dot3.anchoredPosition = UpdatePosition(Dot3, 240f);
            Dot4.anchoredPosition = UpdatePosition(Dot4, -240f);
            if (CurrentEye == SelectedEye.Left)
            {
                RedDot.anchoredPosition = UpdatePosition(RedDot, -900f);
            }
            else if (CurrentEye == SelectedEye.Right)
            {
                RedDot.anchoredPosition = UpdatePosition(RedDot, 900f);
            }
            float redDotRadius = (float)(200 / _appManager.arcMinutesPerPixel);
            RedDot.sizeDelta = new(redDotRadius, redDotRadius);
        }

        private Vector2 UpdatePosition(RectTransform obj, float offset)
        {
            Vector2 pos = obj.anchoredPosition;
            pos.x = (float)(offset / _appManager.arcMinutesPerPixel);
            return pos;
        }
    }
}
