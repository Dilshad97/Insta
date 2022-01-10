import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:imagecrop/image_crop.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getStorgePermission();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 8;
    var width = MediaQuery.of(context).size.height / 8;
    return Scaffold(
      backgroundColor: Colors.accents[1].shade100,
      appBar: AppBar(
        elevation: 3,
        backgroundColor: Colors.accents[1].shade100,
        leading: Icon(Icons.share),
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageCropingExample(),
                      ));
                },
                child: gridRow(height, width, "Grid Maker",
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSiTKwz1crfnN02bdanB0LnOiYKPS08k6yah01PfnTwP5OkhyzbH93D456tCmWnWUX1AtQ&usqp=CAU')),
            InkWell(
                child: gridRow(height, width, 'Profile Viewer',
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ_xap6GbjH3v7-lDkmv_bOAsrryGTIW25blQ&usqp=CAU')),
            InkWell(
                child: gridRow(height, width, "Download Reels",
                    'https://icon-library.com/images/crop-icon/crop-icon-4.jpg'))
          ],
        ),
      ),
    );
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

  Widget gridRow(double height, double width, String text, final img) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Colors.blue, Colors.red, Colors.grey, Colors.blue],
          ),
          borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.network(
            img,
            height: 50,
            width: 80,
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          )
        ],
      ),
    );
  }

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
