part of media_picker_widget;

class Media {
  String ? path;
  String? id;
  Uint8List? thumbnail;
  Uint8List? mediaByte;
  Size? size;
  int? length;
  int? index;
  DateTime? creationTime;
  String? title;
  String? md5;
  String? mediaType;

  Media({
    this.id,
    this.path,
    this.thumbnail,
    this.mediaByte,
    this.length,
    this.md5,
    this.size,
    this.index,
    this.creationTime,
    this.title,
    this.mediaType,
  });
}
