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

using DG.Tweening;
using UnityEngine;

namespace Distortion
{
    public class FocusPointAnimation : MonoBehaviour
    {
        private Vector3 _originalScale;
        private Vector3 _scaleTo;
        private readonly float _animationTime = 0.5f;

        private void Start()
        {
            _originalScale = transform.localScale;
            _scaleTo = _originalScale * 2;
            Scale();
        }

        private void Scale()
        {
            transform
                .DOScale(_scaleTo, _animationTime)
                .SetEase(Ease.InOutSine)
                .OnComplete(() =>
                {
                    transform
                        .DOScale(_originalScale, _animationTime)
                        .SetEase(Ease.InOutSine)
                        .SetDelay(0.25f)
                        .OnComplete(Scale);
                });
        }
    }
}
