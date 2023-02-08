import 'package:camera/camera.dart';
import 'package:camera_camera/src/shared/entities/camera.dart';
import 'package:camera_camera/src/shared/entities/camera_mode.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_camera_status.dart';

class CameraCameraController {
  ResolutionPreset resolutionPreset;
  CameraDescription cameraDescription;
  CameraMode cameraMode;
  List<FlashMode> flashModes;
  void Function(String path) onPath;
  bool enableAudio;
  bool _hasListenImageStream = false;
  late CameraController _controller;

  final statusNotifier = ValueNotifier<CameraCameraStatus>(CameraCameraEmpty());
  CameraCameraStatus get status => statusNotifier.value;
  set status(CameraCameraStatus status) => statusNotifier.value = status;

  CameraCameraController({
    required this.resolutionPreset,
    required this.cameraDescription,
    required this.flashModes,
    required this.onPath,
    this.cameraMode = CameraMode.ratio16s9,
    this.enableAudio = false,
  }) {
    _controller = CameraController(cameraDescription, resolutionPreset,
        enableAudio: enableAudio);
  }

  double get aspectRatio => _controller.value.aspectRatio;

  void init() async {
    status = CameraCameraLoading();
    try {
      await _controller.initialize();
      var maxZoom;
      var minZoom;
      var maxExposure;
      var minExposure;
      if (kIsWeb == false) {
        maxZoom = await _controller.getMaxZoomLevel();
        minZoom = await _controller.getMinZoomLevel();
        maxExposure = await _controller.getMaxExposureOffset();
        minExposure = await _controller.getMinExposureOffset();
      }
      try {
        await _controller.setFlashMode(FlashMode.off);
      } catch (e) {
        status = CameraCameraFailure(
          message: e.toString(),
        );
      }

      status = CameraCameraSuccess(
          camera: Camera(
              maxZoom: maxZoom,
              minZoom: minZoom,
              zoom: minZoom,
              maxExposure: maxExposure,
              minExposure: minExposure,
              flashMode: FlashMode.off));
    } on CameraException catch (e) {
      status = CameraCameraFailure(message: e.description ?? "", exception: e);
    }
  }

  void setFlashMode(FlashMode flashMode) async {
    final camera = status.camera.copyWith(flashMode: flashMode);
    status = CameraCameraSuccess(camera: camera);
    _controller.setFlashMode(flashMode);
  }

  void changeFlashMode() async {
    final flashMode = status.camera.flashMode;
    final list = flashModes;
    var index = list.indexWhere((e) => e == flashMode);
    if (index + 1 < list.length) {
      index++;
    } else {
      index = 0;
    }
    setFlashMode(list[index]);
  }

  void setExposureMode(ExposureMode exposureMode) async {
    final camera = status.camera.copyWith(exposureMode: exposureMode);
    status = CameraCameraSuccess(camera: camera);
    _controller.setExposureMode(exposureMode);
  }

  void setFocusPoint(Offset focusPoint) async {
    final camera = status.camera.copyWith(focusPoint: focusPoint);
    status = CameraCameraSuccess(camera: camera);
    _controller.setFocusPoint(focusPoint);
  }

  void setExposurePoint(Offset exposurePoint) async {
    final camera = status.camera.copyWith(exposurePoint: exposurePoint);
    status = CameraCameraSuccess(camera: camera);
    _controller.setExposurePoint(exposurePoint);
  }

  void setExposureOffset(double exposureOffset) async {
    final camera = status.camera.copyWith(exposureOffset: exposureOffset);
    status = CameraCameraSuccess(camera: camera);
    _controller.setExposureOffset(exposureOffset);
  }

  void setZoomLevel(double zoom) async {
    if (status.camera.zoom != null &&
        status.camera.minZoom != null &&
        status.camera.maxZoom != null) {
      if (zoom != 1) {
        var cameraZoom = double.parse(((zoom)).toStringAsFixed(1));
        if (cameraZoom >= status.camera.minZoom! &&
            cameraZoom <= status.camera.maxZoom!) {
          final camera = status.camera.copyWith(zoom: cameraZoom);
          status = CameraCameraSuccess(camera: camera);
          await _controller.setZoomLevel(cameraZoom);
        }
      }
    }
  }

  void zoomChange() async {
    if (status.camera.zoom != null &&
        status.camera.minZoom != null &&
        status.camera.maxZoom != null) {
      var zoom = status.camera.zoom!;
      if (zoom + 0.5 <= status.camera.maxZoom!) {
        zoom += 0.5;
      } else {
        zoom = 1.0;
      }
      final camera = status.camera.copyWith(zoom: zoom);
      status = CameraCameraSuccess(camera: camera);
      await _controller.setZoomLevel(zoom);
    }
  }

  void zoomIn() async {
    if (status.camera.zoom != null &&
        status.camera.minZoom != null &&
        status.camera.maxZoom != null) {
      var zoom = status.camera.zoom!;
      if (zoom + 1 <= status.camera.maxZoom!) {
        zoom += 1;

        final camera = status.camera.copyWith(zoom: zoom);
        status = CameraCameraSuccess(camera: camera);
        await _controller.setZoomLevel(zoom);
      }
    }
  }

  void zoomOut() async {
    if (status.camera.zoom != null &&
        status.camera.minZoom != null &&
        status.camera.maxZoom != null) {
      var zoom = status.camera.zoom!;
      if (zoom - 1 >= status.camera.minZoom!) {
        zoom -= 1;

        final camera = status.camera.copyWith(zoom: zoom);
        status = CameraCameraSuccess(camera: camera);
        await _controller.setZoomLevel(zoom);
      }
    }
  }

  void takePhoto() async {
    try {
      if (_controller.value.isInitialized &&
          !_controller.value.isTakingPicture) {
        final file = await _controller.takePicture();

        onPath(file.path);
      }
    } catch (e) {
      print(e);
    }
  }

  Widget buildPreview() => _controller.buildPreview();

  void addStreamImage(ValueChanged<CameraImage> onListen) {
    if (kIsWeb) {
      throw CameraCameraFailure(
          message: "Stream Imagens only supported from iOS and Android");
    }
    _hasListenImageStream = true;
    _controller.startImageStream(onListen);
  }

  void stopStreamImage() {
    if (_hasListenImageStream) {
      _controller.stopImageStream();
    } else {
      _hasListenImageStream = false;
    }
  }

  DeviceOrientation getApplicableOrientation() {
    return _controller.value.isRecordingVideo
        ? _controller.value.recordingOrientation!
        : (_controller.value.previewPauseOrientation ??
            _controller.value.lockedCaptureOrientation ??
            _controller.value.deviceOrientation);
  }

  Future<void> dispose() async {
    stopStreamImage();
    await _controller.dispose();

    return;
  }
}
