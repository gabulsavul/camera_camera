import 'package:flutter/material.dart';

class CameraFocus {
  CameraFocus._();

  static Widget rectangle({Color color}) => _FocusRectangle(color: color);
  static Widget circle({Color color}) => _FocusCircle(
        color: color,
      );
  static Widget square({Color color}) => _FocusSquare(
        color: color,
      );
}

class _FocusSquare extends StatelessWidget {
  final Color color;

  const _FocusSquare({Key key, this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipPath(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: color,
        ),
        clipper: _SquareModePhoto(),
      ),
    );
  }
}

class _SquareModePhoto extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    var reactPath = Path();

    reactPath.moveTo(size.width / 4, size.height * 2 / 6);
    reactPath.lineTo(size.width * 3 / 4, size.height * 2 / 6);
    reactPath.lineTo(size.width * 3 / 4, size.height * 4 / 6);
    reactPath.lineTo(size.width / 4, size.height * 4 / 6);

    path.addPath(reactPath, Offset(0, 0));
    path.addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    path.fillType = PathFillType.evenOdd;
/*
    path.moveTo(size.width/4, size.height/4);
    path.lineTo(size.width/4, size.height*3/4);
    path.lineTo(size.width*3/4, size.height*3/4);
    path.lineTo(size.width*3/4, size.height/4);
*/
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _FocusRectangle extends StatelessWidget {
  final Color color;

  const _FocusRectangle({Key key, this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipPath(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: color,
        ),
        clipper: _RectangleModePhoto(),
      ),
    );
  }
}

class _RectangleModePhoto extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    var reactPath = Path();

    reactPath.moveTo(size.width / 4, size.height / 4);
    reactPath.lineTo(size.width / 4, size.height * 3 / 4);
    reactPath.lineTo(size.width * 3 / 4, size.height * 3 / 4);
    reactPath.lineTo(size.width * 3 / 4, size.height / 4);

    path.addPath(reactPath, Offset(0, 0));
    path.addRect(Rect.fromLTWH(0.0, 0.0, size.width, size.height));
    path.fillType = PathFillType.evenOdd;
/*
    path.moveTo(size.width/4, size.height/4);
    path.lineTo(size.width/4, size.height*3/4);
    path.lineTo(size.width*3/4, size.height*3/4);
    path.lineTo(size.width*3/4, size.height/4);
*/
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class _FocusCircle extends StatelessWidget {
  final Color color;

  const _FocusCircle({Key key, this.color}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ClipPath(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          color: color,
        ),
        clipper: _CircleModePhoto(),
      ),
    );
  }
}

class _CircleModePhoto extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return new Path()
      ..addOval(new Rect.fromCircle(
          center: new Offset(size.width / 2, size.height / 2),
          radius: size.width * 0.4))
      ..addRect(new Rect.fromLTWH(0.0, 0.0, size.width, size.height))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}
