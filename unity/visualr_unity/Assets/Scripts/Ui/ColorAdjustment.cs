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

using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using Lean.Gui;
using Manager;
using TMPro;

namespace Ui
{
    public class ColorAdjustment : MonoBehaviour
    {
        private Dictionary<AppManager.CurrentTest, Color> _testToColor;
        private AppManager _appManager;

        private void Awake()
        {
            _appManager = AppManager.Instance;
            _testToColor = new()
            {
                { AppManager.CurrentTest.Contrast, _appManager.contrastColor },
                { AppManager.CurrentTest.Distortion, _appManager.distortionColor },
            };
        }

        private void OnEnable()
        {
            Color color = _testToColor[_appManager.CurrentActiveTest];
            if (TryGetComponent(out LeanCircle circle))
            {
                circle.color = color;
            }

            if (TryGetComponent(out TMP_Text text))
            {
                text.color = color;
            }

            if (TryGetComponent(out Image image))
            {
                image.color = color;
            }
        }
    }
}
