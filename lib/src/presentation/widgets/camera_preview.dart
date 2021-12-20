import 'dart:io';

import 'package:camera_camera/src/core/OrientationPreferences.dart';
import 'package:camera_camera/src/presentation/controller/camera_camera_controller.dart';
import 'package:camera_camera/src/presentation/controller/camera_camera_status.dart';
import 'package:flutter/material.dart';

class CameraCameraPreview extends StatefulWidget {
  final void Function(String value)? onFile;
  final CameraCameraController controller;
  final bool enableZoom;
  final bool enableFlipCamera;
  final GestureTapCallback? onCameraChange;
  CameraCameraPreview({
    Key? key,
    this.onFile,
    required this.controller,
    required this.enableZoom,
    required this.enableFlipCamera,
    required this.onCameraChange,
  }) : super(key: key);

  @override
  _CameraCameraPreviewState createState() => _CameraCameraPreviewState();
}

class _CameraCameraPreviewState extends State<CameraCameraPreview> {
  @override
  void initState() {
    OrientationPreferences.portraitModeOnly();
    widget.controller.init();
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
    OrientationPreferences.enableRotation();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CameraCameraStatus>(
      valueListenable: widget.controller.statusNotifier,
      builder: (_, status, __) => status.when(
          success: (camera) {
            Size? size = widget.controller.size();
            return GestureDetector(
              onScaleUpdate: (details) {
                widget.controller.setZoomLevel(details.scale);
              },
              child: Stack(
                children: [
                  new OverflowBox(
                    maxWidth: double.infinity,
                    maxHeight: double.infinity,
                    alignment: Alignment.center,
                    child: new FittedBox(
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                      clipBehavior: Clip.hardEdge,
                      child: new Container(
                        width: size?.shortestSide,
                        height: size?.longestSide,
                        //child: AspectRatio(
                        //aspectRatio: widget.controller.aspectRatio(),
                        child: widget.controller.buildPreview(),
                        //),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    //left: 0.0,
                    //right: 0.0,
                    child: Container(
                      height: 96 + 2 * 20 + 32,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.4),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  if (widget.enableZoom)
                    Positioned(
                      bottom: 96,
                      left: 0.0,
                      right: 0.0,
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey.withOpacity(0.6),
                        child: IconButton(
                          icon: Center(
                            child: Text(
                              "${camera.zoom.toStringAsFixed(1)}x",
                              style: TextStyle(color: Colors.white, fontSize: 12),
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
                        onTap: widget.controller.takePhoto,
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  if (widget.enableFlipCamera)
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: InkWell(
                          onTap: widget.onCameraChange,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.black.withOpacity(0.6),
                            child: Icon(
                              Platform.isAndroid //
                                  ? Icons.flip_camera_android
                                  : Icons.flip_camera_ios,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
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
}
