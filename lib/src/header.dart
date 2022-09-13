
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

import '../media_picker_widget.dart';
import 'header_controller.dart';
import 'state_behavior.dart';

class Header extends StatefulWidget {
  Header({
    required this.selectedAlbum,
    required this.onBack,
    required this.onDone,
    required this.albumController,
    required this.controller,
    this.mediaCount,
    this.decoration,
  });

  final AssetPathEntity selectedAlbum;
  final VoidCallback onBack;
  final PanelController albumController;
  final Function() onDone;
  final HeaderController controller;
  final MediaCount? mediaCount;
  final PickerDecoration? decoration;

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> with TickerProviderStateMixin {

  var _arrowAnimation;
  AnimationController? _arrowAnimController;

  @override
  void initState() {
    _arrowAnimController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    _arrowAnimation =
        Tween<double>(begin: 0, end: 1).animate(_arrowAnimController!);

    widget.controller.closeAlbumDrawer = () {
      widget.albumController.close();
      _arrowAnimController!.reverse();
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: IconButton(
                  icon: widget.decoration!.cancelIcon ?? Text('Hủy'),
                  onPressed: () {
                    if (_arrowAnimation.value == 1)
                      _arrowAnimController!.reverse();
                    widget.onBack();
                  }),
            ),
            const Spacer(),
            if (widget.mediaCount == MediaCount.multiple)
              AnimatedSwitcher(
                duration: Duration(milliseconds: 100),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    child: child,
                    position: Tween<Offset>(
                            begin: Offset(1, 0.0), end: Offset(0.0, 0.0))
                        .animate(animation),
                  );
                },
                child: StreamBuilder<List<AssetEntity>>(
                    stream: StateBehavior.templesSelectedStream,
                    builder: (context, snapshot) {
                      if (StateBehavior.assetEntitiesSelected.isEmpty)
                        return const SizedBox(
                          width: 24,
                        );
                      if ((snapshot.data ?? []).isEmpty)
                        return CircularProgressIndicator.adaptive();

                      return TextButton(
                        key: Key('button'),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.decoration!.completeText,
                              style: widget.decoration!.completeTextStyle ??
                                  TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                            ),
                            Text(
                              ' (${(snapshot.data??[]).length})',
                              style: TextStyle(
                                color: widget
                                        .decoration!.completeTextStyle?.color ??
                                    Colors.white,
                                fontSize: widget.decoration!.completeTextStyle
                                            ?.fontSize !=
                                        null
                                    ? widget.decoration!.completeTextStyle!
                                            .fontSize! *
                                        0.77
                                    : 11,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                          ],
                        ),
                        onPressed: (snapshot.data??[]).isNotEmpty
                            ? () {
                                widget.onDone.call();
                              }
                            : null,
                        style: widget.decoration!.completeButtonStyle ??
                            ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                  Theme.of(context).primaryColor),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3))),
                            ),
                      );
                    }),
              ),
            const SizedBox(
              width: 16,
            ),
          ],
        ),
        Container(width: double.infinity, height: 1, color: Color(0xFFC2CEDB))
      ],
    );
  }
}
