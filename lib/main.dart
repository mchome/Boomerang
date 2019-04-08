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
  int _lastTimestamp = 0;
  int _time = 0;
  List<CameraDescription> _cameras = [];
  bool _isFrontCamera = true;

  void initState() {
    super.initState();
    availableCameras().then((List<CameraDescription> cameras) {
      _cameras = cameras;
      _setupFrontCamera();
    });
  }

  void dispose() {
    super.dispose();
    _camera?.dispose();
  }

  Future<void> _setupFrontCamera() async {
    await _camera?.dispose();
    _camera = CameraController(_cameras.firstWhere((CameraDescription camera) {
      return camera.lensDirection == CameraLensDirection.front;
    }), ResolutionPreset.low);
    await _camera.initialize();
  }

  Future<void> _setupBackCamera() async {
    await _camera?.dispose();
    _camera = CameraController(_cameras.firstWhere((CameraDescription camera) {
      return camera.lensDirection == CameraLensDirection.back;
    }), ResolutionPreset.low);
    await _camera.initialize();
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
            ? GestureDetector(
                onTap: () async {
                  if (_isFrontCamera)
                    await _setupBackCamera();
                  else
                    await _setupFrontCamera();

                  setState(() => _isFrontCamera = !_isFrontCamera);
                  _setupCameraPreview();
                },
                child: Image.memory(_image, gaplessPlayback: true),
              )
            : Container(height: 200.0, width: 200.0, color: Colors.amber),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() => _enableCameraPreview = !_enableCameraPreview);
          _setupCameraPreview();
        },
        child: _enableCameraPreview
            ? Text(_time > 0 ? '${(1000 / _time).round()}fps' : '0fps')
            : Icon(Icons.camera),
      ),
    );
  }

  void _setupCameraPreview() {
    _enableCameraPreview
        ? _camera.startJpegImageStream(
            (Uint8List image) async {
              setState(() {
                this._image = image;
                if (_lastTimestamp > 0) {
                  this._time =
                      DateTime.now().millisecondsSinceEpoch - _lastTimestamp;
                }
              });
              _lastTimestamp = DateTime.now().millisecondsSinceEpoch;
            },
            horizontalFlip: _isFrontCamera,
            rotation: _isFrontCamera ? -90 : 90,
          )
        : _camera.stopImageStream();
  }
}
