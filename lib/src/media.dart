part of media_picker_widget;

class Media {
  File? file;
  String? id;
  Uint8List? thumbnail;
  Uint8List? mediaByte;
  Size? size;
  int? length;
  DateTime? creationTime;
  String? title;
  MediaType? mediaType;

  Media({
    this.id,
    this.file,
    this.thumbnail,
    this.mediaByte,
    this.length,
    this.size,
    this.creationTime,
    this.title,
    this.mediaType,
  });
}
