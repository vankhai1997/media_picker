import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../media_picker_widget.dart';
import 'loading_widget.dart';

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
  final Function(bool, Media) onSelected;
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
  Media? media;
  Duration _duration = Duration(milliseconds: 100);

  @override
  void initState() {
    selected = widget.isSelected;
    _initFile();
    super.initState();
  }

  Future<void> _initFile() async {
    final res = await convertToMedia(media: widget.media);
    if (mounted) {
      setState(() {
        media = res;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Stack(
        children: [
          Positioned.fill(
              child: InkWell(
            onTap: () {
              if (media == null) return;
              if ((widget.totalSelect ?? 0) >= (widget.maxSelect ?? 1000000) &&
                  !selected!) return;
              setState(() => selected = !selected!);
              widget.onSelected(selected!, media!);
            },
            child: Stack(
              children: [
                media == null
                    ? LoadingWidget(
                        decoration: widget.decoration,
                      )
                    : Positioned.fill(
                        child: Image.memory(
                        media!.thumbnail!,
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
  }

  @override
  bool get wantKeepAlive => true;
}

Future<Media> convertToMedia({required AssetEntity media}) async {
  Media convertedMedia = Media();
  convertedMedia.thumbnail = (await media
      .thumbnailDataWithSize(ThumbnailSize(960, 1280), quality: 45));
  convertedMedia.path = (await media.file)!.path;
  convertedMedia.id = media.id;
  convertedMedia.size = media.size;
  convertedMedia.title = media.title;
  convertedMedia.creationTime = media.createDateTime;
  String? mediaType;
  if (media.type == AssetType.video) mediaType = 'video';
  if (media.type == AssetType.image) mediaType = 'image';
  convertedMedia.mediaType = mediaType;
  return convertedMedia;
}
