import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_uploadimage_to_firebase/Screen/VideoFullScreen.dart';
import 'package:flutter_uploadimage_to_firebase/Screen/ImageFullScreen.dart';
import 'package:hawk_fab_menu/hawk_fab_menu.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';

class ListImage extends StatefulWidget {
  const ListImage({Key? key}) : super(key: key);

  @override
  _ListImageState createState() => _ListImageState();
}

class _ListImageState extends State<ListImage> {
  GlobalKey bottomNavigationKey = GlobalKey();
  FirebaseStorage storage = FirebaseStorage.instance;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  late bool _authorValidation = false;
  late bool _fileNameValidation = false;
  // late String _tempDir;
  late VideoPlayerController _controller;

  // Then upload to Firebase Storage
  Future<void> _upload(String inputSource, String type) async {
    //ShowDialog();
    late String fileName;

    final picker = ImagePicker();
    XFile? pickedImage;
    XFile? pickerVideo;
    try {
      if (type == 'image') {
        pickedImage = await picker.pickImage(
            source: inputSource == 'camera'
                ? ImageSource.camera
                : ImageSource.gallery,
            maxWidth: 1920);
        File imageFile = File(pickedImage!.path);
        // ignore: unnecessary_this
        await _displayTextInputDialog(this.context);
        //await ShowDialog();

        try {
          // Uploading the selected image with some custom meta data
          if (_fileNameController.text.isEmpty) {
            fileName = path.basename(pickedImage.path);
          } else {
            fileName = path.basename(_fileNameController.text);
          }
          await storage.ref('image/' + fileName).putFile(
              imageFile,
              SettableMetadata(customMetadata: {
                'uploaded_by': _authorController.text,
                'description': _descriptionController.text,
              }));

          // Refresh the UI
          setState(() {});
        } on FirebaseException catch (error) {
          if (kDebugMode) {
            print(error);
          }
        }
      } else if (type == 'video') {
        pickerVideo = await picker.pickVideo(
            source: inputSource == 'camera'
                ? ImageSource.camera
                : ImageSource.gallery,
            maxDuration: const Duration(seconds: 60));
        File videoFile = File(pickerVideo!.path);
        // ignore: unnecessary_this
        await _displayTextInputDialog(this.context);
        try {
          // Uploading the selected image with some custom meta data
          //print('_fileNameController.text: ' + _fileNameController.text);
          if (_fileNameController.text.isEmpty) {
            fileName = path.basename(pickerVideo.path);
          } else {
            fileName = path.basename(_fileNameController.text);
          }
          await storage.ref('video/' + fileName).putFile(
              videoFile,
              SettableMetadata(customMetadata: {
                'uploaded_by': _authorController.text,
                'description': _descriptionController.text,
              }));

          // Refresh the UI
          setState(() {});
        } on FirebaseException catch (error) {
          if (kDebugMode) {
            print(error);
          }
        }
      }
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
  }

  // Retriew the uploaded images
  Future<List<Map<String, dynamic>>> _loadImages() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref('image/').list();
    final List<Reference> allFiles = result.items;

    await Future.forEach<Reference>(allFiles, (file) async {
      print('file:' + file.toString());
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      files.add({
        "url": fileUrl,
        "path": file.fullPath.split('/')[1],
        "path_delete": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description'
      });
    });

    return files;
  }

  //Retriew the uploaded videos
  Future<List<Map<String, dynamic>>> _loadVideos() async {
    List<Map<String, dynamic>> files = [];

    final ListResult result = await storage.ref('video/').list();
    final List<Reference> allFiles = result.items;
    // ignore: unused_local_variable
    Uint8List bytes;
    await Future.forEach<Reference>(allFiles, (file) async {
      final String fileUrl = await file.getDownloadURL();
      final FullMetadata fileMeta = await file.getMetadata();
      final fileName = await VideoThumbnail.thumbnailFile(
        video: fileUrl,
        thumbnailPath: (await getTemporaryDirectory()).path,
        imageFormat: ImageFormat.PNG,
        maxHeight:
            64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
        quality: 75,
      );
      final thumbnailFile = File(fileName!);
      bytes = thumbnailFile.readAsBytesSync();
      print('filename: ' + fileName.toString());
      files.add({
        "url": fileUrl,
        "path": file.fullPath.split('/')[1],
        "path_delete": file.fullPath,
        "uploaded_by": fileMeta.customMetadata?['uploaded_by'] ?? 'Nobody',
        "description":
            fileMeta.customMetadata?['description'] ?? 'No description',
        "thumbnail": bytes
      });
    });

    return files;
  }

