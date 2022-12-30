part of media_picker_widget;

class MediaPicker extends StatefulWidget {
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
  _MediaPickerState createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  PickerDecoration? decoration;

  AssetPathEntity? selectedAlbum;
  List<AssetPathEntity>? _albums;

  PanelController albumController = PanelController();
  HeaderController headerController = HeaderController();
  bool _showWarning = false;

  @override
  void initState() {
    _fetchAlbums();
    decoration = widget.decoration ?? PickerDecoration();
    super.initState();
  }

  @override
  void dispose() {
    StateBehavior.clearAssetEntitiesSelected();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _albums == null
          ? CupertinoActivityIndicator()
          : _albums!.isEmpty
              ? NoMedia()
              : Column(
                  children: [
                    if (decoration!.actionBarPosition == ActionBarPosition.top)
                      _buildWarning(),
                    Expanded(
                      child: MediaList(
                        maxSelected: widget.maxSelect,
                        album: selectedAlbum!,
                        mediaCount: widget.mediaCount,
                        decoration: widget.decoration,
                        onTapCamera: () {
                          _openCamera(onCapture: widget.captureCamera);
                        },
                        onPick: widget.onPick,
                      ),
                    ),
                  ],
                ),
    );
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
      StateBehavior.clearAssetEntitiesSelected();
      onCapture([converted]);
    }
  }

  Widget _buildWarning() {
    return Visibility(
      visible: _showWarning,
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

  Widget _buildHeader() {
    return Header(
      onBack: handleBackPress,
      onDone: () {},
      albumController: albumController,
      selectedAlbum: selectedAlbum!,
      controller: headerController,
      mediaCount: widget.mediaCount,
      decoration: decoration,
    );
  }

  _fetchAlbums() async {
    RequestType type = RequestType.common;
    if (widget.mediaType == MediaType.all)
      type = RequestType.common;
    else if (widget.mediaType == MediaType.video)
      type = RequestType.video;
    else if (widget.mediaType == MediaType.image) type = RequestType.image;
    var result = await PhotoManager.requestPermissionExtend();
    if (result == PermissionState.limited) {
      setState(() {
        _showWarning = true;
      });
    }
    if (result == PermissionState.limited ||
        result == PermissionState.authorized) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: type, onlyAll: true);
      setState(() {
        _albums = albums;
        if (albums.isEmpty) return;
        selectedAlbum = _albums![0];
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  void handleBackPress() {
    if (albumController.isPanelOpen)
      albumController.close();
    else
      widget.onCancel();
  }
}
