import 'package:flutter/material.dart';
import 'package:imagecrop/check.dart';
import 'package:imagecrop/image_crop.dart';
import 'package:imagecrop/home_page.dart';

import 'chek_Croper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Puzzle',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

