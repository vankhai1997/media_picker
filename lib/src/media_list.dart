import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:media_picker_widget/src/utils.dart';
import 'package:photo_manager/photo_manager.dart';
import '../media_picker_widget.dart';
import 'header_controller.dart';
import 'state_behavior.dart';
import 'widgets/media_tile.dart';

class MediaList extends StatefulWidget {
  MediaList({
    required this.album,
    this.mediaCount,
    this.decoration,
    this.maxSelected,
    this.scrollController,
    required this.onTapCamera,
    required this.onPick,
  });

  final AssetPathEntity album;
  final MediaCount? mediaCount;
  final PickerDecoration? decoration;
  final ScrollController? scrollController;
  final Function() onTapCamera;
  final Function(List<Media> medias) onPick;
  final int? maxSelected;

  @override
  _MediaListState createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  List<AssetEntity> _mediaList = [];
  int currentPage = 0;
  int? lastPage;
  bool empty = false;
  AssetPathEntity? album;
  List<Media> _selectedMedias = [];

  @override
  void initState() {
    album = widget.album;
    _fetchNewMedia();
    _handleSinkDataSelected();
    super.initState();
  }

  void _handleSinkDataSelected() {
    StateBehavior.onChangeAssetEntitiesSelected((medias) async {
      final tempId = StateBehavior.templesSelected.map((e) => e.id).toList();
      final selectedId =
          StateBehavior.assetEntitiesSelected.map((e) => e.id).toList();
      _selectedMedias.removeWhere((e) => !selectedId.contains(e.id));
      while (StateBehavior.templesSelected.isNotEmpty) {
        final first = StateBehavior.templesSelected.first;
        final _media = await MediaPickerUtils.convertToMedia(media: first);
        if (tempId.contains(_media.id)) {
          _selectedMedias.add(_media);
        }
        StateBehavior.removeTempleSelectedById(_media.id ?? "");
      }
    });
  }

  @override
  void didUpdateWidget(covariant MediaList oldWidget) {
    _resetAlbum();
    super.didUpdateWidget(oldWidget);
  }

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GridView.builder(
          controller: widget.scrollController,
          addAutomaticKeepAlives: false,
          itemCount: _mediaList.length + 1,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
              crossAxisCount: widget.decoration!.columnCount),
          itemBuilder: (BuildContext context, int i) {
            if (i == 0) {
              return InkWell(
                onTap: widget.onTapCamera,
                child: Stack(
                  alignment: Alignment.center,
                  fit: StackFit.expand,
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.camera_alt,
                            size: 36,
                            color: Colors.black.withOpacity(0.5),
                          ),
                          Text(
                            'Chụp ảnh',
                            style: TextStyle(
                                color: Colors.black.withOpacity(0.5),
                                fontSize: 16),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            }
            final index = i - 1;
            if (index == _mediaList.length - 20 && !empty) {
              _fetchNewMedia();
            }
            return MediaTile(
              maxSelect: widget.maxSelected,
              assetEntity: _mediaList[index],
              decoration: widget.decoration,
            );
          },
        ),
        Positioned(
            bottom: 8 + MediaQuery.of(context).padding.bottom,
            left: 32,
            right: 32,
            child: _ButtonSendImage(
              onPick: () {
                widget.onPick(_selectedMedias.toSet().toList());
              },
            ))
      ],
    );
  }

  _resetAlbum() {
    if (album != null) {
      if (album!.id != widget.album.id) {
        _mediaList.clear();
        album = widget.album;
        currentPage = 0;
        _fetchNewMedia();
      }
    }
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermissionExtend();
    if (result == PermissionState.limited ||
        result == PermissionState.authorized) {
      List<AssetEntity> media =
          await album!.getAssetListPaged(page: currentPage, size: 80);
      setState(() {
        empty = media.isEmpty;
        _mediaList.addAll(media);
        currentPage++;
      });
    } else {
      PhotoManager.openSetting();
    }
  }
}

class _ButtonSendImage extends StatelessWidget {
  final Function() onPick;

  const _ButtonSendImage({Key? key, required this.onPick}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<AssetEntity>>(
        stream: StateBehavior.templesSelectedStream,
        builder: (context, snapshot) {
          final data = snapshot.data ?? [];
          final selected = StateBehavior.assetEntitiesSelected.length;
          if (selected == 0) return const SizedBox();
          return SlideInUp(
            child: TextButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all(Theme.of(context).primaryColor),
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6))),
              ),
              onPressed: () {
                if (data.isNotEmpty) return;
                onPick();
              },
              child: Builder(
                builder: (BuildContext context) {
                  if (data.isEmpty) {
                    return Text(
                      'Gửi $selected',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400),
                    );
                  }
                  return SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.white,
                      strokeWidth: 3,
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
