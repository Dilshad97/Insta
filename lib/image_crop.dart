import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
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

enum AppState { free, picked, cropped, aspectRatio }

class _ImageCropingExampleState extends State<ImageCropingExample> {
  AppState state;
  File imageFile;
  File filepath;

  @override
  void initState() {
    super.initState();
    state = AppState.free;
    reqCameraPermision();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
          child: imageFile != null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: MediaQuery.of(context).size.height / 1.8,
                      padding: EdgeInsets.all(10),
                      child: FutureBuilder(
                        future: gridImage(),
                        builder: (
                          context,
                          snapshot,
                        ) {
                          if (snapshot.connectionState ==
                              ConnectionState.none) {
                            return CircularProgressIndicator();
                          } else if (snapshot.connectionState ==
                              ConnectionState.done) {
                            return Column(
                              children: [
                                GridView.count(
                                  shrinkWrap:  true,
                                  crossAxisCount: 3,
                                  crossAxisSpacing: 1.5,
                                  mainAxisSpacing: 1.5,
                                  children: splitImage3X3(
                                      imageFile.readAsBytesSync()),
                                ),
                              ],
                            );
                          }
                          return Center(
                            child: Text(
                              "Loading...",
                              style: TextStyle(fontSize: 20),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(7)),
                      width: 70,
                      height: 30,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.save,
                            color: Colors.white,
                          ),
                          Text(
                            'Save',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          )
                        ],
                      ),
                    )
                  ],
                )
              : Container()),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          if (state == AppState.free)
            reqCameraPermision();
          else if (state == AppState.cropped) {
            _clearImage();
            Navigator.pop(context);
          }
        },
        child: _buildButtonIcon(),
      ),
    );
  }

  /// Future Grid show
  gridImage() async {
    // await splitImage(imageFile.readAsBytesSync());
  }

  ///Bottom sheet Image Option
  Future<dynamic> imageOption(BuildContext context) async {
    var store = await showModalBottomSheet(
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
                  Navigator.pop(context, true);
                },
              ),
              ListTile(
                title: Text("Take a Picture"),
                trailing: Icon(Icons.photo_camera),
                onTap: () {
                  _pickCameraImage();
                  Navigator.pop(context, true);
                },
              ),
            ],
          ),
        );
      },
    );
    if (store == null) {
      Navigator.pop(context);
    }
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
      customCropper();
    }
    if (imageFile == null) {
      Navigator.pop(context);
    }
  }

  /// picking image from Gallery
  Future<Null> _pickGalleryImage() async {
    final pickedImage = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    imageFile = pickedImage != null ? File(pickedImage.path) : null;
    if (imageFile != null) {
      CircularProgressIndicator();
      _cropImage();
      // customCropper();
    }
    if (imageFile == null) {
      Navigator.pop(context);
    }
  }



  void  customCropper(){

    Container(
         height: 200,
        width: 500,
        child: Image.file(imageFile));


  }


  ///crop image in square
  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid
            ? [CropAspectRatioPreset.square, CropAspectRatioPreset.ratio3x2]
            : [CropAspectRatioPreset.square, CropAspectRatioPreset.ratio3x2],
        cropStyle: CropStyle.rectangle,
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Crop Your Image to Make Grid',
            toolbarColor: Colors.accents[1].shade100,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: true),
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
  List<Widget> splitImage3X3(List<int> input) {
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
            savingFile(img);
            shareImage();
          },
          child: Image.memory(imglib.encodeJpg(img))));
    }
    return output;
  }

  /// Splitting image in 2x3
  List<Widget> splitImage2x3(List<int> input) {
    imglib.Image image = imglib.decodeImage(imageFile.readAsBytesSync());
    int x = 1, y = 0;
    int width = (image.width / 3).round();
    int height = (image.height / 2).round();

    List<imglib.Image> parts = <imglib.Image>[];
    for (int i = 0; i < 2; i++) {
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
            savingFile(img);
            shareImage();
          },
          child: Image.memory(imglib.encodeJpg(img))));
    }
    return output;
  }

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
