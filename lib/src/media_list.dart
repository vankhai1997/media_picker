import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../media_picker_widget.dart';
import 'header_controller.dart';
import 'widgets/media_tile.dart';

class MediaList extends StatefulWidget {
  MediaList({
    required this.album,
    required this.headerController,
    required this.previousList,
    this.mediaCount,
    this.decoration,
    this.maxSelected,
    this.scrollController,
  });

  final AssetPathEntity album;
  final HeaderController headerController;
  final List<Media> previousList;
  final MediaCount? mediaCount;
  final PickerDecoration? decoration;
  final ScrollController? scrollController;
  final int? maxSelected;

  @override
  _MediaListState createState() => _MediaListState();
}

class _MediaListState extends State<MediaList> {
  List<AssetEntity> _mediaList = [];
  int currentPage = 0;
  int? lastPage;
  AssetPathEntity? album;

  List<Media> selectedMedias = [];

  @override
  void initState() {
    album = widget.album;
    _fetchNewMedia();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _resetAlbum();
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scroll) {
        _handleScrollEvent(scroll);
        return true;
      },
      child: GridView.builder(
        physics: BouncingScrollPhysics(),
        controller: widget.scrollController,
        itemCount: _mediaList.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
            crossAxisCount: widget.decoration!.columnCount),
        itemBuilder: (BuildContext context, int index) {
          return MediaTile(
            totalSelect: selectedMedias.length,
            maxSelect: widget.maxSelected,
            media: _mediaList[index],
            onSelected: (isSelected, media) {
              if (isSelected) {
                setState(() => selectedMedias.add(media));
                } else
                setState(() => selectedMedias
                    .removeWhere((_media) => _media.id == media.id));
              widget.headerController.updateSelection!(selectedMedias);
            },
            isSelected: isPreviouslySelected(_mediaList[index]),
            decoration: widget.decoration,
          );
        },
      ),
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

  _handleScrollEvent(ScrollNotification scroll) {
    if (scroll.metrics.pixels / scroll.metrics.maxScrollExtent > 0.33) {
      if (currentPage != lastPage) {
        _fetchNewMedia();
      }
    }
  }

  _fetchNewMedia() async {
    lastPage = currentPage;
    var result = await PhotoManager.requestPermission();
    if (result) {
      List<AssetEntity> media = await album!.getAssetListPaged(currentPage, 60);

      setState(() {
        _mediaList.addAll(media);
        currentPage++;
      });
    } else {
      PhotoManager.openSetting();
    }
  }

  bool isPreviouslySelected(AssetEntity media) {
    bool isSelected = false;
    for (var asset in selectedMedias) {
      if (asset.id == media.id) isSelected = true;
    }
    return isSelected;
  }
}
