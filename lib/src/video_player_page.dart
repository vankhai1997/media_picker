import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VideoPlayerPage extends StatefulWidget {
  final File file;
  final double aspect;

  const VideoPlayerPage({Key? key, required this.file, required this.aspect})
      : super(key: key);

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 1/widget.aspect,
      fit: BoxFit.contain,
    );

    _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
    _setupDataSource();
    super.initState();
  }

  void _setupDataSource() async {
    List<int> bytes = widget.file.readAsBytesSync().buffer.asUint8List();
    BetterPlayerDataSource dataSource = BetterPlayerDataSource.memory(bytes);
    _betterPlayerController.setupDataSource(dataSource);
  }

  @override
  Widget build(BuildContext context) {
    return BetterPlayer(controller: _betterPlayerController);
  }
}
