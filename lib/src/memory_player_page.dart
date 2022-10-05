import 'dart:io';

import 'package:better_player/better_player.dart';
import 'package:flutter/material.dart';

class MemoryPlayerPage extends StatefulWidget {
  final File file;

  const MemoryPlayerPage({Key? key, required this.file}) : super(key: key);

  @override
  _MemoryPlayerPageState createState() => _MemoryPlayerPageState();
}

class _MemoryPlayerPageState extends State<MemoryPlayerPage> {
  late BetterPlayerController _betterPlayerController;

  @override
  void initState() {
    BetterPlayerConfiguration betterPlayerConfiguration =
        BetterPlayerConfiguration(
      aspectRatio: 16 / 9,
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
      aspectRatio: 16 / 9,
      child: BetterPlayer(controller: _betterPlayerController),
    );
  }
}
