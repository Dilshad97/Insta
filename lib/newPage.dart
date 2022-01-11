import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart'as imglib;
import 'package:path_provider/path_provider.dart';

class NewPage extends StatefulWidget {
  NewPage(this.imgFile);
 imglib.Image imgFile;
  @override
  _NewPageState createState() => _NewPageState();
}

class _NewPageState extends State<NewPage> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      body: GridView.count(crossAxisCount: 3,crossAxisSpacing: 2,mainAxisSpacing: 2,
       children: splitImage3X3(filepath.readAsBytesSync()),
      ),

    ));
  }

File filepath;

  fileConversion()async{
    Image.memory(imglib.encodeJpg(widget.imgFile));
    var bytes = await rootBundle.load('${widget.imgFile}');
    String tempPath = (await getTemporaryDirectory()).path;
    final file = File(tempPath);
    filepath=await file.writeAsBytes(bytes.buffer.asUint8List());
    return filepath;
  }
  // List<Widget> splitImage3X3(List<int> input) {
  //   imglib.Image image = imglib.decodeImage(file.readAsBytesSync());
  //   int x = 1, y = 0;
  //   int width = (image.width / 3).round();
  //   int height = (image.height / 3).round();
  //
  //   List<imglib.Image> parts = <imglib.Image>[];
  //   for (int i = 0; i < 3; i++) {
  //     for (int j = 0; j < 3; j++) {
  //       parts.add(imglib.copyCrop(image, x, y, width, height));
  //       x += width;
  //     }
  //     x = 0;
  //     y += height;
  //   }
  //   List<Widget> output = <Widget>[];
  //   for (var img in parts) {
  //     output.add(GestureDetector(
  //         onTap: () {
  //           // savingFile(img);
  //           // shareImage();
  //         },
  //         child: Image.memory(imglib.encodeJpg(img))));
  //   }
  //   return output;
  // }
  List<Widget> splitImage3X3(List<int> input) {
    imglib.Image image = imglib.decodeImage(filepath.readAsBytesSync());
    int x = 1, y = 0;
    int width = (image.width / 3).round();
    int height = (image.height / 3).round();

    List<imglib.Image> parts = <imglib.Image>[];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        parts.add(imglib.copyCrop(image, x, y, width, height));
        x += width;
      }
      x = 0;
      y += height;
    }
    List<Widget> output = <Widget>[];
    for (var img in parts) {
      output.add(GestureDetector(
          onTap: () {
            // savingFile(img);
            // shareImage();
          },
          child: Image.memory(imglib.encodeJpg(img))));
    }
    return output;
  }




}
