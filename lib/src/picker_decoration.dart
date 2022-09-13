part of media_picker_widget;

///[PickerDecoration] is used for decorating the UI

class PickerDecoration {
  Widget? cancelIcon;
  double blurStrength;
  int columnCount;
  ActionBarPosition actionBarPosition;
  TextStyle? albumTitleStyle;
  TextStyle? albumTextStyle;
  String completeText;
  String warningText;
  TextStyle? completeTextStyle;
  ButtonStyle? completeButtonStyle;
  Widget? loadingWidget;

  PickerDecoration({
    this.actionBarPosition = ActionBarPosition.top,
    this.cancelIcon,
    this.columnCount = 3,
    this.blurStrength = 2,
    this.albumTitleStyle,
    this.warningText =
        'Bạn vừa cấp quyền cho Meey Team chọn một vài ảnh nhất định.',
    this.completeText = 'Continue',
    this.completeTextStyle,
    this.completeButtonStyle,
    this.loadingWidget,
    this.albumTextStyle,
  });
}
