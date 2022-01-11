import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crop_image/crop_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as imglib;
import 'package:path_provider/path_provider.dart';
import 'newPage.dart';

class CropperXExample extends StatefulWidget {
  final String title;

  CropperXExample({Key key, this.title}) : super(key: key);

  @override
  _CropperXExampleState createState() => _CropperXExampleState();
}

class _CropperXExampleState extends State<CropperXExample> {
  final controller = CropController(
    aspectRatio: 12,
    defaultCrop: Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  File imageFile;
  File filepath;
  Image imgFile;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: Column(
          children: [
            Center(
              child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: imageFile != null
                      ? CropImage(
                          controller: controller, image: Image.file(imageFile))
                      : Container()),
            ),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewPage(imgFile),
                      ));
                },
                child: Text("Make Grid"))
          ],
        ),
        bottomNavigationBar: _buildButtons(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _pickGalleryImage();
          },
          child: Text('Pick'),
        ),
      );

  Widget _buildButtons() => Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextButton(
              onPressed: () {
                setState(() {});
                controller.aspectRatio = 1.0;
                controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
              },
              child: Text("Square")),
          TextButton(
              onPressed: () {
                setState(() {
                  controller.aspectRatio = 2.00 / 1;
                  controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                });
              },
              child: Text("2:1")),
          TextButton(
              onPressed: () {
                setState(() {
                  controller.aspectRatio = 4 / 3;
                  controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                });
              },
              child: Text("4:3")),
          TextButton(
              onPressed: () {
                setState(() {
                  controller.aspectRatio = 16 / 9;
                  controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                });
              },
              child: Text("16:9")),
        ],
      );

  Future<void> _aspectRatios() async {
    final value = await showDialog<double>(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text('Select aspect ratio'),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 1.0),
              child: Text('square'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 2.0),
              child: Text('2:1'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 4.0 / 3.0),
              child: Text('4:3'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, 16.0 / 9.0),
              child: Text('16:9'),
            ),
          ],
        );
      },
    );
    if (value != null) {
      controller.aspectRatio = value;
      controller.crop = Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
    }
  }
  Future<Null> _pickGalleryImage() async {
    final pickedImage = await ImagePicker().getImage(
      source: ImageSource.camera,
    );
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    setState(() {});
    if (imageFile == null) {
      Navigator.pop(context);
    }
  }
}
