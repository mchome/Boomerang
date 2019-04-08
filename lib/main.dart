import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

void main() => runApp(BoomerangApp());

class BoomerangApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      MaterialApp(title: 'Boomerang poc', home: MainPage());
}

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  CameraController _camera;
  bool _enableCameraPreview = false;
  Uint8List _image;

  void initState() {
    super.initState();
    availableCameras().then((List<CameraDescription> cameras) {
      _camera = CameraController(cameras.firstWhere((CameraDescription camera) {
        return camera.lensDirection == CameraLensDirection.front;
      }), ResolutionPreset.low)
        ..initialize();
    });
  }

  void dispose() {
    super.dispose();
    _camera?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Boomerang poc')),
      body: Center(
        child: _camera != null && _enableCameraPreview && _image != null
            // ? AspectRatio(
            //     aspectRatio: _camera.value.aspectRatio,
            //     child: CameraPreview(_camera),
            //   )
            ? Image.memory(_image, gaplessPlayback: true)
            : Container(height: 200.0, width: 200.0, color: Colors.amber),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _enableCameraPreview = !_enableCameraPreview);
          _enableCameraPreview
              ? _camera.startJpegImageStream((Uint8List image) async {
                  setState(() => this._image = image);
                })
              : _camera.stopImageStream();
        },
        child: Icon(Icons.camera),
      ),
    );
  }
}
