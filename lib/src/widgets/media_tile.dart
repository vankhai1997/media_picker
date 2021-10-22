import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../media_picker_widget.dart';

class MediaTile extends StatefulWidget {
  MediaTile({
    Key? key,
    required this.media,
    required this.onSelected,
    this.isSelected = false,
    this.decoration,
    this.maxSelect,
    this.totalSelect,
  }) : super(key: key);

  final AssetEntity media;
  final Function(bool, AssetEntity) onSelected;
  final bool isSelected;
  final PickerDecoration? decoration;
  final int? maxSelect;
  final int? totalSelect;

  @override
  _MediaTileState createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  bool? selected;
  Uint8List? file;
  Duration _duration = Duration(milliseconds: 100);

  @override
  void initState() {
    selected = widget.isSelected;
    _initFile();
    super.initState();
  }

  Future<void> _initFile() async {
    final res = await widget.media.thumbDataWithSize(250, 250);
    setState(() {
      file = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: file == null
          ? CupertinoActivityIndicator()
          : Stack(
              children: [
                Positioned.fill(
                    child: InkWell(
                  onTap: () {
                    if ((widget.totalSelect ?? 0) >=
                            (widget.maxSelect ?? 10000) &&
                        !selected!) return;
                    setState(() => selected = !selected!);
                    widget.onSelected(selected!, widget.media);
                  },
                  child: Stack(
                    children: [
                      Positioned.fill(
                          child: Image.memory(
                        file!,
                        fit: BoxFit.cover,
                        cacheWidth: 200,
                      )),
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: selected! ? 1 : 0,
                          curve: Curves.easeOut,
                          duration: _duration,
                          child: ClipRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                  sigmaX: widget.decoration!.blurStrength,
                                  sigmaY: widget.decoration!.blurStrength),
                              child: Container(
                                color: Colors.black26,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (widget.media.type == AssetType.video)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: EdgeInsets.only(right: 5, bottom: 5),
                            child: Icon(
                              Icons.videocam,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                )),
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: AnimatedOpacity(
                      curve: Curves.easeOut,
                      duration: _duration,
                      opacity: selected! ? 1 : 0,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle),
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          Icons.done,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
    // else {
    //   convertToMedia(media: widget.media)
    //       .then((_media) => setState(() => media = _media));
    //   return LoadingWidget(
    //     decoration: widget.decoration!,
    //   );
    // }
  }

  @override
  bool get wantKeepAlive => true;
}

Future<Media> convertToMedia({required AssetEntity media}) async {
  Media convertedMedia = Media();
  convertedMedia.mediaByte = (await media.thumbDataWithSize(1024, 1024));
  convertedMedia.id = media.id;
  convertedMedia.size = media.size;
  convertedMedia.title = media.title;
  convertedMedia.creationTime = media.createDateTime;
  MediaType mediaType = MediaType.all;
  if (media.type == AssetType.video) mediaType = MediaType.video;
  if (media.type == AssetType.image) mediaType = MediaType.image;
  convertedMedia.mediaType = mediaType;

  return convertedMedia;
}