  // Delete the selected image
  // This function is called when a trash icon is pressed
  Future<void> _delete(String ref) async {
    await storage.ref(ref).delete();
    // Rebuild the UI
    setState(() {});
  }

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('thông tin hình ảnh!'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  //author
                  TextField(
                    controller: _authorController,
                    textInputAction: TextInputAction.go,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Vui lòng nhập tác giả!",
                      errorText:
                          _authorValidation ? 'Vui lòng nhập tác giả!' : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        //_description = value;
                      });
                    },
                  ),
                  const SizedBox(height: 5),
                  // file name
                  TextField(
                    controller: _fileNameController,
                    textInputAction: TextInputAction.go,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: "Vui lòng nhập tên hình ảnh!",
                      errorText: _fileNameValidation
                          ? 'Vui lòng nhập tên hình ảnh!'
                          : null,
                    ),
                    onChanged: (value) {
                      setState(() {
                        //_description = value;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  //description
                  TextField(
                    controller: _descriptionController,
                    textInputAction: TextInputAction.go,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Vui lòng nhập miêu tả hình ảnh",
                    ),
                    onChanged: (value) {
                      setState(() {
                        //_description = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    child: const Text('OK'),
                    onPressed: () {
                      validateTextField(_authorController.text, 'author');
                      validateTextField(_fileNameController.text, 'filename');

                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    child: const Text('cancel'),
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                  ),
                ],
              )
            ],
          );
        });
  }

  //validation
  bool validateTextField(String userInput, String field) {
    print('field: $field');
    if (userInput.isEmpty) {
      setState(() {
        //isUserNameValidate = true;
        switch (field) {
          case 'author':
            _authorValidation = true;
            break;
          case 'filename':
            _fileNameValidation = true;
            break;
        }
      });
      return true;
    }
    setState(() {
      //isUserNameValidate = false;
      switch (field) {
        case 'author':
          _authorValidation = false;
          break;
        case 'filename':
          _fileNameValidation = false;
          break;
      }
    });
    return false;
  }

  //download file
  Future<void> _dowloadFile(String url) async {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('chu boi doi'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.image)),
                Tab(icon: Icon(Icons.videocam)),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              //tab image
              HawkFabMenu(
                icon: AnimatedIcons.menu_arrow,
                fabColor: Colors.white,
                iconColor: Colors.green,
                items: [
                  HawkFabMenuItem(
                    label: 'home',
                    ontap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => super.widget));
                    },
                    icon: const Icon(Icons.home),
                    color: Colors.red,
                    labelColor: Colors.blue,
                  ),
                  HawkFabMenuItem(
                    label: 'thư viện ảnh',
                    ontap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      _upload('gallery', 'image');
                    },
                    icon: const Icon(Icons.broken_image_outlined),
                    labelColor: Colors.white,
                    labelBackgroundColor: Colors.blue,
                  ),
                  HawkFabMenuItem(
                    label: 'chụp ảnh',
                    ontap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      _upload('camera', 'image');
                    },
                    icon: const Icon(Icons.add_a_photo),
                  ),
                ],
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: FutureBuilder(
                          future: _loadImages(),
                          builder: (context,
                              AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return ListView.builder(
                                itemCount: snapshot.data?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final Map<String, dynamic> image =
                                      snapshot.data![index];
                                  return GestureDetector(
                                    child: Card(
                                      elevation: 5,
                                      // ignore: avoid_unnecessary_containers
                                      child: Container(
                                          child: Row(
                                        children: [
                                          Flexible(
                                            child: Container(
                                              height: 100.0,
                                              width: 70.0,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  bottomLeft:
                                                      Radius.circular(5),
                                                  topLeft: Radius.circular(5),
                                                ),
                                                image: DecorationImage(
                                                  fit: BoxFit.cover,
                                                  image: NetworkImage(
                                                      image['url']),
                                                ),
                                              ),
                                            ),
                                            flex: 2,
                                          ),
                                          Flexible(
                                            flex: 5,
                                            child: Container(
                                              height: 100,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        10, 2, 0, 0),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    Row(
                                                      children: [
                                                        const Text("Tên: "),
                                                        Text(
                                                          image['path'].length >
                                                                  MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width /
                                                                      10
                                                              ? image['path']
                                                                      .substring(
                                                                          0,
                                                                          10) +
                                                                  '...'
                                                              : image['path'],
                                                          maxLines: 1,
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 3, 0, 3),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        child: Row(
                                                          children: [
                                                            const Text(
                                                                "Đăng bởi: "),
                                                            Text(
                                                              image['uploaded_by'].length >
                                                                      MediaQuery.of(context)
                                                                              .size
                                                                              .width /
                                                                          2
                                                                  ? image['uploaded_by']
                                                                          .substring(
                                                                              0,
                                                                              10) +
                                                                      '...'
                                                                  : image[
                                                                      'uploaded_by'],
                                                              maxLines: 1,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(0, 5, 0, 2),
                                                      child: Container(
                                                        width: 260,
                                                        child: Row(
                                                          children: [
                                                            const Text(
                                                                "Chi tiết: "),
                                                            Text(
                                                              image['description'].length >
                                                                      20
                                                                  ? image['description']
                                                                          .substring(
                                                                              0,
                                                                              20) +
                                                                      '...'
                                                                  : image[
                                                                      'description'],
                                                              maxLines: 1,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Flexible(
                                              flex: 1,
                                              child: IconButton(
                                                color: Colors.red,
                                                icon: const Icon(Icons.delete),
                                                onPressed: () {
                                                  _delete(image['path_delete']);
                                                },
                                              )),
                                          Flexible(
                                              flex: 1,
                                              child: IconButton(
                                                color: Colors.red,
                                                icon:
                                                    const Icon(Icons.download),
                                                onPressed: () {
                                                  _dowloadFile(image['path']);
                                                },
                                              )),
                                        ],
                                      )),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenImage(
                                                      child: Image.network(
                                                          image['url']),
                                                      dark: true,
                                                      name: image['path'])));
                                    },
                                  );
                                },
                              );
                            }

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //tap video
              HawkFabMenu(
                icon: AnimatedIcons.menu_arrow,
                fabColor: Colors.white,
                iconColor: Colors.green,
                items: [
                  HawkFabMenuItem(
                    label: 'home',
                    ontap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) => super.widget));
                    },
                    icon: const Icon(Icons.home),
                    color: Colors.red,
                    labelColor: Colors.blue,
                  ),
                  HawkFabMenuItem(
                    label: 'thư viện video',
                    ontap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      _upload('gallery', 'video');
                    },
                    icon: const Icon(Icons.video_library_outlined),
                    labelColor: Colors.white,
                    labelBackgroundColor: Colors.blue,
                  ),
                  HawkFabMenuItem(
                    label: 'quay video',
                    ontap: () {
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      _upload('camera', 'video');
                    },
                    icon: const Icon(Icons.video_camera_back_outlined),
                  ),
                ],
                body: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Expanded(
                        child: FutureBuilder(
                          future: _loadVideos(),
                          builder: (context,
                              AsyncSnapshot<List<Map<String, dynamic>>>
                                  snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              return ListView.builder(
                                itemCount: snapshot.data?.length ?? 0,
                                itemBuilder: (context, index) {
                                  final Map<String, dynamic> video =
                                      snapshot.data![index];
                                  return GestureDetector(
                                    child: Card(
                                      elevation: 5,
                                      // ignore: avoid_unnecessary_containers
                                      child: Container(
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: Container(
                                                height: 100.0,
                                                width: 70.0,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      const BorderRadius.only(
                                                    bottomLeft:
                                                        Radius.circular(5),
                                                    topLeft: Radius.circular(5),
                                                  ),
                                                  image: DecorationImage(
                                                    fit: BoxFit.cover,
                                                    image: MemoryImage(
                                                        video['thumbnail']),
                                                    // image: AssetImage(
                                                    //     'assets/image/avatar.jpg'),
                                                  ),
                                                ),
                                              ),
                                              flex: 2,
                                            ),
                                            Flexible(
                                              flex: 5,
                                              child: Container(
                                                height: 100,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          10, 2, 0, 0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      Row(
                                                        children: [
                                                          const Text("Tên: "),
                                                          Text(
                                                            video['path']
                                                                        .length >
                                                                    20
                                                                ? video['path']
                                                                        .substring(
                                                                            0,
                                                                            20) +
                                                                    '...'
                                                                : video['path'],
                                                            maxLines: 1,
                                                          ),
                                                        ],
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 3, 0, 3),
                                                        child: Container(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width /
                                                              2,
                                                          child: Row(
                                                            children: [
                                                              const Text(
                                                                  "Đăng bởi: "),
                                                              Text(
                                                                video['uploaded_by']
                                                                            .length >
                                                                        MediaQuery.of(context).size.width /
                                                                            2
                                                                    ? video['uploaded_by'].substring(
                                                                            0,
                                                                            10) +
                                                                        '...'
                                                                    : video[
                                                                        'uploaded_by'],
                                                                maxLines: 1,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .fromLTRB(
                                                                0, 5, 0, 2),
                                                        child: Container(
                                                          width: 260,
                                                          child: Row(
                                                            children: [
                                                              const Text(
                                                                  "Chi tiết: "),
                                                              Text(
                                                                video['description']
                                                                            .length >
                                                                        MediaQuery.of(context).size.width /
                                                                            2
                                                                    ? video['description'].substring(
                                                                            0,
                                                                            10) +
                                                                        '...'
                                                                    : video[
                                                                        'description'],
                                                                maxLines: 1,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                                flex: 1,
                                                child: IconButton(
                                                  color: Colors.red,
                                                  icon:
                                                      const Icon(Icons.delete),
                                                  onPressed: () {
                                                    _delete(
                                                        video['path_delete']);
                                                  },
                                                )),
                                            Flexible(
                                                flex: 1,
                                                child: IconButton(
                                                  color: Colors.red,
                                                  icon: const Icon(
                                                      Icons.download),
                                                  onPressed: () {
                                                    _dowloadFile(video['path']);
                                                  },
                                                )),
                                          ],
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      print('video:' + video.toString());
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  FullScreenVideo(
                                                    url: video['url'],
                                                    name: video['path'],
                                                  )));
                                    },
                                  );
                                },
                              );
                            }

                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
