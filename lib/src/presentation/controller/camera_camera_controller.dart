import 'package:camera/camera.dart';
import 'package:camera_camera/src/shared/entities/camera.dart';
import 'package:flutter/material.dart';

import 'camera_camera_status.dart';

class CameraCameraController {
  ResolutionPreset resolutionPreset;
  CameraDescription cameraDescription;
  List<FlashMode> flashModes;
  void Function(String path) onPath;
  bool enableAudio;

  late CameraController _controller;

  final statusNotifier = ValueNotifier<CameraCameraStatus>(CameraCameraEmpty());
  CameraCameraStatus get status => statusNotifier.value;
  set status(CameraCameraStatus status) => statusNotifier.value = status;

  CameraCameraController({
    required this.resolutionPreset,
    required this.cameraDescription,
    required this.flashModes,
    required this.onPath,
    this.enableAudio = false,
  }) {
    _controller = CameraController(cameraDescription, resolutionPreset, enableAudio: enableAudio);
  }

  void init() async {
    status = CameraCameraLoading();
    try {
      await _controller.initialize();
      final maxZoom = await _controller.getMaxZoomLevel();
      final minZoom = await _controller.getMinZoomLevel();
      final maxExposure = await _controller.getMaxExposureOffset();
      final minExposure = await _controller.getMinExposureOffset();
      try {
        await _controller.setFlashMode(FlashMode.off);
      } catch (e) {}

      status = CameraCameraSuccess(camera: Camera(maxZoom: maxZoom, minZoom: minZoom, zoom: minZoom, maxExposure: maxExposure, minExposure: minExposure, flashMode: FlashMode.off));
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
    if (zoom != 1) {
      var cameraZoom = double.parse(((zoom)).toStringAsFixed(1));
      if (cameraZoom >= status.camera.minZoom && cameraZoom <= status.camera.maxZoom) {
        final camera = status.camera.copyWith(zoom: cameraZoom);
        status = CameraCameraSuccess(camera: camera);
        await _controller.setZoomLevel(cameraZoom);
      }
    }
  }

  void zoomChange() async {
    var zoom = status.camera.zoom;
    if (zoom + 0.5 <= status.camera.maxZoom) {
      zoom += 0.5;
    } else {
      zoom = 1.0;
    }
    final camera = status.camera.copyWith(zoom: zoom);
    status = CameraCameraSuccess(camera: camera);
    await _controller.setZoomLevel(zoom);
  }

  void zoomIn() async {
    var zoom = status.camera.zoom;
    if (zoom + 1 <= status.camera.maxZoom) {
      zoom += 1;

      final camera = status.camera.copyWith(zoom: zoom);
      status = CameraCameraSuccess(camera: camera);
      await _controller.setZoomLevel(zoom);
    }
  }

  void zoomOut() async {
    var zoom = status.camera.zoom;
    if (zoom - 1 >= status.camera.minZoom) {
      zoom -= 1;

      final camera = status.camera.copyWith(zoom: zoom);
      status = CameraCameraSuccess(camera: camera);
      await _controller.setZoomLevel(zoom);
    }
  }

  void takePhoto() async {
    final file = await _controller.takePicture();

    onPath(file.path);
  }

  Widget buildPreview() => _controller.buildPreview();

  Future<void> dispose() async {
    await _controller.dispose();
    return;
  }

  double aspectRatio() {
    return _controller.value.aspectRatio;
  }

  Size? size() {
    return _controller.value.previewSize;
  }
}
