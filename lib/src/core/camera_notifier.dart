import 'package:camera/camera.dart';
import 'package:camera_camera/src/presentation/controller/camera_camera_controller.dart';
import 'package:camera_camera/src/shared/entities/camera_mode.dart';
import 'package:camera_camera/src/shared/entities/camera_side.dart';
import 'package:flutter/material.dart';

import 'camera_service.dart';
import 'camera_status.dart';

class CameraNotifier extends ChangeNotifier {
  CameraService service;
  void Function(String value) onPath;
  CameraSide cameraSide;
  List<FlashMode> flashModes;
  CameraCameraController? _cameraController;
  bool enableAudio;
  final CameraMode mode;

  CameraNotifier({
    required this.service,
    required this.onPath,
    required this.cameraSide,
    required this.flashModes,
    required this.mode,
    this.enableAudio = false,
  });

  //STREAM STATUS
  CameraStatus _status = CameraStatusEmpty();

  CameraStatus get status => _status;
  set status(CameraStatus status) {
    _status = status;
    notifyListeners();
  }

  listen(Function(CameraStatus) onListen) {
    addListener(() {
      onListen(status);
    });
  }

  void init() async {
    await getAvailableCameras();
    status.when(
        orElse: () {},
        success: (_) {
          changeCamera();
        });
  }

  Future<void> getAvailableCameras() async {
    status = CameraStatusLoading();
    try {
      final cameras = await service.getCameras();
      if (cameraSide == CameraSide.back || cameraSide == CameraSide.front) {
        cameras.removeWhere((e) => e.lensDirection == cameraSide.lensDirection);
      }
      status = CameraStatusSuccess(cameras: cameras);
      return;
    } on CameraException catch (e) {
      status = CameraStatusFailure(message: e.description ?? "", error: e);
      return;
    }
  }

  void changeCamera([int? specificIndex]) {
    if (status is CameraStatusSuccess) {
      final cameras = status.success.cameras;
      status = CameraStatusSelected(cameras: cameras, indexSelected: 0);
    } else if (status is CameraStatusPreview) {
      final cameras = status.preview.cameras;
      final index = status.preview.indexSelected;
      var indexSelected = 0;
      if (index + 1 < cameras.length) {
        indexSelected = index + 1;
      }
      status = CameraStatusSelected(
          cameras: cameras, indexSelected: specificIndex ?? indexSelected);
    } else {
      throw "CAMERA_CAMERA ERROR: Invalid changeCamera";
    }
  }

  void startPreview(
    ResolutionPreset resolutionPreset, {
    ValueChanged<CameraImage>? listenImage,
  }) async {
    await _cameraController?.dispose();
    await Future.delayed(Duration(milliseconds: 800));

    final cameras = status.selected.cameras;
    final indexSelected = status.selected.indexSelected;
    _cameraController = CameraCameraController(
      cameraDescription: cameras[indexSelected],
      resolutionPreset: resolutionPreset,
      onPath: onPath,
      flashModes: flashModes,
      enableAudio: enableAudio,
      cameraMode: mode,
    );
    status = CameraStatusPreview(
        controller: _cameraController!,
        cameras: cameras,
        indexSelected: indexSelected);

    if (listenImage != null) {
      try {
        _cameraController!.addStreamImage(listenImage);
      } catch (e) {
        status = CameraStatusFailure(message: e.toString());
      }
    }
  }

  void dispose() {
    super.dispose();
  }
}
