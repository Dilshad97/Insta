import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'dart:io';
import 'package:image/image.dart' as imglib;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share/share.dart';

class ImageCropingExample extends StatefulWidget {
  final String title;

  ImageCropingExample({this.title});

  @override
  _ImageCropingExampleState createState() => _ImageCropingExampleState();
}

enum AppState { free, picked, croping, cropped, split }

class _ImageCropingExampleState extends State<ImageCropingExample> {
  AppState state;
  File imageFile;

  @override
  void initState() {
    super.initState();
    state = AppState.free;
    getStorgePermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: imageFile != null
              ? Container(
                  height: MediaQuery.of(context).size.height / 1.8,
                  padding: EdgeInsets.all(10),
                  child: GridView.count(
                    // childAspectRatio:
                    crossAxisCount: 3,
                    crossAxisSpacing: 1.5,
                    mainAxisSpacing: 1.5,
                    children: splitImage(imageFile.readAsBytesSync()),
                  ),
                )
              : Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.all(10),
                  color: Colors.grey.shade400,
                  child: Center(child: Text("Add Image by Clicking Add Icon ")),
                )),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          if (state == AppState.free)
            reqCameraPermision();
          else if (state == AppState.cropped) _clearImage();
        },
        child: _buildButtonIcon(),
      ),
    );
  }

  Future<dynamic> imageOption(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Wrap(
            children: [
              ListTile(
                title: Text("Browse from Gallery"),
                trailing: Icon(Icons.photo_album),
                onTap: () {
                  _pickGalleryImage();
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text("Take a Picture"),
                trailing: Icon(Icons.photo_camera),
                onTap: () {
                  _pickCameraImage();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  ///FAB Button Icon
  Widget _buildButtonIcon() {
    if (state == AppState.free)
      return Icon(Icons.add);
    else if (state == AppState.cropped)
      return Icon(Icons.clear);
    else
      return Container();
  }

  ///Storage Permission
  Future<void> getStorgePermission() async {
    final serviceStatus = await Permission.storage.isGranted;
    bool isStorage = serviceStatus == ServiceStatus.enabled;
    final storageStatus = await Permission.storage.request();
    if (storageStatus == PermissionStatus.granted) {
      print("Storage permission granted");
    } else if (storageStatus == PermissionStatus.denied) {
      print("Storage permission denied");
      showToast("Storage Permission is required");
    } else if (storageStatus == PermissionStatus.permanentlyDenied) {
      showToast("Storage Permission is required");
      print("Storage permission permanently denied");
    }
  }

  /// Camera Permission
  Future<void> reqCameraPermision() async {
    final serviceStatus = await Permission.camera.isGranted;
    bool isCameraOn = serviceStatus == ServiceStatus.enabled;
    final status = await Permission.camera.request();
    if (status == PermissionStatus.granted) {
      imageOption(context);
      print("permission granted");
    } else if (status == PermissionStatus.denied) {
      showToast("Camera Permission is required");
      print("permission denied");
    } else if (status == PermissionStatus.permanentlyDenied) {
      showToast("Camera Permission is required");
      print('permanent denied');
      await openAppSettings();
    }
  }

  /// pick image from camera
  Future<Null> _pickCameraImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.camera);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      _cropImage();
    }
  }

  Future<Null> _pickGalleryImage() async {
    final pickedImage =
        await ImagePicker().getImage(source: ImageSource.gallery);
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      // CircularProgressIndicator();
      _cropImage();
    }
  }

  ///crop image in square
  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.square,
              ]
            : [
                CropAspectRatioPreset.square,
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

  ///Splitting images in 3x3
  List<Widget> splitImage(List<int> input) {
    imglib.Image image = imglib.decodeImage(imageFile.readAsBytesSync());
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
            savingFile(
              img,
            );
            shareImage();
          },
          child: Image.memory(imglib.encodeJpg(img))));
    }
    return output;
  }

  File filepath;

  ///Saving file locally
  Future<void> savingFile(imglib.Image img) async {
    var imagePath = imglib.encodeJpg(img);
    final external = (await getApplicationDocumentsDirectory()).path +
        '/${TimeOfDay.now().toString()}.png';
    try {
      final file = File(external);
      filepath = await file.writeAsBytes(imagePath);
    } catch (error) {
      print('///// ERROR: $error');
    }
  }

  ///Share image
  Future<void> shareImage() async {
    final RenderBox box = context.findRenderObject();
    Share.shareFiles([filepath.path],
        subject: "this is subject",
        sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
  }

  ///clear image
  void _clearImage() {
    imageFile = null;
    setState(() {
      state = AppState.free;
    });
  }

  /// Flutter Toast
  void showToast(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      fontSize: 16.0,
      backgroundColor: Colors.transparent,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      textColor: Colors.white,
    );
  }
}
