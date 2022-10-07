import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:media_picker_widget/src/media_detail.dart';
import 'package:media_picker_widget/src/state_behavior.dart';
import 'package:media_picker_widget/src/utils.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

import '../../media_picker_widget.dart';
import 'loading_widget.dart';

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

  Future<Uint8List?> _getAssetThumbnail(AssetEntity asset) async {
    return await asset.thumbnailDataWithSize(ThumbnailSize(250, 250),
        quality: 80);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(0.5),
      child: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<Uint8List?>(
                future: _getAssetThumbnail(widget.assetEntity),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoDialogRoute(
                              builder: (context) =>
                                  MediaDetail(assetEntity: widget.assetEntity),
                              context: context),
                        );
                      },
                      child: Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      ),
                    );
                  }
                  return LoadingWidget(
                    decoration: widget.decoration,
                  );
                }),
          ),
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
