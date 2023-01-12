import 'package:async/async.dart';
import 'package:get/get.dart';
import 'package:photo_manager/photo_manager.dart';

import '../../media_picker_widget.dart';
import '../utils.dart';

class MediaController extends GetxController {
  final MediaType type;
  AssetPathEntity? albums;
  bool showWarning = false;
  bool emptyData = false;
  final RxList<Media> medias = RxList();
  final RxList<AssetEntity> assetEntities = RxList();
  final RxList<AssetEntity> assetEntitiesSelected = RxList();
  final RxMap<String, CancelableOperation<Media>> cancelable = RxMap();
  int currentPage = 0;
  bool empty = false;

  MediaController(this.type);

  @override
  void onInit() {
    _initData();
    super.onInit();
  }

  Future<void> _initData() async {
    await fetchAlbums(type);
    fetchNewMedia();
  }

  @override
  void onClose() {
    cancelable.values.forEach((e) {
      e.cancel();
    });
    print('MediaController.onClose');
    super.onClose();
  }

  bool isSelected(AssetEntity assetEntity) =>
      assetEntitiesSelected.indexOf(assetEntity) != -1;

  int indexSelected(AssetEntity assetEntity) =>
      assetEntitiesSelected.indexOf(assetEntity)+1;

  void onSelected(AssetEntity assetEntity) {
    if (assetEntitiesSelected.contains(assetEntity)) {
      assetEntitiesSelected.remove(assetEntity);
    } else {
      assetEntitiesSelected.add(assetEntity);
    }
    _futureAction(assetEntity);
  }

  void _futureAction(AssetEntity assetEntity) {
    if (cancelable[assetEntity.id] != null) {
      cancelable[assetEntity.id]!.cancel();
      return;
    }
    final index = medias.indexWhere((e) => e.id == assetEntity.id);
    if (index != -1) {
      medias.removeAt(index);
      return;
    }
    final cancellableOperation = CancelableOperation.fromFuture(
      MediaPickerUtils.convertToMedia(media: assetEntity),
      onCancel: () => {cancelable.remove(assetEntity.id)},
    );

    final map =
        Map.fromEntries([MapEntry(assetEntity.id, cancellableOperation)]);
    cancelable.addAll(map);

    ///lắng nghe kết quả thành công từ việc convert assetEntity sạng media
    cancellableOperation.value.then((value) {
      medias.add(value);
      cancelable.remove(assetEntity.id);
    });
  }

  fetchAlbums(mediaType) async {
    RequestType type = RequestType.common;
    if (mediaType == MediaType.all)
      type = RequestType.common;
    else if (mediaType == MediaType.video)
      type = RequestType.video;
    else if (mediaType == MediaType.image) type = RequestType.image;
    var result = await PhotoManager.requestPermissionExtend();
    if (result == PermissionState.limited) {
      showWarning = true;
      update();
    }
    if (result == PermissionState.limited ||
        result == PermissionState.authorized) {
      List<AssetPathEntity> _albums =
          await PhotoManager.getAssetPathList(type: type, onlyAll: true);
      if (_albums.isEmpty) {
        emptyData = true;
        update();
        return;
      }
      albums = _albums.first;
      update();
    } else {
      PhotoManager.openSetting();
    }
  }

  Future fetchNewMedia() async {
    print('_MediaListState._fetchNewMedia');
    if (empty) return;
    var result = await PhotoManager.requestPermissionExtend();
    if (result == PermissionState.limited ||
        result == PermissionState.authorized) {
      List<AssetEntity> media =
          await albums!.getAssetListPaged(page: currentPage, size: 80);
      empty = media.isEmpty;
      assetEntities.addAll(media);
      currentPage++;
    } else {
      PhotoManager.openSetting();
    }
  }
}
