import 'package:photo_manager/photo_manager.dart';

import '../media_picker_widget.dart';

class MediaPickerUtils {
  static Future<Media> convertToMedia({required AssetEntity media}) async {
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

  static Future<Media> convertToMedia2({required AssetEntity media}) async {
    Media convertedMedia = Media();
    convertedMedia.path = (await media.file)!.path;
    convertedMedia.id = media.id;
    String? mediaType;
    if (media.type == AssetType.video) mediaType = 'video';
    if (media.type == AssetType.image) mediaType = 'image';
    convertedMedia.mediaType = mediaType;
    return convertedMedia;
  }

  static String intTimeHs(int time) {
    final duration = Duration(seconds: time);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
