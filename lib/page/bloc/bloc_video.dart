import 'dart:io';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class BlocVideo {
  var cameras = BehaviorSubject<List<CameraDescription>>();
  var selectCamera = BehaviorSubject<bool>();
  var videoPath = BehaviorSubject<File>();
  var cameraOn = BehaviorSubject<int>();
  var videoOn = BehaviorSubject<bool>();
  var playPause = BehaviorSubject<bool>.seeded(false);
  var timeVideo = BehaviorSubject<double>.seeded(0.0);
  FloatingActionButtonLocation fabLocation =
      FloatingActionButtonLocation.centerDocked;

  CameraController controllCamera;
  VideoPlayerController controllVideo;

  Future getCameras() async {
    await availableCameras().then((lista) {
      cameras.sink.add(lista);
    }).catchError((e) {
      print("ERROR CAMERA: $e");
    });
  }

  Future<String> takePicture() async {
    if (!controllCamera.value.isInitialized) {
      print("selecionado camera");
      return null;
    }
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    if (controllCamera.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

    try {
      await controllCamera.takePicture(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    return filePath;
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    selectCamera.sink.add(null);
    if (controllCamera != null) {
      await controllCamera.dispose();
    }
    controllCamera =
        CameraController(cameraDescription, ResolutionPreset.medium);
    controllCamera.addListener(() {
      if (controllCamera.value.hasError) selectCamera.sink.add(false);
    });

    await controllCamera.initialize().then((value) {
      selectCamera.sink.add(true);
    }).catchError((e) {
      print(e);
    });
  }

  void changeCamera() {
    var list = cameras.value;

    if (list.length == 2) {
      if (controllCamera.description.name == "0") {
        onNewCameraSelected(list[1]);
        cameraOn.sink.add(1);
      } else {
        onNewCameraSelected(list[0]);
        cameraOn.sink.add(0);
      }
    }
  }

  void deleteVideo() {
    var dir = new Directory(videoPath.value.path);
    dir.deleteSync(recursive: true);
    videoPath.sink.add(null);
    videoOn.sink.add(null);
  }

  //Recording video

  void onVideoRecordButtonPressed() {
    fabLocation = FloatingActionButtonLocation.centerFloat;
    startVideoRecording().then((String filePath) {
      if (filePath != null) videoPath.sink.add(File(filePath));
    });
  }

  void onStopButtonPressed() {
    fabLocation = FloatingActionButtonLocation.centerDocked;
    stopVideoRecording().then((_) {
      //AQUI VC PAUSA O VIDEO
    });
  }

  Future<String> startVideoRecording() async {
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controllCamera.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      await controllCamera.startVideoRecording(filePath);
    } on CameraException catch (e) {
      print(e);
      return null;
    }
    videoOn.sink.add(false);
    /*  Timer.periodic(Duration(seconds: 1), (time) {
      var value = timeVideo.value * 60;
      if (time.tick == 63 || videoOn.value == true) {
        onStopButtonPressed();
        timeVideo.sink.add(0);
        time.cancel();
      } else {
        value++;
        print("valor: ${value / 60}");
        timeVideo.sink.add(value / 60);
      }
    });*/

    return filePath;
  }

  Future<void> stopVideoRecording() async {
    if (!controllCamera.value.isRecordingVideo) {
      return null;
    }

    try {
      await controllCamera.stopVideoRecording();
    } on CameraException catch (e) {
      print(e);
      return null;
    }

    _startVideoPlayer();
    if (controllVideo != null) videoOn.sink.add(true);
  }

  Future<void> _startVideoPlayer() async {
    controllVideo = VideoPlayerController.file(videoPath.value);

    await controllVideo.initialize();
    await controllVideo.setLooping(true);
    await controllVideo.play();
    playPause.sink.add(true);
  }

  void dispose() {
    cameras.close();
    controllCamera.dispose();
    controllVideo.dispose();
    selectCamera.close();
    videoPath.close();
    cameraOn.close();
    videoOn.close();
    timeVideo.close();
    playPause.close();
  }
}
