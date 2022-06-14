import 'package:flutter/material.dart';
import 'package:media_picker_widget/media_picker_widget.dart';
import 'package:photo_manager/photo_manager.dart';

class HeaderController {
  HeaderController();

  ValueChanged<List<Media>>? updateSelection;
  VoidCallback? closeAlbumDrawer;
}
