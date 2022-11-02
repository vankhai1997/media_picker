part of media_picker_widget;

class Media extends Equatable {
  String? path;
  String? id;
  Uint8List? thumbnail;
  Uint8List? mediaByte;
  Size? size;
  int? length;
  int? duration;
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
    this.duration,
    this.md5,
    this.size,
    this.index,
    this.creationTime,
    this.title,
    this.mediaType,
  });

  @override
  List<Object?> get props => [path];
}
