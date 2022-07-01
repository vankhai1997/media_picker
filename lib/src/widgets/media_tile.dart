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
  bool? selected;
  Media? media;

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
                  if (media == null) return;
                  if ((widget.totalSelect ?? 0) >=
                          (widget.maxSelect ?? 1000000) &&
                      !selected!) return;
                  setState(() => selected = !selected!);
                  widget.onSelected(selected!, media!);
                },
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.2),
                        border: Border.all(color: Colors.white, width: 2),
                        shape: BoxShape.circle),
                    child: AnimatedCrossFade(
                      duration: const Duration(milliseconds: 250),
                      crossFadeState: (selected ?? false)
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      secondChild: AnimatedContainer(
                        alignment: Alignment.center,
                        child: media == null || !(selected ?? false)
                            ? const SizedBox()
                            : Text(
                                '${widget.selectedMedias.indexOf(media!) + 1}',
                                style: TextStyle(color: Colors.white),
                              ),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle),
                        height: (selected ?? false) ? 20 : 20,
                        width: (selected ?? false) ? 20 : 20,
                        duration: const Duration(milliseconds: 250),
                      ),
                      firstChild: SizedBox(
                        height: 20,
                        width: 20,
                      ),
                    )),
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
