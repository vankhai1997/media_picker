import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

import '../media_picker_widget.dart';

class StateBehavior {
  static final _assetEntitiesSelectedBehavior =
      BehaviorSubject<List<AssetEntity>>.seeded([]);

  static Stream<List<AssetEntity>> get assetEntitiesSelectedStream =>
      _assetEntitiesSelectedBehavior.stream;

  static final _templesSelectedBehavior =
      BehaviorSubject<List<AssetEntity>>.seeded([]);

  static Stream<List<AssetEntity>> get templesSelectedStream =>
      _templesSelectedBehavior.stream;

  static List<AssetEntity> get assetEntitiesSelected =>
      _assetEntitiesSelectedBehavior.value;

  static List<AssetEntity> get templesSelected =>
      _templesSelectedBehavior.value;

  static void addTempleSelected(AssetEntity templeSelected) {
    templesSelected.add(templeSelected);
    _templesSelectedBehavior.add(templesSelected);
  }

  static void removeTempleSelected(AssetEntity temple) {
    templesSelected.remove(temple);
    _templesSelectedBehavior.add(templesSelected);
  }

  static void removeTempleSelectedById(String id) {
    templesSelected.removeWhere((e) => e.id == id);
    _templesSelectedBehavior.add(templesSelected);
  }

  static void updateAssetEntitiesSelected(AssetEntity selectedMedia) {
    if (assetEntitiesSelected.contains(selectedMedia)) {
      removeTempleSelected(selectedMedia);
      assetEntitiesSelected.remove(selectedMedia);
    } else {
      addTempleSelected(selectedMedia);
      assetEntitiesSelected.add(selectedMedia);
    }
    _assetEntitiesSelectedBehavior.add(assetEntitiesSelected.toSet().toList());
  }

  static void onChangeAssetEntitiesSelected(
      Function(List<AssetEntity> selectedMedias) function) {
    _assetEntitiesSelectedBehavior.stream.listen((event) {
      function.call(event);
    });
  }

  static void clearAssetEntitiesSelected() {
    _assetEntitiesSelectedBehavior.value.clear();
    _templesSelectedBehavior.value.clear();
  }
}
