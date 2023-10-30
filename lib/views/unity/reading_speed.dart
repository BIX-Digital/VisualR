/*
 * Copyright 2023 BI X GmbH
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:visualr_app/common/providers/prefs.dart';
import 'package:visualr_app/main.dart';
import 'package:visualr_app/meta.dart';
import 'package:visualr_app/reading_speed/models/step.dart';
import 'package:visualr_app/reading_speed/models/summary.dart';
import 'package:visualr_app/reading_speed/services/service.dart';
import 'package:visualr_app/views/unity/unity_view.dart';
import 'package:visualr_app/widgets/unity_transition.dart';
import 'package:whisper_dart/scheme/scheme.dart';
import 'package:whisper_dart/whisper_dart.dart';

Future<void> transcribeFunction(WhisperIsolateData whisperIsolateData) async {
  final Whisper whisper = Whisper(
    whisperLib: "whisper_dart.so",
  );
  final audio = File(whisperIsolateData.path);
  if (await audio.exists()) {
    final res = await whisper.request(
      whisperRequest: WhisperRequest.fromWavFile(
        audio: File(whisperIsolateData.path),
        model: whisperIsolateData.model,
        language: whisperIsolateData.language,
      ),
    );
    await File(whisperIsolateData.path).delete();
    whisperIsolateData.mainSendPort.send(res);
  } else {
    whisperIsolateData.mainSendPort.send('Not processing because of error');
  }
}

class WhisperIsolateData {
  final SendPort mainSendPort;
  final SendPort secondSendPort;
  final String path;
  final String language;
  final File model;
  WhisperIsolateData({
    required this.mainSendPort,
    required this.secondSendPort,
    required this.path,
    required this.model,
    required this.language,
  });
}

@RoutePage()
class UnityReadingSpeedPage extends UnityViewPage {
  const UnityReadingSpeedPage({
    super.key,
    super.showInstructions = true,
    super.unityView = UnityView.readingSpeed,
  });

  @override
  State<UnityViewPage> createState() => _UnityReadingSpeedPageState();
}

class _UnityReadingSpeedPageState extends UnityViewPageState {
  final record = Record();
  ReadingSpeedTestService? svc;
  late final Prefs prefs;
  EyeEnum eye = EyeEnum.right;
  int iterationCounter = 0;
  Exception? firstPartException;

  String clipFilePath = '';
  int fileIndex = 1;
  late String result;

  @override
  void initState() {
    getApplicationDocumentsDirectory().then((documents) {
      clipFilePath = '${documents.path}/clip-$fileIndex.wav';
    });
    super.initState();
  }

  void startRecorder() {
    record.start(
      path: clipFilePath,
      encoder: AudioEncoder.pcm16bit,
      samplingRate: 16000,
    );
  }

  Future<File?> copyAssetToLocal(String path) async {
    try {
      final content = await rootBundle.load("assets/models/$path");
      final directory = await getApplicationDocumentsDirectory();
      final file = File("${directory.path}/$path");
      if (!await file.exists()) {
        file.writeAsBytesSync(content.buffer.asUint8List());
      }
      return file;
    } catch (e) {
      debugPrint('Error');
    }
    return null;
  }

  void closeView() {
    if (!prefs.presentation) {
      final Set<String> finishedTests = prefs.finishedTests;
      finishedTests.add(widget.unityView.toShortString());
      prefs.finishedTests = finishedTests;
    }
    unityClose!.status =
        prefs.presentation ? UnityTestState.error : UnityTestState.success;
    unityWidgetController!.postMessage(
      'unityModuleReading',
      'ReadingSpeedEnd',
      '',
    );
  }

  void closeViewWithError(String error) {
    debugPrint(error);
    unityClose!.status = UnityTestState.error;
    unityWidgetController!.postMessage(
      'unityModuleReading',
      'ReadingSpeedError',
      '',
    );
  }

  Future<void> transcribeFile(File audio) async {
    iterationCounter++;
    final ReceivePort receivePort = ReceivePort();

    final ReceivePort secondReceivePort = ReceivePort();
    receivePort.listen((message) async {
      message as WhisperResponse;
      result = message.toString();
      if (svc != null) {
        final result = ReadingSpeedWhisperResult.fromJson(
          message.toJson() as Map<String, dynamic>,
        );
        if (firstPartException != null) {
          closeViewWithError(firstPartException.toString());
          return;
        }
        try {
          final ReadingSpeedSummary? summary =
              await svc!.manager.processWhisperResult(result);
          if (summary == null) return;
          if (!prefs.presentation) {
            objectBox.readingSpeed.save(
              locale: prefs.locale,
              user: prefs.user,
              summary: summary,
              steps: svc!.manager.steps,
            );
          }
          closeView();
        } catch (e) {
          firstPartException = e as Exception;
          if (iterationCounter == 2) {
            closeViewWithError(e.toString());
          }
        }
      }
    });
    final String modelName =
        (prefs.locale == 'en') ? 'ggml-base.en.bin' : 'ggml-base.bin';
    final model = await copyAssetToLocal(modelName);
    final WhisperIsolateData whisperIsolateDate = WhisperIsolateData(
      mainSendPort: receivePort.sendPort,
      secondSendPort: secondReceivePort.sendPort,
      path: audio.path,
      model: model!,
      language: prefs.locale,
    );
    Isolate.spawn(transcribeFunction, whisperIsolateDate);
  }

  Future<void> stopRecorder() async {
    await record.stop().then((value) {
      transcribeFile(File(clipFilePath));
      setState(() {
        fileIndex++;
        getTemporaryDirectory().then((documents) {
          clipFilePath = '${documents.path}/clip-$fileIndex.wav';
        });
      });
    });
  }

  @override
  void onUnityCreated(
    UnityWidgetController controller,
    Prefs prefs,
    BuildContext context,
  ) {
    screenBrightnessService.setBrightness();
    this.prefs = prefs;
    unityWidgetController = controller;
    setUnityCloseMessage();
    localizedTextService
        .getLocalizedText(widget.unityView.toShortString(), prefs)
        .then((localizedText) {
      unityWidgetController!.postMessage(
        'unityModuleIdle',
        'OpenReadingSpeed',
        '''
          {
            "arcMinFont": $arcMinFont,
            "debug": ${prefs.debug},
            "height": ${View.of(context).physicalSize.height},
            "instructions": "${widget.showInstructions}",
            "ipd": ${prefs.ipd},
            "locale": "${prefs.locale}",
            "screenToLensDistance": ${prefs.screenToLensDistance},
            "text": $localizedText,
            "width": ${View.of(context).physicalSize.width}
          }
        ''',
      );
    });
    Future.delayed(Duration.zero, () async {
      svc = await ReadingSpeedTestService.startService(prefs);
    });
  }

  @override
  Future<void> onUnityMessage(
    UnityMessage message,
    BuildContext context, [
    Prefs? prefs,
  ]) async {
    switch (message.name) {
      case 'StartRecord':
        startRecorder();
      case 'EndRecord':
        stopRecorder();
      case 'Close':
        screenBrightnessService.resetBrightness();
        closeUnity(context);
      case 'ReadingReady':
        // clipRecord();
        final newEye = (eye == EyeEnum.left) ? EyeEnum.right : EyeEnum.left;
        setState(() {
          eye = newEye;
        });
        final ReadingSpeedTestStep step =
            await svc!.manager.createTestEvent(newEye);
        unityWidgetController!.postMessage(
          'unityModuleReading',
          'ReadingTest',
          '{"words": "${step.words}"}',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<Prefs>(
      builder: (context, prefs, child) => UnityWidget(
        onUnityCreated: (UnityWidgetController controller) =>
            onUnityCreated(controller, prefs, context),
        onUnityMessage: (dynamic message) {
          message = cleanUnityMessage(message.toString());
          onUnityMessage(
            UnityMessage.fromJson(
              jsonDecode(cleanUnityMessage(message.toString()))
                  as Map<String, dynamic>,
            ),
            context,
            prefs,
          );
        },
        enablePlaceholder: showTransition,
        placeholder: const UnityTransition(),
      ),
    );
  }
}
