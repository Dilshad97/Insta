import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({this.title});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class _MyHomePageState extends State<MyHomePage> {
  AppState state;
  File imageFile;
  double height = 100.0;
  Offset position;

  @override
  void initState() {
    super.initState();
    state = AppState.free;
    position = Offset(0.0, height - 20);
  }

  double width;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width / 1.1;
    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          imageFile != null ? Image.file(imageFile) : Container(),
          Positioned(
            left: position.dx,
            top: position.dy - height + 20,
            child: Draggable(
              child: SizedBox(
                  height: 500,
                  width: width,
                  child: AspectRatio(
                    aspectRatio: 2 / 1,
                    child: Container(
                      decoration: BoxDecoration(
                        // color: Colors.red ,
                          border: Border.all(color: Colors.yellow)),
                    ),
                  )),
              feedback: Container(),
              onDraggableCanceled: (Velocity velocity, Offset offset) {
                setState(() => position = offset);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          if (state == AppState.free)
            _pickImage();
          else if (state == AppState.picked)
            // _cropImage();
            // corpImagr();
            _clearImage();
          else if (state == AppState.cropped) _clearImage();
        },
        child: _buildButtonIcon(),
      ),
    );
  }

  Widget _buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.add);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.clear);
    else
      return Container();
  }

  Future<Null> _pickImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.camera);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
    }
  }

  // corpImagr() {
  //   Positioned(
  //     left: position.dx,
  //     top: position.dy - height + 20,
  //     child: Draggable(
  //       child: Container(
  //         decoration: BoxDecoration(border: Border.all(color: Colors.red)),
  //         width: width,
  //         height: height,
  //         // color: Colors.blue,
  //         // child: Center(child: Text("Drag",),),
  //       ),
  //       feedback: Container(
  //           // child: Center(
  //           //   child: Text("Drag", ),),
  //           // color: Colors.blue[300],
  //           // width: width,
  //           // height: height,
  //           ),
  //       onDraggableCanceled: (Velocity velocity, Offset offset) {
  //         setState(() => position = offset);
  //       },
  //     ),
  //   );
  // }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Cropper',
        ));
    if (croppedFile != null) {
      imageFile = croppedFile;
      setState(() {
        state = AppState.cropped;
      });
    }
  }

  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }
}
