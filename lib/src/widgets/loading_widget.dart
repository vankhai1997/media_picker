import 'package:flutter/cupertino.dart';

import '../../media_picker_widget.dart';

class LoadingWidget extends StatelessWidget {
  LoadingWidget({ this.decoration});

  final PickerDecoration? decoration;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: (decoration?.loadingWidget != null)
          ? decoration!.loadingWidget
          : CupertinoActivityIndicator(),
    );
  }
}
