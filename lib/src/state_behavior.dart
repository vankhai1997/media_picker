import 'package:rxdart/rxdart.dart';

import '../media_picker_widget.dart';

class StateBehavior {
  static final reloadCounterBehavior = BehaviorSubject<List<Media>>.seeded([]);

  static void reloadState(List<Media> selectedMedias) {
    reloadCounterBehavior.add(selectedMedias);
  }

  static void listenState(Function(List<Media> selectedMedias) function) {
    reloadCounterBehavior.stream.listen((event) {
      function.call(event);
    });
  }

  static void clearState() {
    reloadCounterBehavior.value.clear();
  }
}
