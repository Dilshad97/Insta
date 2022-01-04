import 'package:flutter/material.dart';
import 'package:imagecrop/image_crop.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Puzzle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageCropingExample(),
    );
  }
}

