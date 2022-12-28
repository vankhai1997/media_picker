import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:media_picker_widget/src/state_behavior.dart';
import 'package:media_picker_widget/src/utils.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../media_picker_widget.dart';

class MediaTile extends StatefulWidget {
  MediaTile({
    Key? key,
    required this.assetEntity,
    this.decoration,
    this.maxSelect,
  }) : super(key: key);

  final AssetEntity assetEntity;
  final PickerDecoration? decoration;
  final int? maxSelect;

  @override
  _MediaTileState createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  Uint8List? data;

  Future<Uint8List?> _getAssetThumbnail(AssetEntity asset) async {
    if (data == null) {
      data = await asset.thumbnailDataWithSize(ThumbnailSize(195, 195),
          quality: 100);
    }

    return data;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      key: widget.key,
      padding: const EdgeInsets.all(0.5),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
                child: Image(
              image: AssetEntityImageProvider(widget.assetEntity,
                  thumbnailSize: ThumbnailSize(195, 195), isOriginal: false),
              fit: BoxFit.cover,
            )),
          ),
          StreamBuilder<List<AssetEntity>>(
              stream: StateBehavior.assetEntitiesSelectedStream,
              builder: (context, snapshot) {
                final selected = (snapshot.data ?? [])
                        .indexWhere((e) => e.id == widget.assetEntity.id) !=
                    -1;
                return selected
                    ? AnimatedOpacity(
                        opacity: selected ? 1 : 0,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          color: Colors.white.withOpacity(0.4),
                        ),
                      )
                    : SizedBox();
              }),
          if (widget.assetEntity.type == AssetType.video)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: Colors.black.withOpacity(0.3)),
                  child: Text(
                      MediaPickerUtils.intTimeHs(widget.assetEntity.duration),
                      style: TextStyle(color: Colors.white, fontSize: 10))),
            ),
          Align(
            alignment: Alignment.topRight,
            child: StreamBuilder<List<AssetEntity>>(
                stream: StateBehavior.assetEntitiesSelectedStream,
                builder: (context, snapshot) {
                  final selected = (snapshot.data ?? [])
                          .indexWhere((e) => e.id == widget.assetEntity.id) !=
                      -1;
                  return InkWell(
                    onTap: () {
                      onTapItem(selected);
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.2),
                            border: Border.all(color: Colors.white, width: 2),
                            shape: BoxShape.circle),
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 250),
                          crossFadeState: selected
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          secondChild: AnimatedContainer(
                            alignment: Alignment.center,
                            child: !selected
                                ? const SizedBox()
                                : Text(
                                    '$indexSelected',
                                    style: TextStyle(color: Colors.white),
                                  ),
                            decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle),
                            height: selected ? 20 : 20,
                            width: selected ? 20 : 20,
                            duration: const Duration(milliseconds: 250),
                          ),
                          firstChild: SizedBox(
                            height: 20,
                            width: 20,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }

  Future<void> onTapItem(bool selected) async {
    if ((StateBehavior.assetEntitiesSelected.length) >=
            (widget.maxSelect ?? 1000000) &&
        !selected) return;
    StateBehavior.updateAssetEntitiesSelected(widget.assetEntity);
  }

  int get indexSelected {
    return StateBehavior.assetEntitiesSelected
            .map((e) => e.id)
            .toList()
            .indexOf(widget.assetEntity.id) +
        1;
  }

  @override
  bool get wantKeepAlive => true;
}
