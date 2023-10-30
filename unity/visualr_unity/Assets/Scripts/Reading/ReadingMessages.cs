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
using Manager;
using UnityEngine;

namespace Reading
{
    public class ReadingMessages : MonoBehaviour
    {
        private UnityMessageManager _unityMessageManager;

        private void Start()
        {
            _unityMessageManager = GetComponent<UnityMessageManager>();
        }

        public void StartRecord()
        {
            Debug.Log("Unity to Flutter Start Record");

            UnityMessage msg = new() { name = "StartRecord", data = null };
            _unityMessageManager.SendMessageToFlutter(msg);
        }

        public void EndRecord()
        {
            Debug.Log("Unity to Flutter End Record");

            UnityMessage msg = new() { name = "EndRecord", data = null };
            _unityMessageManager.SendMessageToFlutter(msg);
        }

        public void ReadingTestReady()
        {
            Debug.Log("Unity to Flutter Reading Speed Test Ready");

            UnityMessage msg = new() { name = "ReadingReady", data = null };
            _unityMessageManager.SendMessageToFlutter(msg);

            /*
            
            Debug.LogError("Remove this before release");
            var testMessage = "{\"words\":\"drawer candidate puzzle palace cottage jazz examiner greeting guest cotton exams player wardrobe wool lorry flu suggestion ice politics tram power printer shoe roll spoon blouse volume basin fridge roof cage ground cake police immigration recipe throat rainforest ingredient title driver granddaughter digital excitement ambition brochure quality idea salt landscape detective apartment kilogramme full elevator singer snack buyer peak army ocean beard underwear goal video accommodation cheek drum sex region charity screen month fashion pitch reporter opinion programme flour toothpaste diagram kettle tune parking folder fare art middle conversation discotheque midnight paragraph frog hairdryer gallery trunk physics Rathaus Rechnung Tomate\"}";
            ReadingTest(testMessage);
            
            */
        }

        /// <summary>
        /// recieve reading words from flutter
        /// </summary>
        /// <param name="message"></param>
        public void ReadingTest(string message)
        {
            Debug.Log("Load new words " + message);
            if (string.IsNullOrEmpty(message))
            {
                Debug.Log("Error: No words recieved");
            }
            else
            {
                var words = JsonUtility.FromJson<Words>(message);
                Debug.Log("Words: " + words.words);
                AppManager.Instance.readingSpeedWords = words.words;

                //get the last three words
                string[] parts = words.words.Split(' ');
                AppManager.Instance.lastThreeWords = $"{parts[^3]} {parts[^2]} {parts[^1]}";
            }
        }

        /// <summary>
        /// message from Flutter that reading speed test can be closed
        /// </summary>
        /// <param name="message"></param>
        public void ReadingSpeedEnd(string message)
        {
            Debug.Log("Reading Speed End");
            AppSignals.ReadingSpeedTestEndScreen.Dispatch();
        }

        public void ReadingSpeedError(string message)
        {
            Debug.Log("Reading Speed Error");
            AppSignals.ReadingSpeedTestErrorScreen.Dispatch();
        }
    }

    [Serializable]
    public class Words
    {
        public string words;
    }
}
