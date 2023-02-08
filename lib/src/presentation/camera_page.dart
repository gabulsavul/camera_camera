import 'dart:io';

import 'package:camera/camera.dart';
import 'package:camera_camera/src/core/camera_notifier.dart';
import 'package:camera_camera/src/core/camera_service.dart';
import 'package:camera_camera/src/core/camera_status.dart';
import 'package:camera_camera/src/presentation/widgets/camera_preview.dart';
import 'package:camera_camera/src/shared/entities/camera_mode.dart';
import 'package:camera_camera/src/shared/entities/camera_side.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CameraCamera extends StatefulWidget {
  ///Define your prefer resolution
  final ResolutionPreset resolutionPreset;

  ///CallBack function returns File your photo taken
  final void Function(File file) onFile;

  ///Define types of camera side is enabled
  final CameraSide cameraSide;

  ///Define your accepted [FlashMode]s
  final List<FlashMode> flashModes;

  ///Enable zoom camera ( default = true )
  final bool enableZoom;

  ///Whether to allow audio recording. This can remove the microphone
  ///permission on Android
  final bool enableAudio;

  //You can define your prefered aspect ratio, 1:1, 16:9, 4:3 or full screen
  final CameraMode mode;

  // You can listen image from camera frame by frame
  // This option running only iOS or Android devices
  final ValueChanged<CameraImage>? listenImage;

  CameraCamera(
      {Key? key,
      this.resolutionPreset = ResolutionPreset.ultraHigh,
      required this.onFile,
      this.cameraSide = CameraSide.all,
      this.flashModes = FlashMode.values,
      this.mode = CameraMode.ratio16s9,
      this.enableZoom = true,
      this.enableAudio = false,
      this.listenImage})
      : super(key: key);

  @override
  _CameraCameraState createState() => _CameraCameraState();
}

class _CameraCameraState extends State<CameraCamera> {
  late CameraNotifier controller = CameraNotifier(
    flashModes: widget.flashModes,
    service: CameraServiceImpl(),
    onPath: (path) => widget.onFile(File(path)),
    cameraSide: widget.cameraSide,
    enableAudio: widget.enableAudio,
    mode: widget.mode,
  );

  @override
  void initState() {
    controller.listen((state) {
      return state.when(
          orElse: () {},
          selected: (camera) async {
            controller.startPreview(widget.resolutionPreset,
                listenImage: widget.listenImage);
          });
    });
    controller.init();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    //SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    super.dispose();
  }

  Widget getIconByPlatform() {
    if (kIsWeb) {
      return Icon(Icons.flip_camera_android);
    }
    if (Platform.isAndroid) {
      return Icon(Icons.flip_camera_android);
    } else {
      return Icon(Icons.flip_camera_ios);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black,
      child: SafeArea(
        child: AnimatedBuilder(
          animation: controller,
          builder: (_, __) => controller.status.when(
              preview: (controller) => Stack(
                    children: [
                      CameraCameraPreview(
                        enableZoom: widget.enableZoom,
                        key: UniqueKey(),
                        controller: controller,
                      ),
                      if (this.controller.status.preview.cameras.length > 1)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(bottom: 32, right: 64),
                            child: InkWell(
                              onTap: () {
                                this.controller.changeCamera();
                              },
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.black.withOpacity(0.6),
                                child: getIconByPlatform(),
                              ),
                            ),
                          ),
                        )
                    ],
                  ),
              failure: (message, _) => ErrorWidget(message),
              orElse: () => Container(
                    color: Colors.black,
                  )),
        ),
      ),
    );
  }
}
