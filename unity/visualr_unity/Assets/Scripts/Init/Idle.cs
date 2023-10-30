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
using System.Collections.Generic;
using Manager;
using Contrast;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace Init
{
    public class Idle : MonoBehaviour
    {
        private UnityMessageManager _unityMessageManager;
        private AppManager _appManager;

        private void Awake()
        {
            _appManager = AppManager.Instance;
        }

        private void OnEnable()
        {
            AppSignals.UnityModulClose.AddListener(UnityModulClose);
        }

        private void OnDisable()
        {
            AppSignals.UnityModulClose.RemoveListener(UnityModulClose);
        }

        private void Start()
        {
            Debug.Log("Device Orientation: " + Input.deviceOrientation);
            _appManager.InitUnityModule();

            //prevent screen to sleep
            Screen.sleepTimeout = SleepTimeout.NeverSleep;

            _unityMessageManager = GetComponent<UnityMessageManager>();

            //when test is done we close unity module
            //flutter will close it -> UnityClose
            if (_appManager.TestDone)
            {
                Debug.Log("Test Done Close Unity");
                _appManager.TestDone = false;
                UnityModulClose();
            }
            else if (!_appManager.TestDone && _appManager.DistortionPart2)
            {
                Debug.Log("Idle - Start Distortion Part 2");
                _appManager.DistortionPart2 = false;
                OpenDistortionPart2(_appManager.DistortionMessagePart2);
            }

            //Test
            //OpenSettings("{\"ipd\":52.5,\"height\":1170,\"screenToLensDistance\":39.3}");
            //OpenContrast("{\"instructions\":\"true\",\"backgroundColor\":{\"r\":26,\"g\":26,\"b\":26},\"locale\":\"de\",\"ipd\":52.5,\"arcMinFont\":120, \"height\":1170,\"text\":{\"instructions\":[{\"id\":1,\"text\":\"Sagen Sie <i>START</i> um zu beginnen.\"},{\"id\":2,\"text\":\"Als Nächstes werden Ihnen mehrere Kreise in verschiedenen Grautönen gezeigt. Womöglich werden Sie nicht alle sehen.\"},{\"id\":3,\"text\":\"Wie viele Kreise sehen Sie?\"},{\"id\":4,\"text\":\"Verstanden. Danke.\"},{\"id\":5,\"text\":\"Der Test startet nun.\"}],\"text\":{\"question\":\"Wie viele Kreise sehen Sie?\",\"understood\":\"Verstanden. Danke.\",\"end\":\"Der Test ist beendet. Bitte nehmen Sie die VR Brille ab.\"}}}");
            //OpenIpd("{\"instructions\":\"true\",\"debug\":\"true\",\"locale\":\"de\",\"arcMinFont\":120, \"height\":1170,\"arcMinSize\":700,\"text\":{\"instructions\":[{\"id\":1,\"text\":\"Sagen Sie START  <i>nachdem</i> Sie die VR Brille aufgesetzt haben.\"}],\"text\":{\"question\":\"Welches Bild war das schärfste?\",\"understood\":\"Bild {0} war das schärfste. Verstanden. Danke.\",\"end\":\"Die Einstellung ist beendet. Bitte nehmen Sie die VR Brille ab.\"}}}");
            //OpenReadingSpeed("{\"instructions\":\"true\",\"locale\":\"de\",\"ipd\":72.5,\"arcMinFont\":120,\"height\":1170,\"width\":2436,\"text\":{\"instructions\":[{\"id\":1,\"text\":\"Sagen Sie START, um zu beginnen.\"},{\"id\":2,\"text\":\"Als Nächstes wird Ihnen ein Beispieltext angezeigt.  Schauen Sie sich um und gewöhnen Sie sich an die Bewegung.\"},{\"id\":3,\"text\":\"Nun beginnt Ihre Aufgabe. Bitte lesen Sie den gesamten Text laut und deutlich von oben links ohne Unterbrechung vor.<br><br>Sagen Sie START, um zu beginnen.\"}],\"text\":{\"instructionWords\":\"drawer candidate puzzle palace cottage jazz examiner greeting guest cotton exams player wardrobe wool lorry flu suggestion ice politics tram power printer shoe roll spoon blouse volume basin fridge roof cage ground cake police immigration recipe throat rainforest ingredient title driver granddaughter digital excitement ambition brochure quality idea salt landscape detective apartment kilogramme full elevator singer snack buyer peak army ocean beard underwear goal video accommodation cheek drum sex region charity screen month fashion pitch reporter opinion programme flour toothpaste diagram kettle tune parking folder fare art middle conversation discotheque midnight paragraph frog hairdryer gallery trunk physics windy mystery question\",\"infoSignText\":\"Bitte sehen Sie in diese Richtung\",\"repeat\":\"Der Test wird nun mit Ihrem anderen Auge wiederholt.<br><br>Bitte lesen Sie erneut den gesamten Text laut und deutlich von oben links ohne Unterbrechung vor.\",\"endTestInstruction\":\"Sagen Sie TEST BEENDEN, um den Test zu beenden.\",\"end\":\"Der Test ist beendet. Bitte nehmen Sie die VR Brille ab.\"}}}");

            //Distortion Part 1 Test
            //de
            //OpenDistortion("{\"instructions\":\"true\",\"color\":{\"r\":150,\"g\":150,\"b\":150},\"part\":1,\"locale\":\"de\",\"dotSize\":6,\"focusSize\":300,\"ipd\":52.5,\"arcMinFont\":120,\"height\":1170,\"text\":{\"instructions\":[{\"id\":1,\"text\":\"Sagen Sie <i>START</i> um zu beginnen nachdem Sie die VR Brille aufgesetzt haben. \"},{\"id\":2,\"text\":\"In diesem Test werden Ihnen für sehr kurze Zeit Linien gezeigt.<br><br>Zuvor wird Ihnen immer ein Kreis angezeigt. Fokussieren Sie  dabei die Mitte, möglichst den Punkt. Es folgt ein Beispiel.\"},{\"id\":3,\"text\":\"Linien können <i>waagerecht</i> oder <i>senkrecht</i> sein. Viele Linien sind <i>gerade</i>, andere <i>gebogen</i>.<br><br>Als Nächstes sehen Sie ein Beispiel für eine gebogene Linie.\"},{\"id\":4,\"text\":\"Ihre Aufgabe ist es, zu sagen, welche Linie <i>gerade</i> ist und welche <i>gebogen.</i><br><br>Sagen Sie nach jeder Linie <i>JA</i> für <u>gerade</u> und <i>NEIN</i> für <u>gebogen</u>.<br><br>Es folgt ein weiteres Beispiel.\"},{\"id\":5,\"text\":\"Der Test startet nun.<br><br>Bitte antworten Sie auch, wenn Sie sich unsicher sind.\"}],\"text\":{\"question\":\"War die Linie gerade?\",\"understood\":\"Verstanden. Danke\",\"end\":\"Der Test ist beendet. Bitte nehmen Sie die VR Brille ab.\"}}}");
            //en
            //OpenDistortion("{ \"instructions\": \"true\", \"color\":{ \"r\": 150, \"g\": 150, \"b\": 150 },  \"part\":1,  \"locale\": \"en\",  \"dotSize\": 6,  \"focusSize\": 300,   \"ipd\": 52.5,  \"arcMinFont\": 120,\"height\":1170,\"text\": {    \"instructions\": [      {        \"id\": 1,        \"text\": \"Say START to begin <i>after</i> putting on the VR headset.\"      },      {        \"id\": 2,        \"text\": \"In this test you will be shown lines for a very short time.<br><br>Before that, you will always be shown a circle. Focus on the center, if possible the point. The following is an example.\"      },      {        \"id\": 3,        \"text\": \"Lines can be horizontal or vertical. Many lines are straight, others are curved. Next you will see an example of a curved line.\"      },      {        \"id\": 4,        \"text\": \"Your task is to say which line is straight and which is curved.<br><br>After each line, say YES for straight and NO for curved.<br><br>Here is another example.\"      },       {        \"id\": 5,        \"text\": \"The test will now start.<br><br>Please answer even if you are unsure.<br><br>followed by countdown\"      }    ],    \"text\": {      \"question\": \"Was the line straight?\",      \"understood\": \"Understood. Thanks.\",      \"end\": \"The test is finished. Please remove the VR headset.\"    }  }}");

            //Distortion Part 2 Dotted Instructions
            //de
            //OpenDistortionPart2("{  \"instructions\": \"true\", \"color\":{ \"r\": 150, \"g\": 150, \"b\": 150 },  \"part\":2,  \"locale\": \"de\",  \"dotSize\": 6,  \"focusSize\": 300,   \"ipd\": 52.5,  \"arcMinFont\": 120,\"height\":1170,\"text\": {    \"instructions\": [      {        \"id\": 1,        \"text\": \"Im Folgenden werden Ihnen weitere gerade und gebogene Linien angezeigt. Diese werden zusätzlich unterschiedlich gepunktet sein.<br><br>Als Nächstes sehen Sie ein Beispiel.\"      },      {        \"id\": 2,        \"text\": \"Ihr Test wird für mehrere Minuten fortgeführt.<br><br>Machen Sie eine Pause und schließen Sie Ihre Augen für einen Moment.<br><br>Es folgen weiteren Pausen.\"      },      {        \"id\": 3,        \"text\": \"Der Test geht nun weiter.<br><br>Beantworten Sie, ob die Linien  gerade waren mit JA oder NEIN.\"      }    ],    \"text\": {      \"question\": \"War die Linie gerade?\",      \"understood\": \"Verstanden. Danke\",      \"end\": \"Der Test ist beendet. Bitte nehmen Sie die VR Brille ab.\",      \"pause\": \"Machen Sie eine Pause und schließen Sie Ihre Augen für einen Moment.<br><br>Es folgen weiteren Pausen.\",      \"pauseEnd\": \"Der Test geht nun weiter.<br><br>Beantworten Sie, ob die Linien  gerade waren mit <i>JA</i> oder <i>NEIN</i>.\"    }  }}");
            //en
            //OpenDistortionPart2("{  \"instructions\": \"true\", \"color\":{ \"r\": 150, \"g\": 150, \"b\": 150 },  \"part\":2,  \"locale\": \"en\",  \"dotSize\": 6,  \"focusSize\": 300,   \"ipd\": 52.5,  \"arcMinFont\": 120,\"height\":1170,\"text\": {    \"instructions\": [      {        \"id\": 1,        \"text\": \"In the following you will see more straight and curved lines. These will additionally be dotted differently.<br><br>Next you will see an example.\"      },      {        \"id\": 2,        \"text\": \"Your test will continue for multiple minutes.<br><br>Take a break and close your eyes for a moment.<br><br>More pauses will follow.\"      },      {        \"id\": 3,        \"text\": \"The test now continues.<br><br>Answer whether the lines were straight with <i>YES</i> or <i>NO</i>.\"      }    ],    \"text\": {      \"question\": \"Was the line straight?\",      \"understood\": \"Understood. Thanks.\",      \"end\": \"The test is finished. Please remove the VR headset.\",      \"pause\": \"Take a break and close your eyes for a moment.<br><br>More pauses will follow.\",      \"pauseEnd\": \"The test now continues.<br><br>Answer whether the lines were straight with <i>YES</i> or <i>NO</i>.\"    }  }}");
        }

        /// <summary>
        /// Open Distortion Test Part 1 - from flutter
        /// </summary>
        /// <param name="message"></param>
        public void OpenDistortion(string message)
        {
            _appManager.TestDone = false;
            Debug.Log("Flutter OpenDistortion call - part 1: " + message);
            if (string.IsNullOrEmpty(message))
            {
                Debug.Log("No message from flutter");
            }
            else
            {
                //instruction parameters
                var distortionParameters = JsonUtility.FromJson<InstructionsTextDistortion>(
                    message
                );
                //use instructions
                _appManager.useInstructions = distortionParameters.instructions;
                //instruction part
                _appManager.distortionPart = distortionParameters.part;
                //use instruction
                _appManager.instructions = distortionParameters.instructions;
                //current language
                _appManager.activeLanguage = distortionParameters.locale;
                //user ipd
                _appManager.ipd = distortionParameters.ipd;
                //dot size
                _appManager.dotSize = distortionParameters.dotSize;
                //Instructions & additional text
                _appManager.instructionData = distortionParameters.text;
                //arcMinFont size
                _appManager.arcMinFont = distortionParameters.arcMinFont;
                //screen height
                _appManager.screenHeight = distortionParameters.height;
                //screen to lens distance
                _appManager.screenToLensDistance = distortionParameters.screenToLensDistance;
                //line color
                _appManager.distortionColor = new Color(
                    distortionParameters.color.r / 255f,
                    distortionParameters.color.g / 255f,
                    distortionParameters.color.b / 255f
                );
                //debug mode
                _appManager.debug = distortionParameters.debug;

                SetArcMinuteCalculationValues();
            }

            _appManager.CurrentActiveTest = AppManager.CurrentTest.Distortion;
            SceneManager.LoadScene("distortion");
        }

        /// <summary>
        /// Open Distortion Test - from flutter
        /// </summary>
        /// <param name="message"></param>
        public void OpenDistortionPart2(string message)
        {
            Debug.Log("OpenDistortionPart2 idle scene ");
            _appManager.TestDone = false;
            Debug.Log("OpenDistortion init Part 2: " + message);
            if (string.IsNullOrEmpty(message))
            {
                Debug.Log("No message from flutter");
            }
            else
            {
                //instruction parameters
                var distortionParameters = JsonUtility.FromJson<InstructionsTextDistortion>(
                    message
                );
                //use instructions
                _appManager.useInstructions = distortionParameters.instructions;
                //instruction part
                _appManager.distortionPart = distortionParameters.part;
                //use instruction
                _appManager.instructions = distortionParameters.instructions;
                //current language
                _appManager.activeLanguage = distortionParameters.locale;
                //user ipd
                _appManager.ipd = distortionParameters.ipd;
                //dot size
                _appManager.dotSize = distortionParameters.dotSize;
                //Instructions & additional text
                _appManager.instructionData = distortionParameters.text;
                //arcMinFont size
                _appManager.arcMinFont = distortionParameters.arcMinFont;
                //screen height
                _appManager.screenHeight = distortionParameters.height;
                //screen to lens distance
                _appManager.screenToLensDistance = distortionParameters.screenToLensDistance;
                //line color
                _appManager.distortionColor = new Color(
                    distortionParameters.color.r / 255f,
                    distortionParameters.color.g / 255f,
                    distortionParameters.color.b / 255f
                );
                //debug mode
                _appManager.debug = distortionParameters.debug;

                SetArcMinuteCalculationValues();
            }

            _appManager.CurrentActiveTest = AppManager.CurrentTest.Distortion;
            SceneManager.LoadScene("distortion");
        }

        /// <summary>
        /// Open Contrast Test - from flutter
        /// </summary>
        /// <param name="message"></param>
        public void OpenContrast(string message)
        {
            _appManager.TestDone = false;

            Debug.Log("Open Contrast call: " + message);
            if (string.IsNullOrEmpty(message))
            {
                Debug.Log("No message from flutter");
            }
            else
            {
                //instruction parameters
                var contrastParameters = JsonUtility.FromJson<Instructions>(message);
                //use instruction
                _appManager.instructions = contrastParameters.instructions;
                //current language
                _appManager.activeLanguage = contrastParameters.locale;
                //Instructions & additional text
                _appManager.instructionData = contrastParameters.text;
                //user ipd
                _appManager.ipd = contrastParameters.ipd;
                //arcMinFont size
                _appManager.arcMinFont = contrastParameters.arcMinFont;
                //screen height
                _appManager.screenHeight = contrastParameters.height;
                //screen to lens distance
                _appManager.screenToLensDistance = contrastParameters.screenToLensDistance;
                //Background color
                _appManager.backgroundColor = new Color(
                    contrastParameters.backgroundColor.r / 255f,
                    contrastParameters.backgroundColor.g / 255f,
                    contrastParameters.backgroundColor.b / 255f
                );
                //Font color
                _appManager.contrastColor = new Color(
                    contrastParameters.color.r / 255f,
                    contrastParameters.color.g / 255f,
                    contrastParameters.color.b / 255f
                );
                //debug mode
                _appManager.debug = contrastParameters.debug;

                SetArcMinuteCalculationValues();
            }

            _appManager.CurrentActiveTest = AppManager.CurrentTest.Contrast;
            SceneManager.LoadScene("contrast");
        }

        /// <summary>
        /// Open Reading Speed Test - from flutter
        /// </summary>
        /// <param name="message"></param>
        public void OpenReadingSpeed(string message)
        {
            _appManager.TestDone = false;
            Debug.Log("Open Reading speed call: " + message);

            if (string.IsNullOrEmpty(message))
            {
                Debug.Log("No message from flutter");
            }
            else
            {
                //instruction parameters
                var readingSpeedParameters = JsonUtility.FromJson<InstructionsReading>(message);
                //use instruction
                _appManager.instructions = readingSpeedParameters.instructions;
                //current language
                _appManager.activeLanguage = readingSpeedParameters.locale;
                //Instructions & additional text
                _appManager.instructionDataReading = readingSpeedParameters.text;
                //user ipd
                _appManager.ipd = readingSpeedParameters.ipd;
                //arcMinFont size
                _appManager.arcMinFont = readingSpeedParameters.arcMinFont;
                //screen height
                _appManager.screenHeight = readingSpeedParameters.height;
                //screen width
                _appManager.screenWidth = readingSpeedParameters.width;
                //screen to lens distance
                _appManager.screenToLensDistance = readingSpeedParameters.screenToLensDistance;
                //debug mode
                _appManager.debug = readingSpeedParameters.debug;

                SetArcMinuteCalculationValues();

                Debug.Log("-> " + _appManager.readingSpeedWords);
            }

            _appManager.CurrentActiveTest = AppManager.CurrentTest.ReadingSpeed;
            SceneManager.LoadScene("reading");
        }

        /// <summary>
        /// Open Unity Settings
        /// - will be obsolete -
        /// </summary>
        public void OpenSettings(string message)
        {
            if (string.IsNullOrEmpty(message))
            {
                Debug.Log("No message from flutter");
            }
            else
            {
                //settings parameters
                var settingsParameter = JsonUtility.FromJson<SettingsValue>(message);
                //screen height
                _appManager.screenHeight = settingsParameter.height;
                //user ipd
                _appManager.ipd = settingsParameter.ipd;
                //screen to lens distance
                _appManager.screenToLensDistance = settingsParameter.screenToLensDistance;
                //debug mode
                _appManager.debug = settingsParameter.debug;
                //current language
                _appManager.activeLanguage = settingsParameter.locale;
                //display text
                _appManager.angleValidationText = settingsParameter.text;
                //arcMinFont size
                _appManager.arcMinFont = settingsParameter.arcMinFont;

                SetArcMinuteCalculationValues();
            }

            _appManager.CurrentActiveTest = AppManager.CurrentTest.Settings;
            SceneManager.LoadScene("settings");
        }

        /// <summary>
        /// Open Unity IPD Setup
        /// </summary>
        /// <param name="message"></param>
        public void OpenIpd(string message)
        {
            _appManager.TestDone = false;

            Debug.Log("Open ipd call: " + message);
            if (string.IsNullOrEmpty(message))
            {
                Debug.Log("No message from flutter");
            }
            else
            {
                //instruction parameters
                var ipdParameters = JsonUtility.FromJson<InstructionIpd>(message);
                //use instruction
                _appManager.instructions = ipdParameters.instructions;
                //current language
                _appManager.activeLanguage = ipdParameters.locale;
                //Instructions & additional text
                _appManager.instructionDataIpd = ipdParameters.text;
                //arcMinFont size
                _appManager.arcMinFont = ipdParameters.arcMinFont;
                //arcMinSize
                _appManager.arcMinSize = ipdParameters.arcMinSize;
                //screen height
                _appManager.screenHeight = ipdParameters.height;
                //screen to lens distance
                _appManager.screenToLensDistance = ipdParameters.screenToLensDistance;
                //debug mode
                _appManager.debug = ipdParameters.debug;

                SetArcMinuteCalculationValues();
            }

            _appManager.CurrentActiveTest = AppManager.CurrentTest.Ipda;
            SceneManager.LoadScene("ipd");
        }

        /// <summary>
        /// Close Unity - Message to Flutter
        /// </summary>
        private void UnityModulClose()
        {
            //Reset unity module
            _appManager.ResetUnityModule();

            Debug.Log("Send Flutter Close");
            UnityMessage msg = new() { name = "Close", data = null };
            _unityMessageManager.SendMessageToFlutter(msg);
        }

        private void SetArcMinuteCalculationValues()
        {
            _appManager.verticalAngle = CalculateVerticalAngle();
            _appManager.arcMinutesPerPixel = CalculateArcMinutesPerPixel();
        }

        private double CalculateVerticalAngle()
        {
            return Math.Atan(
                    _appManager.GetScreenHeightInMm()
                        / (_appManager.screenToLensDistance * (1 + _appManager.magnifyingFactor))
                )
                * (180 / Math.PI)
                * 2;
        }

        private double CalculateArcMinutesPerPixel()
        {
            return _appManager.verticalAngle * 60 / _appManager.screenHeight;
        }
    }

    /// <summary>
    /// Instruction
    /// </summary>
    [Serializable]
    public class Instruction
    {
        public int id;
        public string text;
    }

    [Serializable]
    public class InstructionText
    {
        public List<Instruction> instructions;
        public TextData text;
    }

    [Serializable]
    public class TextData
    {
        public string question;
        public string understood;
        public string end;
        public string pause;
        public string pauseEnd;
    }

    public class SettingsValue
    {
        public int height;
        public float ipd;
        public float screenToLensDistance;
        public bool debug;
        public string locale;
        public string text;
        public double arcMinFont;
    }

    //contrast - distortion test instruction
    [Serializable]
    public class InstructionsTextDistortion
    {
        public bool instructions;
        public int part;
        public ColorValue color;
        public string locale;
        public float screenToLensDistance;
        public float dotSize;
        public float focusSize;
        public int height;
        public float ipd;
        public int arcMinFont;
        public InstructionText text;
        public bool debug;
    }

    //contrast - distortion test instruction
    [Serializable]
    public class Instructions
    {
        public bool instructions;
        public ColorValue backgroundColor;
        public ColorValue color;
        public string locale;
        public float screenToLensDistance;
        public float dotSize;
        public int height;
        public float ipd;
        public int arcMinFont;
        public InstructionText text;
        public bool debug;
    }

    //ipd - instruction
    [Serializable]
    public class InstructionIpd
    {
        public bool instructions;
        public string locale;
        public float screenToLensDistance;
        public int arcMinFont;
        public int arcMinSize;
        public int height;
        public InstructionTextIpd text;
        public bool debug;
    }

    [Serializable]
    public class InstructionTextIpd
    {
        public List<Instruction> instructions;
        public TextDataIpd text;
    }

    [Serializable]
    public class TextDataIpd
    {
        public string question;
        public string understood;
        public string text;
        public string end;
    }

    //reading speed - instruction
    [Serializable]
    public class InstructionsReading
    {
        public bool instructions;
        public string locale;
        public float screenToLensDistance;
        public int arcMinFont;
        public int height;
        public int width;
        public float ipd;
        public InstructionTextReading text;
        public bool debug;
    }

    [Serializable]
    public class InstructionTextReading
    {
        public List<Instruction> instructions;
        public TextDataReading text;
    }

    [Serializable]
    public class TextDataReading
    {
        public string instructionWords;
        public string infoSignText;
        public string repeat;
        public string endTestInstruction;
        public string processing;
        public string error;
        public string end;
    }
}
