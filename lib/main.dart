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
  List<CameraDescription> _cameras = [];

  int _lastTimestamp = 0;
  int _time = 0;
  bool _enableCameraPreview = false;
  List<CameraImage> _cameraImages = [];
  List<Uint8List> _convertedImages = [];

  void initState() {
    super.initState();
    availableCameras().then((List<CameraDescription> cameras) {
      _cameras = cameras;
      _setupCamera();
    });
  }

  void dispose() {
    super.dispose();
    _camera?.dispose();
  }

  Future<void> _setupCamera({
    CameraLensDirection cameraLensDirection: CameraLensDirection.back,
  }) async {
    assert(cameraLensDirection != null);

    await _camera?.dispose();
    _camera = CameraController(_cameras.firstWhere((CameraDescription camera) {
      return camera.lensDirection == cameraLensDirection;
    }), ResolutionPreset.low);
    await _camera.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Boomerang poc')),
      body: Center(
        child: _camera != null && _enableCameraPreview
            ? AspectRatio(
                aspectRatio: _camera.value.aspectRatio,
                child: CameraPreview(_camera),
              )
            : Container(
                height: 200.0,
                width: 200.0,
                color: Colors.lime,
                alignment: Alignment.center,
                child: Text('Ready'),
              ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () {
              setState(() => _enableCameraPreview = !_enableCameraPreview);
              _setupCameraPreviewNew();
            },
            tooltip: 'After recording.',
            child: _enableCameraPreview
                ? Text('${_time > 0 ? (1000 / _time).round() : 0}fps')
                : Icon(Icons.camera),
          ),
          SizedBox(height: 20),
          FloatingActionButton(
            onPressed: () {
              setState(() => _enableCameraPreview = !_enableCameraPreview);
              _setupCameraPreview();
            },
            tooltip: 'During recording.',
            child: _enableCameraPreview
                ? Text('${_time > 0 ? (1000 / _time).round() : 0}fps')
                : Icon(Icons.camera),
          ),
        ],
      ),
    );
  }

  Future<void> _setupCameraPreview() async {
    if (_enableCameraPreview) {
      _convertedImages = [];
      _camera.startJpegImageStream(
        (Uint8List image) async {
          setState(() {
            _convertedImages.add(image);
            if (_lastTimestamp > 0)
              _time = DateTime.now().millisecondsSinceEpoch - _lastTimestamp;
          });
          _lastTimestamp = DateTime.now().millisecondsSinceEpoch;
        },
        rotation: 90,
      );
    } else {
      _camera.stopImageStream();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ListView.builder(
            itemCount: _convertedImages.length,
            itemBuilder: (BuildContext context, int index) {
              return Image.memory(_convertedImages[index]);
            },
          );
        },
      );
    }
  }

  Future<void> _setupCameraPreviewNew() async {
    if (_enableCameraPreview) {
      _cameraImages = [];
      _camera.startImageStream(
        (CameraImage image) async {
          setState(() {
            _cameraImages.add(image);
            if (_lastTimestamp > 0)
              _time = DateTime.now().millisecondsSinceEpoch - _lastTimestamp;
          });
          _lastTimestamp = DateTime.now().millisecondsSinceEpoch;
        },
      );
    } else {
      _camera.stopImageStream();
      Iterable<Future<Uint8List>> _result = _cameraImages.map(
        (CameraImage _cameraImage) {
          return _camera.yuv420ToJpeg(_cameraImage, rotation: 90);
        },
      );
      _convertedImages = await Future.wait(_result);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ListView.builder(
            itemCount: _convertedImages.length,
            itemBuilder: (BuildContext context, int index) {
              return Image.memory(_convertedImages[index]);
            },
          );
        },
      );
    }
  }
}
