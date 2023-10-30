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

namespace ArcMinuteCalculation
{
    public class ArcMinutesToPosition : MonoBehaviour
    {
        public RectTransform rectTransform;

        private AppManager _appManager;

        private void Awake()
        {
            _appManager = AppManager.Instance;
            rectTransform = GetComponent<RectTransform>();
        }

        private void Start()
        {
            SetPosition();
        }

        private void SetPosition()
        {
            //position
            var pos = rectTransform.anchoredPosition;
            pos.y = (float)(_appManager.arcMinMargin / _appManager.arcMinutesPerPixel);
            rectTransform.anchoredPosition = pos;
        }
    }
}
