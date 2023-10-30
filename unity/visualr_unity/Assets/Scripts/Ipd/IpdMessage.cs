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
using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;
using UnityEngine;

namespace Ipd
{
    public class IpdMessage : MonoBehaviour
    {
        private UnityMessageManager _unityMessageManager;
        public IpdSetup ipdSetup;

        private void Start()
        {
            //prevent screen to sleep
            Screen.sleepTimeout = SleepTimeout.NeverSleep;

            _unityMessageManager = GetComponent<UnityMessageManager>();
        }

        private void OnEnable()
        {
            AppSignals.IPDAAnswer.AddListener(UserAnswer);
            AppSignals.IPDAReady.AddListener(IpdReady);
        }

        private void OnDisable()
        {
            AppSignals.IPDAAnswer.RemoveListener(UserAnswer);
            AppSignals.IPDAReady.RemoveListener(IpdReady);
        }

        public void IpdStep(string message)
        {
            Debug.Log(message);
            IpdStep ipdStep = JsonUtility.FromJson<IpdStep>(message);
            ipdSetup.GenerateStep(ipdStep);
        }

        private void IpdReady()
        {
            IpdDpi dpi = new() { dpi = Screen.dpi, };
            UnityMessage msg = new() { name = "IpdReady", data = JObject.FromObject(dpi), };

            _unityMessageManager.SendMessageToFlutter(msg);
        }

        public void IpdEnd(string message)
        {
            StartCoroutine(ipdSetup.IpdSetupDone());
        }

        private void UserAnswer(int answer)
        {
            IpdUserAnswer userAnswer = new() { answer = answer, };
            UnityMessage msg = new() { name = "IpdAnswer", data = JObject.FromObject(userAnswer), };

            _unityMessageManager.SendMessageToFlutter(msg);
        }
    }
}

[Serializable]
public class IpdUserAnswer
{
    public int answer;
}

[Serializable]
public class IpdDpi
{
    public float dpi;
}

[Serializable]
public class IpdStep
{
    public List<double> ipdValues;
    public int step;
}
