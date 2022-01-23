import 'package:camera/camera.dart';
import 'package:camera_camera/src/shared/entities/camera.dart';
import 'package:camera_platform_interface/camera_platform_interface.dart';

abstract class CameraCameraStatus {}

class CameraCameraEmpty extends CameraCameraStatus {
  CameraCameraEmpty();
}

class CameraCameraLoading extends CameraCameraStatus {
  CameraCameraLoading();
}

class CameraCameraFailure extends CameraCameraStatus {
  String message;
  CameraException exception;
  CameraCameraFailure({
    required this.message,
    required this.exception,
  });
}

class CameraCameraSuccess extends CameraCameraStatus {
  Camera camera;
  bool shatterOpen;
  CameraCameraSuccess({
    required this.camera,
    this.shatterOpen = true,
  });
}

extension CameraCameraStatusExt on CameraCameraStatus {
  Camera get camera => (this as CameraCameraSuccess).camera;
  CameraCameraFailure get failure => this as CameraCameraFailure;
  CameraCameraLoading get loading => this as CameraCameraLoading;
  CameraCameraSuccess get success => this as CameraCameraSuccess;
  dynamic when({
    Function(String message, dynamic exception)? failure,
    Function()? loading,
    required Function() orElse,
    Function(Camera camera, bool shutter)? success,
  }) {
    switch (this.runtimeType) {
      case CameraCameraFailure:
        {
          if (failure != null) {
            return failure(this.failure.message, this.failure.exception);
          } else {
            return orElse();
          }
        }

      case CameraCameraLoading:
        {
          if (loading != null) {
            return loading();
          } else {
            return orElse();
          }
        }

      case CameraCameraSuccess:
        {
          if (success != null) {
            return success(this.success.camera, this.success.shatterOpen);
          } else {
            return orElse();
          }
        }

      default:
        throw "CAMERA CAMERA (UI) INVALID STATUS";
    }
  }
}
