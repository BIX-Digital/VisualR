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

namespace Audio
{
    public class AudioPlayer : MonoBehaviour
    {
        public AudioSource audioSource;

        public IEnumerator PlayClip(AudioClip clip, float delay, bool controlMicrophone = false)
        {
            yield return new WaitForSeconds(delay);
            audioSource.clip = clip;
            audioSource.Play();
            if (controlMicrophone)
            {
                StartCoroutine(WaitForSound());
            }
        }

        public IEnumerator WaitForSound()
        {
            AppSignals.SpeechRecognitionActive.Dispatch(false, false);
            yield return new WaitUntil(() => audioSource.isPlaying == false);
            // as adding a delay of .25 seconds of triggering the activation of the microphone
            // to clips that have a length close to that could lead to race conditions
            // we need to only have a delay when he length of the clip meets a certain
            // threshold.
            bool hasDelay = audioSource.clip.length > 0.5;
            AppSignals.SpeechRecognitionActive.Dispatch(true, hasDelay);
        }
    }
}
