import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

import '../media_picker_widget.dart';

class MediaPickerUtils {
  static Future<Media> convertToMedia({required AssetEntity media}) async {
    Media convertedMedia = Media();
    String? mediaType;
    if (media.type == AssetType.video) mediaType = 'video';
    if (media.type == AssetType.image) mediaType = 'image';
    convertedMedia.mediaType = mediaType;

    if (media.type == AssetType.image) {
      final _originFile = (await media
          .thumbnailDataWithSize(ThumbnailSize(960, 1280), quality: 95));
      final _file =
          await _byteToImageFile(media.id, _originFile!, isThumb: false);
      convertedMedia.path = _file.path;
    } else {
      convertedMedia.path = (await media.file)!.path;
    }
    final _thumbByte = (await media
        .thumbnailDataWithSize(ThumbnailSize(960, 1280), quality: 40));

    final _thumbFile =
        await _byteToImageFile(media.id, _thumbByte!, isThumb: true);

    convertedMedia.thumbPath = _thumbFile.path;
    final wh = await _getWHImage(_thumbFile.path);
    convertedMedia.id = media.id;
    convertedMedia.width = wh.width;
    convertedMedia.height = wh.height;
    convertedMedia.duration = media.duration;
    convertedMedia.title = media.title;
    convertedMedia.creationTime = media.createDateTime;
    convertedMedia.creationTime = media.createDateTime;
    print('MediaPickerUtils.convertToMedia  ${convertedMedia.thumbPath}');
    return convertedMedia;
  }

  static Future<ui.Image> _getWHImage(String path) async {
    final image = File(path); // Or any other way to get a File instance.
    final decodedImage = await decodeImageFromList(image.readAsBytesSync());
    return decodedImage;
  }

  static Future<String> _fileLocalPathCache() async {
    if (Platform.isMacOS) {
      return '';
    }
    Directory? tempDir;

    if (Platform.isAndroid) {
      tempDir = await getExternalStorageDirectory();
    } else {
      tempDir = await getApplicationDocumentsDirectory();
    }
    final _localPath = '${tempDir?.path}${Platform.pathSeparator}caches';
    final savedDir = Directory(_localPath);
    final bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.createSync();
    }
    return _localPath;
  }

  static Future<File> _byteToImageFile(
      String fileName, Uint8List compressedFile,
      {String ext = 'jpeg', bool isThumb = false}) async {
    final tempDir = await _fileLocalPathCache();
    final _rename = "${fileName.split('/').first}${isThumb ? 'thumb' : ""}";
    final File file = File('$tempDir${Platform.pathSeparator}$_rename.$ext');
    final _exist = await _checkFileImageExist(_rename, ext: ext);
    if (_exist != null) {
      return file;
    }
    file.writeAsBytesSync(compressedFile);
    return file;
  }

  static Future<File?> _checkFileImageExist(String fileName,
      {String? ext}) async {
    final tempDir = await _fileLocalPathCache();
    final _path =
        '$tempDir${Platform.pathSeparator}$fileName${ext == null ? '' : '.$ext'}';
    final file = File(_path);
    final ex = file.existsSync();
    if (ex) {
      return file;
    }
    return null;
  }

  static String intTimeHs(int time) {
    final duration = Duration(seconds: time);
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    final String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
