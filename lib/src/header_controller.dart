import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

import '../media_picker_widget.dart';

class HeaderController {
  HeaderController();

  ValueChanged<List<AssetEntity>>? updateSelection;
  VoidCallback? closeAlbumDrawer;
}
