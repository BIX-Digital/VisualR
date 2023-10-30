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
using Init;
using UnityEngine;

namespace Manager
{
    public class AppManager : MonoBehaviour
    {
        [Header("ArcMinutes Parameters")]
        //Font size in ArcMinutes
        public double arcMinFont = 120f;
        public double screenToLensDistance = 40f;
        public int screenHeight;
        public int screenWidth;
        public double verticalAngle;
        public double arcMinutesPerPixel;
        public double magnifyingFactor = 0.42;

        //Image Size in ArcMinutes
        public float arcMinSize = 800f;
        public int distortionPart = 0;

        //Image Margin Y
        public float arcMinMargin = 500f;

        [Header("Unity Test Setup")]
        public bool unityEditorTesting;

        public bool showCenterPointInTest = false;

        [Header("Instruction Data")]
        public InstructionText instructionData;

        [Header("Instruction Data for IPD")]
        public InstructionTextIpd instructionDataIpd;

        [Header("Instruction Data for Reading Speed Test")]
        public InstructionTextReading instructionDataReading;

        [Header("Reading Text for Reading Speed Test")]
        public string readingSpeedWords;
        public string lastThreeWords = "end";

        [Header("Distortion Test Parameters")]
        public bool DistortionPart2;
        public string DistortionMessagePart2;
        public bool DistortionTestPart2;

        [Header("Color Value")]
        public Color backgroundColor;
        public Color distortionColor;
        public Color contrastColor;

        [Header("Angle Validation")]
        public string angleValidationText;

        public float ipd;

        public float dotSize;

        public bool useInstructions;

        public bool debug;

        public enum CurrentTest
        {
            Ipda,
            Distortion,
            Contrast,
            ReadingSpeed,
            Settings,
        }

        public string activeLanguage = "de";

        public bool init;
        public bool TestDone;
        public bool instructions;

        public CurrentTest CurrentActiveTest;

        /// <summary>
        /// Singelton with locking mechanism and preventing unity memory leaks
        /// </summary>
        private static readonly object _lock = new();
        private static bool _applicationIsQuitting;
        private static AppManager _instance = null;
        public static AppManager Instance
        {
            get
            {
                if (_applicationIsQuitting)
                {
                    return null;
                }
                lock (_lock)
                {
                    if (_instance == null)
                    {
                        GameObject go = new("App Manager");
                        _instance = go.AddComponent<AppManager>();
                        DontDestroyOnLoad(go);
                    }
                }
                return _instance;
            }
            private set { }
        }

        /// <summary>
        ///
        /// </summary>
        public void InitUnityModule()
        {
#if UNITY_EDITOR
            unityEditorTesting = true;
#else
            unityEditorTesting = false;
#endif
        }

        public float GetScreenHeightInMm()
        {
#if UNITY_ANDROID
            return Screen.height / GetDPI() * 25.4f;
#elif UNITY_EDITOR
            return Screen.height / GetDPI() * 25.4f;
#elif UNITY_IOS
            if (unityEditorTesting)
            {
                //iphone 12
                screenHeight = 1170;
                //iphone SE 2.
                //screenHeight = 750;
                //dpi iphone 12
                return screenHeight / 460f * 25.4f;
                //dpi iphone se 2nd
                //return screenHeight / 326f * 25.4f;
            }

            return screenHeight / Screen.dpi * 25.4f;
#endif
        }

        /// <summary>
        /// Reset Unity Module
        /// </summary>
        public void ResetUnityModule()
        {
            DistortionMessagePart2 = String.Empty;
            readingSpeedWords = String.Empty;
            instructionDataReading = null;
            instructionData = null;
            ipd = 0;
        }

        private void OnDestroy()
        {
            _applicationIsQuitting = true;
        }

        public float GetDPI()
        {
#if UNITY_EDITOR
            return 64f;
#else
            AndroidJavaClass activityClass = new AndroidJavaClass("com.unity3d.player.UnityPlayer");
            AndroidJavaObject activity = activityClass.GetStatic<AndroidJavaObject>(
                "currentActivity"
            );

            AndroidJavaObject metrics = new AndroidJavaObject("android.util.DisplayMetrics");
            activity
                .Call<AndroidJavaObject>("getWindowManager")
                .Call<AndroidJavaObject>("getDefaultDisplay")
                .Call("getMetrics", metrics);

            return (metrics.Get<float>("xdpi") + metrics.Get<float>("ydpi")) * 0.5f;
#endif
        }
    }
}
