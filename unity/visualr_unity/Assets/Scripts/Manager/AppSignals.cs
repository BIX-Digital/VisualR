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

using strange.extensions.signal.impl;

namespace Manager
{
    public static class AppSignals
    {
        //Speech Recognition
        public static Signal SpeechRecognitionStart = new();
        public static Signal<bool?> SpeechRecognitionBool = new();
        public static Signal SpeechRecognitionTestEnd = new();
        public static Signal<int?> SpeechRecognitionNumber = new();
        public static Signal SpeechRecognitionStop = new();
        public static Signal<bool, bool> SpeechRecognitionActive = new();
        public static Signal SpeechRecognitionStarted = new();

        //
        public static Signal UnityModulClose = new();

        //Distortion Test
        public static Signal DistortionTestInstructions = new();
        public static Signal DistortionTestNoInstructions = new();
        public static Signal DistortionTestEnd = new();
        public static Signal DistortionTestPause = new();
        public static Signal DistortionTestShowQuestion = new();
        public static Signal DistortionTestHideQuestion = new();
        public static Signal DistortionTestShowConfirmation = new();
        public static Signal DistortionTestHideConfirmation = new();
        public static Signal<bool> DistortionTesFocusPointVisibility = new();
        public static Signal DistortionTestNoAnswer = new();

        //Contrast Test
        public static Signal ContrastTestInstructions = new();
        public static Signal ContrastTestNoInstructions = new();
        public static Signal ContrastTestEnd = new();
        public static Signal ContrastTestShowQuestion = new();
        public static Signal ContrastTestHideQuestion = new();
        public static Signal ContrastTestShowConfirmation = new();
        public static Signal ContrastTestHideConfirmation = new();

        //Reading Speed Test
        public static Signal ReadingSpeedTestInitGyro = new();
        public static Signal ReadingSpeedTestEndScreen = new();
        public static Signal ReadingSpeedTestErrorScreen = new();

        //IPDA
        public static Signal<int> IPDAAnswer = new();
        public static Signal IPDAReady = new();
    }
}
