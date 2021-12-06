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

  final ValueChanged<List<AssetEntity>> onPick;
  final ValueChanged<Media> captureCamera;
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

  @override
  void initState() {
    _fetchAlbums();
    decoration = widget.decoration ?? PickerDecoration();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: _albums == null
          ? LoadingWidget(
              decoration: widget.decoration!,
            )
          : _albums!.isEmpty
              ? NoMedia()
              : Column(
                  children: [
                    if (decoration!.actionBarPosition == ActionBarPosition.top)
                      _buildHeader(),
                    Expanded(
                        child: Stack(
                      children: [
                        Positioned.fill(
                          child: MediaList(
                            maxSelected: widget.maxSelect,
                            album: selectedAlbum!,
                            headerController: headerController,
                            mediaCount: widget.mediaCount,
                            decoration: widget.decoration,
                            scrollController: widget.scrollController,
                            onTapCamera: () {
                              _openCamera(onCapture: widget.captureCamera);
                            },
                          ),
                        ),
                        AlbumSelector(
                          panelController: albumController,
                          albums: _albums!,
                          decoration: widget.decoration!,
                          onSelect: (album) {
                            headerController.closeAlbumDrawer!();
                            setState(() => selectedAlbum = album);
                          },
                        ),
                      ],
                    )),
                    if (decoration!.actionBarPosition ==
                        ActionBarPosition.bottom)
                      _buildHeader(),
                  ],
                ),
    );
  }

  _openCamera({required ValueChanged<Media> onCapture}) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      Media converted = Media(
        id: UniqueKey().toString(),
        thumbnail: await pickedFile.readAsBytes(),
        creationTime: DateTime.now(),
        path: pickedFile.path,
        mediaByte: await pickedFile.readAsBytes(),
        title: 'capturedImage',
      );
      onCapture(converted);
    }
  }

  Widget _buildHeader() {
    return Header(
      onBack: handleBackPress,
      onDone: widget.onPick,
      albumController: albumController,
      selectedAlbum: selectedAlbum!,
      controller: headerController,
      mediaCount: widget.mediaCount,
      decoration: decoration,
    );
  }

  _fetchAlbums() async {
    PhotoManager.clearFileCache();
    RequestType type = RequestType.common;
    if (widget.mediaType == MediaType.all)
      type = RequestType.common;
    else if (widget.mediaType == MediaType.video)
      type = RequestType.video;
    else if (widget.mediaType == MediaType.image) type = RequestType.image;

    var result = await PhotoManager.requestPermission();
    if (result) {
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
