part of media_picker_widget;



class MediaPicker extends StatelessWidget {
  MediaPicker({
    required this.onPick,
    required this.onCancel,
    this.mediaCount = MediaCount.multiple,
    this.mediaType = MediaType.all,
    this.decoration,
    this.scrollController,
    this.maxSelect,
    required this.captureCamera,
  });

  final ValueChanged<List<Media>> onPick;
  final ValueChanged<List<Media>> captureCamera;
  final VoidCallback onCancel;
  final MediaCount mediaCount;
  final MediaType mediaType;
  final PickerDecoration? decoration;
  final ScrollController? scrollController;
  final int? maxSelect;
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: GetBuilder<MediaController>(
          init: MediaController(mediaType),
          global: false,
          builder: (controller) {
            return controller.albums == null
                ? CupertinoActivityIndicator()
                : controller.emptyData
                    ? NoMedia()
                    : Column(
                        children: [
                          if (decoration!.actionBarPosition ==
                              ActionBarPosition.top)
                            _buildWarning(controller.showWarning),
                          Expanded(
                            child: MediaList(
                              maxSelected: maxSelect,
                              album: controller.albums!,
                              mediaCount: mediaCount,
                              decoration: decoration,
                              onTapCamera: () {
                                _openCamera(onCapture: captureCamera);
                              },
                              onPick: onPick,
                              controller: controller,
                            ),
                          ),
                        ],
                      );
          },
        ));
  }

  _openCamera({required ValueChanged<List<Media>> onCapture}) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        maxHeight: 1024,
        maxWidth: 896,
        imageQuality: 90);
    if (pickedFile != null) {
      Media converted = Media(
        id: UniqueKey().toString(),
        creationTime: DateTime.now(),
        path: pickedFile.path,
        thumbPath: pickedFile.path,
        mediaType: 'image',
        width: 896,
        height: 1024,
        title: pickedFile.path,
      );
      onCapture([converted]);
    }
  }

  Widget _buildWarning(bool showWarning) {
    return Visibility(
      visible: showWarning,
      child: Container(
          color: Color(0xFFE5E9F2),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: RichText(
            text: new TextSpan(
                text: decoration?.warningText,
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1C2433)),
                children: [
                  new TextSpan(
                    text: 'Thay đổi quyền tại đây',
                    style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF2174E2)),
                    recognizer: new TapGestureRecognizer()
                      ..onTap = () => PhotoManager.openSetting(),
                  )
                ]),
          )),
    );
  }
}
