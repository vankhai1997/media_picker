import 'package:flutter/material.dart';
import 'package:media_picker_widget/media_picker_widget.dart';
import 'package:photo_manager/photo_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Picker',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<AssetEntity> mediaList = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Picker'),
      ),
      body: previewList(),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => openImagePicker(context),
      ),
    );
  }

  Widget previewList() {
    return SizedBox(
      height: 96,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: List.generate(mediaList.length, (index) => Text('data')),
      ),
    );
  }

  void openImagePicker(BuildContext context) {
    // openCamera(onCapture: (image){
    //   setState(()=> mediaList = [image]);
    // });
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return MediaPicker(
            maxSelect: 2,
            onPick: (selectedList) {
              Navigator.pop(context);
            },
            onCancel: () => Navigator.pop(context),
            mediaCount: MediaCount.multiple,
            mediaType: MediaType.all,
            decoration: PickerDecoration(
              columnCount: 3,
              actionBarPosition: ActionBarPosition.top,
              blurStrength: 2,
              completeText: 'Next',
            ),
          );
        });
  }
}
