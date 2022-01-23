import 'package:camera_camera/src/presentation/controller/camera_camera_controller.dart';
import 'package:camera_camera/src/presentation/controller/camera_camera_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

class CameraCameraPreview extends StatefulWidget {
  final void Function(String value)? onFile;
  final CameraCameraController controller;
  final bool enableZoom;
  CameraCameraPreview({
    Key? key,
    this.onFile,
    required this.controller,
    required this.enableZoom,
  }) : super(key: key);

  @override
  _CameraCameraPreviewState createState() => _CameraCameraPreviewState();
}

class _CameraCameraPreviewState extends State<CameraCameraPreview> {
  @override
  void initState() {
    widget.controller.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraCameraStatus>(
      valueListenable: widget.controller.statusNotifier,
      builder: (_, status, __) => status.when(
          success: (camera, shutter) {
            if (shutter == false) {
              return Container(color: Colors.black);
            }
            return GestureDetector(
              onScaleUpdate: (details) {
                widget.controller.setZoomLevel(details.scale);
              },
              child: Stack(
                children: [
                  Center(
                    child: StreamBuilder<DeviceOrientationChangedEvent>(
                      builder: (context, snapshot) {
                        if (snapshot.data == null) {
                          return _wrapInRotatedBox(
                            child: widget.controller.buildPreview(),
                            orentation:
                                widget.controller.getApplicableOrientation(),
                          );
                        }
                        return _wrapInRotatedBox(
                          child: widget.controller.buildPreview(),
                          orentation: snapshot.data!.orientation,
                        );
                      },
                      stream:
                          CameraPlatform.instance.onDeviceOrientationChanged(),
                    ),
                  ),
                  if (widget.enableZoom)
                    Positioned(
                      bottom: 96,
                      left: 0.0,
                      right: 0.0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.black.withOpacity(0.6),
                        child: IconButton(
                          icon: Center(
                            child: Text(
                              "${camera.zoom.toStringAsFixed(1)}x",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                          onPressed: () {
                            widget.controller.zoomChange();
                          },
                        ),
                      ),
                    ),
                  if (widget.controller.flashModes.length > 1)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.black.withOpacity(0.6),
                          child: IconButton(
                            onPressed: () {
                              widget.controller.changeFlashMode();
                            },
                            icon: Icon(
                              camera.flashModeIcon,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: InkWell(
                        onTap: () {
                          widget.controller.takePhoto();
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          failure: (message, _) => Container(
                color: Colors.black,
                child: Text(message),
              ),
          orElse: () => Container(
                color: Colors.black,
              )),
    );
  }

  Widget _wrapInRotatedBox(
      {required Widget child, required DeviceOrientation orentation}) {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    }

    return RotatedBox(
      quarterTurns: _getQuarterTurns(orentation),
      child: child,
    );
  }

  int _getQuarterTurns(DeviceOrientation orentation) {
    return turns[orentation]!;
  }

  Map<DeviceOrientation, int> turns = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeRight: 1,
    DeviceOrientation.portraitDown: 2,
    DeviceOrientation.landscapeLeft: 3,
  };
}
