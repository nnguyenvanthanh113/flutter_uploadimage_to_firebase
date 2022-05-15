import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FullScreenImage extends StatefulWidget {
  FullScreenImage({
    required this.child,
    required this.dark,
    required this.name,
  });

  final String child;
  final bool dark;
  final String name;

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
  //final imgUrl = "https://images6.alphacoders.com/683/thumb-1920-683023.jpg";

  bool downloading = false;
  var progress = "";
  var pathDownload = "No Data";
  var platformVersion = "Unknown";
  Permission permission1 = Permission.storage;
  var _onPressed;
  static final Random random = Random();
  late Directory externalDir;
  @override
  void initState() {
    var brightness = widget.dark ? Brightness.light : Brightness.dark;
    var color = widget.dark ? Colors.black12 : Colors.white70;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      systemNavigationBarColor: color,
      statusBarColor: color,
      statusBarBrightness: brightness,
      statusBarIconBrightness: brightness,
      systemNavigationBarDividerColor: color,
      systemNavigationBarIconBrightness: brightness,
    ));
    super.initState();
  }

  @override
  void dispose() {
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //     // Restore your settings here...
    //     ));
    super.dispose();
  }

  Future<void> downloadFile() async {
    Dio dio = Dio();

    String dirloc = "";
    // if (Platform.isAndroid) {
    //   dirloc = "/sdcard/download/";
    // } else {
    //   dirloc = (await getApplicationDocumentsDirectory()).path;
    // }
    dirloc = (await getApplicationDocumentsDirectory()).path;
    print('dirloc: ' + dirloc);
    var randid = random.nextInt(10000);

    try {
      //FileUtils.mkdir([dirloc]);
      await dio.download(widget.child, dirloc + randid.toString() + ".jpg",
          onReceiveProgress: (receivedBytes, totalBytes) {
        setState(() {
          downloading = true;
          progress =
              ((receivedBytes / totalBytes) * 100).toStringAsFixed(0) + "%";
        });
      });
    } catch (e) {
      print(e);
    }

    setState(() {
      downloading = false;
      progress = "Download Completed.";
      pathDownload = dirloc + randid.toString() + ".jpg";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.name),
          actions: <Widget>[
            IconButton(
              onPressed: () {
                downloadFile();
              },
              icon: const Icon(Icons.download),
            )
          ],
        ),
        backgroundColor: widget.dark ? Colors.black : Colors.white,
        body: Center(
          child: downloading
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(pathDownload),
                    MaterialButton(
                      child: const Text('Request Permission Again.'),
                      onPressed: _onPressed,
                      disabledColor: Colors.blueGrey,
                      color: Colors.pink,
                      textColor: Colors.white,
                      height: 40.0,
                      minWidth: 100.0,
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Stack(
                      children: [
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 333),
                          curve: Curves.fastOutSlowIn,
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.5,
                            maxScale: 4,
                            child: Image.network(widget.child),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
        ));
  }
}
