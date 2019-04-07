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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Boomerang poc')),
      body: Center(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Go',
        child: Icon(Icons.camera),
      ),
    );
  }
}
