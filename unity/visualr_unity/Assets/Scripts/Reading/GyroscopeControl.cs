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

namespace Reading
{
    public class GyroscopeControl : MonoBehaviour
    {
        // STATE
        private Transform rawGyroRotation;
        private Quaternion initialRotation;
        private Quaternion gyroInitialRotation;
        private Quaternion offsetRotation;

        public bool GyroEnabled { get; set; }
        private bool gyroInitialized = false;

        // SETTINGS
        [SerializeField]
        private float smoothing = 0.1f;

        [SerializeField]
        private float speed = 60.0f;

        public bool debug;

        private bool calibration;

        private void InitGyro()
        {
            if (!gyroInitialized)
            {
                Debug.Log("Device Orientation: " + Input.deviceOrientation);
                Input.gyro.enabled = true;
                Input.gyro.updateInterval = 0.0167f;
            }
            gyroInitialized = true;
        }

        private void StartGyro()
        {
            if (HasGyro())
            {
                InitGyro();
                GyroEnabled = true;
            }
            else
                GyroEnabled = false;

            /* Get object and gyroscope initial rotation for calibration */
            initialRotation = transform.rotation;
            Recalibrate();

            /* GameObject instance used to prepare object movement */
            rawGyroRotation = new GameObject("GyroRaw").transform;
            rawGyroRotation.SetPositionAndRotation(transform.position, transform.rotation);
        }

        private void OnEnable()
        {
            AppSignals.ReadingSpeedTestInitGyro.AddListener(StartGyro);
        }

        private void OnDisable()
        {
            AppSignals.ReadingSpeedTestInitGyro.RemoveListener(StartGyro);
        }

        private void Update()
        {
            if (!calibration)
                return;

            if (Time.timeScale == 1 && GyroEnabled)
            {
                ApplyGyroRotation(); // Get rotation state in rawGyroRotation
                transform.rotation = Quaternion.Slerp(
                    transform.rotation,
                    initialRotation * rawGyroRotation.rotation,
                    smoothing
                ); // Progressive rotation of the object
            }
        }

        private void ApplyGyroRotation()
        {
            if (!calibration)
                return;

            // Apply initial offset for calibration
            offsetRotation =
                Quaternion.Inverse(gyroInitialRotation) * GyroToUnity(Input.gyro.attitude);

            float curSpeed = Time.deltaTime * speed;
            Quaternion tempGyroRotation =
                new(
                    offsetRotation.x * curSpeed,
                    offsetRotation.y * curSpeed,
                    0f * curSpeed,
                    offsetRotation.w * curSpeed
                );

            rawGyroRotation.rotation = tempGyroRotation;
        }

        private Quaternion GyroToUnity(Quaternion gyro)
        {
            return new Quaternion(gyro.x, gyro.y, -gyro.z, -gyro.w);
        }

        private bool HasGyro()
        {
            return SystemInfo.supportsGyroscope;
        }

        /* Used for calibrate gyro at start or during execution using UI button for example */
        public void Recalibrate()
        {
            Quaternion gyro = GyroToUnity(Input.gyro.attitude);
            gyroInitialRotation.x = gyro.x;
            gyroInitialRotation.y = gyro.y;
            gyroInitialRotation.z = gyro.z;
            gyroInitialRotation.w = gyro.w;
            print("Successfully recalibrated !");
            calibration = true;
        }

        void OnGUI()
        {
            if (debug)
            {
                GUIStyle style =
                    new()
                    {
                        fontSize = Mathf.RoundToInt(Mathf.Min(Screen.width, Screen.height) / 20f)
                    };
                style.normal.textColor = Color.white;
                GUILayout.BeginVertical("box");
                GUILayout.Label("Attitude: " + Input.gyro.attitude.ToString(), style);
                GUILayout.Label("Rotation: " + transform.rotation.ToString(), style);
                GUILayout.Label("Offset Rotation: " + offsetRotation.ToString(), style);
                GUILayout.Label("Raw Rotation: " + rawGyroRotation.rotation.ToString(), style);
                GUILayout.EndVertical();
            }
        }
    }
}
