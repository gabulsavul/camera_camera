import 'dart:developer';
import 'dart:io';
import 'package:flutter_better_camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class BlocCamera {
  var cameras = BehaviorSubject<List<CameraDescription>>();
  var selectCamera = BehaviorSubject<bool>();
  var imagePath = BehaviorSubject<File>();
  var cameraOn = BehaviorSubject<int>();

  CameraController controllCamera;

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

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      imagePath.sink.add(File(filePath));
    });
  }

  Future<Null> onNewCameraSelected(CameraDescription cameraDescription) async {
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
      debugPrint('####### ERROR ####### ');
      debugPrint(e);
      debugPrint('############## ');
    });

    return;
  }

  Future<Null> changeCamera() async {
    try {
      var list = cameras.value;

      debugPrint('LOGX: ${list.length}');
      if (list.length > 1) {
        var listCameraFront = list
            .where((val) => val.lensDirection == CameraLensDirection.front)
            .toList();

        var listCameraBack = list
            .where((val) => val.lensDirection == CameraLensDirection.back)
            .toList();

        if (controllCamera.description.lensDirection ==
            CameraLensDirection.back) {
          debugPrint('LOGX: Frontal selected');
          await onNewCameraSelected(listCameraFront[0]);
          cameraOn.sink.add(list.indexOf(listCameraFront[0]));
        } else {
          debugPrint('LOGX: Back selected');
          await onNewCameraSelected(listCameraBack[0]);
          cameraOn.sink.add(list.indexOf(listCameraBack[0]));
        }
      }
      return;
    } catch (e) {
      debugPrint('####### ERROR ####### ');
      debugPrint(e);
      debugPrint('############## ');
    }
  }

  void deletePhoto() {
    var dir = new Directory(imagePath.value.path);
    dir.deleteSync(recursive: true);
    imagePath.sink.add(null);
  }

  void dispose() {
    cameras.close();
    controllCamera.dispose();
    selectCamera.close();
    imagePath.close();
    cameraOn.close();
  }

  /* Future<Null> cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
      toolbarTitle: "Editar",
      toolbarColor: Colors.black,
      
      sourcePath: imagePath.value.path,
      ratioX: 1.0,
      ratioY: 1.0,
      maxWidth: 512,
      maxHeight: 512,
    );

    if (croppedFile != null) imagePath.sink.add(croppedFile);
  }*/
}
