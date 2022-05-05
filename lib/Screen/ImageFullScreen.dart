import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullScreenImage extends StatefulWidget {
  FullScreenImage({
    required this.child,
    required this.dark,
    required this.name,
  });

  final Image child;
  final bool dark;
  final String name;

  @override
  _FullScreenImageState createState() => _FullScreenImageState();
}

class _FullScreenImageState extends State<FullScreenImage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(widget.name)),
        backgroundColor: widget.dark ? Colors.black : Colors.white,
        body: Center(
          child: Stack(
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
                      child: widget.child,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
