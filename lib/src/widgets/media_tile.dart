import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_picker_widget/src/controller/index.dart';
import 'package:media_picker_widget/src/utils.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../media_picker_widget.dart';

class MediaTile extends StatelessWidget {
  MediaTile({
    Key? key,
    required this.assetEntity,
    this.decoration,
    this.maxSelect,
    required this.controller,
  }) : super(key: key);
  final MediaController controller;
  final AssetEntity assetEntity;
  final PickerDecoration? decoration;
  final int? maxSelect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: key,
      padding: const EdgeInsets.all(0.5),
      child: Stack(
        children: [
          Positioned.fill(
            child: RepaintBoundary(
                child: Image(
              image: AssetEntityImageProvider(assetEntity,
                  thumbnailSize: ThumbnailSize(195, 195), isOriginal: false),
              fit: BoxFit.cover,
            )),
          ),
          Obx(() {
            final selected = controller.isSelected(assetEntity);
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
          if (assetEntity.type == AssetType.video)
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
                  child: Text(MediaPickerUtils.intTimeHs(assetEntity.duration),
                      style: TextStyle(color: Colors.white, fontSize: 10))),
            ),
          Align(
              alignment: Alignment.topRight,
              child: Obx(() {
                final selected = controller.isSelected(assetEntity);
                return InkWell(
                  onTap: () {
                    if (selected &&
                        controller.assetEntities.length == maxSelect) {
                      return;
                    }
                    controller.onSelected(assetEntity);
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
                                  '${controller.indexSelected(assetEntity)}',
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
              })),
        ],
      ),
    );
  }
}
