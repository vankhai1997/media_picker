import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class VIdeoPlayerPage extends StatefulWidget {
  final File file;
  final double aspect;

  const VIdeoPlayerPage({Key? key, required this.file, required this.aspect})
      : super(key: key);

  @override
  _VIdeoPlayerPageState createState() => _VIdeoPlayerPageState();
}

class _VIdeoPlayerPageState extends State<VIdeoPlayerPage> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: widget.aspect,
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
    return AspectRatio(
      aspectRatio: widget.aspect,
      child: BetterPlayer(controller: _betterPlayerController),
    );
  }
}
