import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_picker_widget/media_picker_widget.dart';
import 'package:media_picker_widget/src/utils.dart';
import 'package:photo_manager/photo_manager.dart';

import 'video_player_page.dart';
import 'widgets/simple_interactive_gallery_viewer.dart';

class MediaDetail extends StatefulWidget {
  final AssetEntity assetEntity;

  const MediaDetail({Key? key, required this.assetEntity}) : super(key: key);

  @override
  State<MediaDetail> createState() => _MediaDetailState();
}

class _MediaDetailState extends State<MediaDetail> {
  Media? media;

  @override
  void initState() {
    _initFile();
    super.initState();
  }

  Future<void> _initFile() async {
    media = await MediaPickerUtils.convertToMedia2(media: widget.assetEntity);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark));
    return Scaffold(
      body: Stack(
        children: [
          SimpleInteractiveViewerGallery(
            initIndex: 0,
            sources: [media?.path ?? ""],
            itemBuilder: (BuildContext context, int index, bool isFocus) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Center(
                  child: Builder(builder: (c) {
                    if (media == null) return const SizedBox();
                    if (media!.mediaType == 'video') {
                      return VideoPlayerPage(
                        file: File(media!.path ?? ""),
                        aspect: widget.assetEntity.width /
                            widget.assetEntity.height,
                      );
                    }
                    return Image.file(File(media!.path ?? ""));
                  }),
                ),
              );
            },
          ),
          SafeArea(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                Navigator.pop(context);
              },
              child: Icon(
                Icons.close,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
