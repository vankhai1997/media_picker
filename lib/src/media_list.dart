import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:media_picker_widget/src/controller/index.dart';
import 'package:photo_manager/photo_manager.dart';

import '../media_picker_widget.dart';
import 'widgets/media_tile.dart';

class MediaList extends StatelessWidget {
  MediaList({
    required this.album,
    this.mediaCount,
    this.decoration,
    this.maxSelected,
    required this.onTapCamera,
    required this.controller,
    required this.onPick,
  });

  final MediaController controller;
  final AssetPathEntity album;
  final MediaCount? mediaCount;
  final PickerDecoration? decoration;
  final Function() onTapCamera;
  final Function(List<Media> medias) onPick;
  final int? maxSelected;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Obx(() {
          return controller.assetEntities.isEmpty
              ? Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 36,
                    width: 36,
                    child: CircularProgressIndicator.adaptive(
                      backgroundColor: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                )
              : CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: <Widget>[
                      SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (_, int i) => Builder(
                            builder: (BuildContext _context) {
                              if (i == 0) {
                                return InkWell(
                                  onTap: onTapCamera,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    fit: StackFit.expand,
                                    children: [
                                      Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt,
                                              size: 36,
                                              color:
                                                  Colors.black.withOpacity(0.5),
                                            ),
                                            Text(
                                              'Chụp ảnh',
                                              style: TextStyle(
                                                  color: Colors.black
                                                    .withOpacity(0.5),
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
                              if (index ==
                                      controller.assetEntities.length - 5 &&
                                  !controller.empty) {
                                controller.fetchNewMedia();
                              }
                              final item = controller.assetEntities[index];
                              return MergeSemantics(
                                child: Directionality(
                                    textDirection: Directionality.of(context),
                                    child: MediaTile(
                                      key: ValueKey<String>(item.id),
                                      maxSelect: maxSelected,
                                      assetEntity: item,
                                      decoration: decoration,
                                      controller: controller,
                                    )),
                              );
                            },
                          ),
                          childCount: controller.assetEntities.length + 1,
                          findChildIndexCallback: (Key? key) {
                            if (key is ValueKey<String>) {
                              return controller.assetEntities
                                  .indexWhere((e) => e.id == key.value);
                            }
                            return null;
                          },
                          // Explicitly disable semantic indexes for custom usage.
                          addSemanticIndexes: false,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                        ),
                      ),
                    ]);
        }),
        Positioned(
            bottom: 8 + MediaQuery.of(context).padding.bottom,
            left: 32,
            right: 32,
            child: _ButtonSendImage(
              onPick: () {
                onPick(controller.medias);
              }, controller: controller,
            ))
      ],
    );
  }

}

class _ButtonSendImage extends StatelessWidget {
  final Function() onPick;
  final MediaController controller;

  const _ButtonSendImage(
      {Key? key, required this.onPick, required this.controller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.medias.isEmpty) return const SizedBox();
      return SlideInUp(
        child: IgnorePointer(
          ignoring: controller.cancelable.isNotEmpty,
          child: TextButton(
            style: ButtonStyle(
              backgroundColor:
                  MaterialStateProperty.all(Theme.of(context).primaryColor),
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6))),
            ),
            onPressed: onPick,
            child: Builder(
              builder: (BuildContext context) {
                if (controller.cancelable.isEmpty) {
                  return Text(
                    'Gửi ${controller.medias.length}',
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
        ),
      );
    });
  }
}
