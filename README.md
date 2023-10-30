# VisualR

VisualR is a VR-based smartphone application to perform vision function tests. It consists of a smartphone app that is used together with a simple VR headset.

The app includes novel tests for metamorphopsia, contrast sensitivity and reading speed that can be performed by following simple instructions and providing verbal responses to visual cues, without the need for expert supervision. The smartphone handles all data processing and image display; the app does not require an internet connection, and all data is stored locally and owned by the user. VisualR is currently optimized for iOS phones, particularly the iPhone 13.

More details about VisualR can be found in [Sozzi et al. (MedRxiv 2023)](https://www.medrxiv.org/content/10.1101/2023.10.27.23297661v1).

**VisualR is a prototype tool for performing visual tests. It is not intended to be used as a medical device or to diagnose, treat, or prevent any disease or condition.**

## Development

The app was built using Flutter and Unity and makes use of [`flutter_unity_widget`](https://github.com/juicycleff/flutter-unity-view-widget) to embed the Unity app as a module into the Flutter application.

### Repository structure

All relevant source files for the Flutter application can be found in `lib/`. The `lib` directory is divided into the following domains:

| Domain            | Usage  |
|-------------------|--------|
| `common/`         | All classes and services used my multiple parts of the app   |
| `contrast/`       | All classes and services used by the "contrast sensitivity" test  |
| `distortion/`     | All classes and services used by the "distortion" test  |
| `ipda/`           | All classes and services used by the interpupillary distance adjustment |
| `reading_speed/`  | All classes and services used by the "reading speed" test  |

Each domain itself is then divided again into the following subdirectories (if applicable):

| Directory   | Usage  |
|-------------|--------|
| `database/` | Classes used for storing and accessing data |
| `models/`   | Classes that describe models used by the respective domain for data storage and processing  |
| `providers/`| All provider classes  |
| `services/` | All services commonly used or by the respective visual test  |

The code for the embedded Unity application can be found in `/unity/visualr_unity/`. All audio files, fonts and icons used during the visual tests are inside `Assets/Artworks/`, while the scripts for running and displaying the visual tests are in `Assets/Scripts/`.
Here the scripts are separated into different namespaces depending on their usage, e.g. `ArcMinuteCalculation`, `Contrast` or `Ui`.

### Visual test logic

All logic for each visual test resides inside the Flutter application and is similar across all visual tests.

For each visual test there are at least three classes in charge of the logic and data flow:

1. The visual test specific implementation of the abstract class `UnityViewPage`, which is responsible for rendering the Unity content and sending and receiving messages to and from the Unity module.

2. The visual test service responsible for the communication between the `UnityViewPage` and the visual test's manager class.

3. The visual test's manager class, which is in charge of creating new test events, keeping track of the user's answers and storing the test results as soon as the test is finished.

For some visual tests there are additional services needed for the creation of test events.

In more detail the flow to create new test events will look like the following:

Inside `views/unity/` there is an implementation of the `UnityViewPage` that makes use of the `UnityWidget` for each visual test.
The `UnityWidget` is wrapped inside a `StreamBuilder` which takes care of feeding the Unity module with data for the next test step. When there is a new test step to be created, an event is triggered within the respective service of the visual test, e.g. the `ContrastService`, which itself will call `createNextTestEvent()` of the respective manager class, e.g. `ContrastManager`.

While the logic for creating a new test event will look differently for each visual test, the result will always be that a new event will be added to the stream used for the `StreamBuilder` widget which will take care of sending the newly created test event to Unity.

An example flow to create a new test step of the contrast test looks like this (although it will be the same for the other visual tests):

`UnityContrastPage` &rarr; `ContrastService` &rarr; `ContrastManager` &rarr; `ContrastService` &rarr; `UnityContrastPage`

After the test is finished (indicated by `createTestEvent()` returning `null`) the manager will take care of creating the test results and storing them in the database.

## Building

Before being able to build the application using Xcode or the Flutter CLI, the following steps need to be done.

### Getting required assets

The following assets need to be downloaded and added to the repository.

#### Whisper speech recognition models

VisualR uses [Whisper](https://openai.com/research/whisper) to transcribe audio files. The models used are the multilingual base model and the English base model, that need to be placed in `/assets/models`. The models can be downloaded in the required format using [the download tool](https://github.com/ggerganov/whisper.cpp/blob/master/models/README.md) provided by [whisper.cpp](https://github.com/ggerganov/whisper.cpp), the C++ port of Whisper.

#### Vosk speech recognition models

In addition to Whisper, VisualR also relies on the speech recognition engine [Vosk](https://alphacephei.com/vosk/) for the voice commands inside the app. The app uses the small German model and the small English model, both in version 0.15, but we expect that later versions of the models will work the same way. They can be downloaded from the [official list of models compatible with the Vosk-API](https://alphacephei.com/vosk/models). Make sure to download `vosk-model-small-en-us-0.xx` and `vosk-model-small-de-0.xx`.

The contents of the downloaded .zip files then need to be placed in `/unity/visualr_unity/Assets/StreamingAssets/LanguageModels/de-DE` and `/unity/visualr_unity/Assets/StreamingAssets/LanguageModels/en-US` respectively.

#### Unity assets from the Unity Asset Store

This project relies on some assets from the [Unity Asset Store](https://assetstore.unity.com). Most are free-of-charge while others have a cost (indicated by ($)).
All assets listed below need to be downloaded from the asset store and added to the unity project.

- [Circle Generator (v1.0.2)](https://assetstore.unity.com/packages/tools/gui/circle-generator-213175)
- [DOTween (HOTween v2) (v1.2.745)](https://assetstore.unity.com/packages/tools/animation/dotween-hotween-v2-27676)
- [Lean GUI Shapes (v2.0.2)](https://assetstore.unity.com/packages/tools/gui/lean-gui-shapes-69366) ($)
- [Recognissimo: Offline Speech Recognition (v2.0.6)](https://assetstore.unity.com/packages/tools/audio/recognissimo-offline-speech-recognition-203101) ($) (*)
- [StrangeIoC (v0.7.0)](https://assetstore.unity.com/packages/tools/strangeioc-9267)

(*) While VisualR is using the paid asset Recognissimo to do offline speech recognition via Vosk, one might be able to replace it by [one of the sample projects provided by AlphaCephei](https://alphacephei.com/vosk/unity).
However, this was not tested and might not work the same way as Recognissimo does.

#### TextMesh Pro

VisualR uses [TextMesh Pro](https://docs.unity3d.com/Manual/com.unity.textmeshpro.html) to render text. Even though TextMesh Pro is shipped together with the Unity Editor it still needs to be added to project.
This can be done by opening `unity/visualr-unity/` in the unity Editor and using the "Window &rarr; TextMeshPro &rarr; Import TMP Essential Resources" menu option.

### Getting Flutter packages

All packages needed to build VisualR can be downloaded by running the following command from the root of the repository:

```bash
flutter pub get
```

### Generating needed files

Some files used for the database models and routes of the app need to be generated via [`build_runner`](https://pub.dev/packages/build_runner).
This can be done by running the following command:

```bash
 dart run build_runner build --delete-conflicting-outputs
```

### Export Unity project

In order to build and export the Unity project, one needs to open `/unity/visualr_unity/` in the Unity Editor. After setting the build platform to iOS within the Build Settings of the Unity Editor, one can use the "Export iOS" option from the "Flutter" context within the menu bar. This will build the Unity application to `ios/UnityLibrary/`.

### Set Signing & Capabilities

One needs to set the "Signing & Capabilities" within Xcode to their respective development team and (optionally) certificates. In addition, a unique bundle identifier needs to be provided.
To do that one needs to open `ios/Runner.xcworkspace/` in Xcode, choose "Runner" on the left side menu and navigate to the "Signing & Capabilities" tab.

### Install Pods via CocoaPods

Flutter uses [CocoaPods](https://cocoapods.org), which can either be installed via Ruby

```bash
sudo gem install cocoapods
```

or via brew

```bash
brew install cocoapods
```

After CocoaPods has successfully been installed, one needs to run `pod install` from within the `ios/` directory.