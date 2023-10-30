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
using Lean.Gui;
using UnityEngine;

namespace Distortion
{
    public class PauseTimerAnimation : MonoBehaviour
    {
        private LeanCircle circle;

        private void Awake()
        {
            circle = GetComponent<LeanCircle>();
        }

        private void OnEnable()
        {
            StartCoroutine(StartTimer());
        }

        private void OnDisable()
        {
            circle.Fill = 0f;
            StopAllCoroutines();
        }

        private IEnumerator StartTimer()
        {
            yield return new WaitForSeconds(.25f);
            float timer = 0f;
            while (timer < 10f)
            {
                timer += Time.deltaTime;
                circle.Fill = timer / 10f;
                yield return null;
            }
            circle.Fill = 0f;
        }
    }
}
