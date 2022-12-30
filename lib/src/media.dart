part of media_picker_widget;

class Media extends Equatable {
  String? path;
  String? id;

  int? width;
  int? height;
  int? length;
  int? duration;
  int? index;
  DateTime? creationTime;
  String? title;
  String? thumbPath;
  String? md5;
  String? mediaType;

  Media({
    this.id,
    this.path,
    this.length,
    this.duration,
    this.md5,
    this.thumbPath,
    this.height,
    this.width,
    this.index,
    this.creationTime,
    this.title,
    this.mediaType,
  });

  @override
  List<Object?> get props => [path];
}
