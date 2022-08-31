import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_picker_widget/src/state_behavior.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

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
    required this.selectedMedias,
  }) : super(key: key);

  final AssetEntity media;
  final Function(bool, Media) onSelected;
  final bool isSelected;
  final PickerDecoration? decoration;
  final int? maxSelect;
  final int? totalSelect;
  final List<Media> selectedMedias;

  @override
  _MediaTileState createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  final selectedBehavior = BehaviorSubject<bool>.seeded(false);

  Stream<bool> get selectedStream => selectedBehavior.stream;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      StateBehavior.listenState((selected) {
        if (selectedBehavior.isClosed) return;
        selectedBehavior.add(selected.indexWhere((e) => e.id==widget.media.id,)!=-1);
      });
      selectedBehavior.add(widget.isSelected);
    });
    // _initFile();
    super.initState();
  }

  Future<Uint8List?> _getAssetThumbnail(AssetEntity asset) async {
    return await asset.thumbnailDataWithSize(ThumbnailSize(250, 250),
        quality: 80);
  }

  @override
  void dispose() {
    selectedBehavior.close();
    super.dispose();
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
              onTapItem();
            },
            child: Stack(
              children: [
                FutureBuilder<Uint8List?>(
                    future: _getAssetThumbnail(widget.media),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Positioned.fill(
                          child: Image.memory(
                            snapshot.data!,
                            fit: BoxFit.cover,
                          ),
                        );
                      }
                      return LoadingWidget(
                        decoration: widget.decoration,
                      );
                    }),
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
              padding: const EdgeInsets.all(6),
              child: InkWell(
                onTap: () {
                  onTapItem();
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle),
                    child: StreamBuilder<bool>(
                        stream: selectedStream,
                        builder: (context, snapshot) {
                          return AnimatedCrossFade(
                            duration: const Duration(milliseconds: 250),
                            crossFadeState: (snapshot.data ?? false)
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                            secondChild: AnimatedContainer(
                              alignment: Alignment.center,
                              child: !(snapshot.data ?? false)
                                  ? const SizedBox()
                                  : Text(
                                      '$indexSelected',
                                      style: TextStyle(color: Colors.white),
                                    ),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  shape: BoxShape.circle),
                              height: (snapshot.data ?? false) ? 20 : 20,
                              width: (snapshot.data ?? false) ? 20 : 20,
                              duration: const Duration(milliseconds: 250),
                            ),
                            firstChild: SizedBox(
                              height: 20,
                              width: 20,
                            ),
                          );
                        })),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> onTapItem() async {
    if ((widget.selectedMedias.length) >= (widget.maxSelect ?? 1000000) &&
        !selectedBehavior.value) return;
    final res = await convertToMedia(media: widget.media);
    if ((widget.selectedMedias.length) >= (widget.maxSelect ?? 1000000) &&
        !selectedBehavior.value) return;
    widget.onSelected(!selectedBehavior.value, res);
  }

  int get indexSelected {
    return widget.selectedMedias
            .map((e) => e.id)
            .toList()
            .indexOf(widget.media.id) +
        1;
  }

  @override
  bool get wantKeepAlive => true;
}

Future<Media> convertToMedia({required AssetEntity media}) async {
  Media convertedMedia = Media();
  convertedMedia.thumbnail = (await media
      .thumbnailDataWithSize(ThumbnailSize(960, 1280), quality: 40));
  convertedMedia.path = (await media.file)!.path;
  convertedMedia.id = media.id;
  convertedMedia.size = media.size;
  convertedMedia.duration = media.duration;
  convertedMedia.title = media.title;
  convertedMedia.creationTime = media.createDateTime;
  String? mediaType;
  if (media.type == AssetType.video) mediaType = 'video';
  if (media.type == AssetType.image) mediaType = 'image';
  convertedMedia.mediaType = mediaType;
  return convertedMedia;
}
//
// Future<File?> resizeImage(String path, {bool isThumb = false}) async {
//   try {
//     final filename = path.split("/").last.split('.').first;
//     final _exist = await checkFileImageExist(filename, ext: 'jpeg');
//     if (_exist != null) {
//       return _exist;
//     }
//     final compressedFile = await FlutterImageCompress.compressWithFile(
//       path,
//       quality: isThumb ? 40 : 95,
//       minHeight: 1280,
//       minWidth: 960,
//     );
//     return byteToImageFile(
//       filename,
//       compressedFile!,
//       isThumb: isThumb,
//     );
//   } catch (e) {
//     return File(path);
//   }
// }
//
// Future<File?> checkFileImageExist(String fileName,
//     {String? ext, String? originPath}) async {
//
//   final tempDir = await PathUtils.fileLocalPathCache();
//   final _path =
//       '$tempDir${Platform.pathSeparator}$fileName${ext == null ? '' : '.$ext'}';
//   final file = File(_path);
//   final ex = file.existsSync();
//   if (ex) {
//     return file;
//   }
//   return null;
// }
