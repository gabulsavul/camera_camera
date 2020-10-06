import 'dart:developer';
import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera_camera/camera_camera.dart';

//import '../../lib/page/camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File val;

  Timer t1;

  Matrix4 matrix = Matrix4.identity();
  double zoom = 1;
  double prevZoom = 1;
  bool showZoom = false;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("")),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.camera_alt),
            onPressed: () async {
              val = await showDialog(
                  context: context,
                  builder: (context) => Camera(
                        mode: CameraMode.fullscreen,
                        zoomController: (Function zoomHandler){
                          return Container(
                            child: GestureDetector(
                              onScaleStart: (ScaleStartDetails details) {
                                print('scalStart');
                                setState(() => prevZoom = zoom);
                                setState(() {});
                              },
                              onScaleUpdate: (ScaleUpdateDetails details) {
                                var newZoom = (prevZoom * details.scale);

                                if (newZoom >= 1) {
                                  if (newZoom > 10) {
                                    return false;
                                  }
                                  setState(() {
                                    showZoom = true;
                                    zoom = newZoom;
                                  });

                                  if (t1 != null) {
                                    t1.cancel();
                                  }

                                  t1 = Timer(Duration(milliseconds: 2000), () {
                                    setState(() {
                                      showZoom = false;
                                    });
                                  });
                                }
                                zoomHandler(zoom);
                              },
                              onScaleEnd: (ScaleEndDetails details) {
                                setState(() {});
                              },
                            )
                          );
                        },
                        //initialCamera: CameraSide.front,
                        //enableCameraChange: false,
                        //  orientationEnablePhoto: CameraOrientation.landscape,
                        onChangeCamera: (direction, _) {
                          print('--------------');
                          print('$direction');
                          print('--------------');
                        },

                        // imageMask: CameraFocus.square(
                        //   color: Colors.black.withOpacity(0.5),
                        // ),
                      ));
              setState(() {});
            }),
        body: Center(
            child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                width: MediaQuery.of(context).size.width * 0.8,
                child: val != null
                    ? Image.file(
                        val,
                        fit: BoxFit.contain,
                      )
                    : Text("Tire a foto"))));
  }
}
