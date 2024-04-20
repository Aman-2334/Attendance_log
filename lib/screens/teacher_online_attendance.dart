import 'dart:io';
import 'package:attendance_log/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class OnlineAttendance extends StatefulWidget {
  final List<File> photos;
  final ValueChanged<File> addImage;
  const OnlineAttendance(
      {super.key, required this.photos, required this.addImage});

  @override
  State<OnlineAttendance> createState() => _OnlineAttendanceState();
}

class _OnlineAttendanceState extends State<OnlineAttendance> {
  late List<File> photos;
  bool isUploading = false;
  int maximumPics = 8;
  final ImagePicker picker = ImagePicker();

  void takeCameraPic() async {
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: ImageSource.camera,
      );
      if (pickedFile != null) {
        setState(() {
          widget.addImage(File(pickedFile.path));
        });
      }
    } catch (e) {
      print("camera picked file error $e");
    }
  }

  void takeGalleryPic() async {
    try {
      int totalPhotos = photos.length;
      final List<XFile> pickedFiles = await picker.pickMultiImage();
      if (pickedFiles.length > maximumPics - totalPhotos) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              margin: AppTheme().snackbarMargin,
              content: const Text("Allowed maximum number of images are 8")));
        }
        pickedFiles.removeRange(maximumPics - totalPhotos, pickedFiles.length);
      }
      List<String> containedImages =
          photos.map((File file) => file.path.split('/').last).toList();
      setState(() {
        for (XFile pickedFile in pickedFiles) {
          if (!containedImages
              .contains(File(pickedFile.path).path.split('/').last)) {
            widget.addImage(File(pickedFile.path));
          }
        }
      });
    } catch (e) {
      print("gallery picked file error $e");
    }
  }

  Widget imageHolder(file, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      key: Key(index.toString()),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(width: 1, color: Colors.black26)),
      height: 180,
      width: 120,
      child: Stack(
        children: [
          GestureDetector(
            onTap: index == photos.length ? takeCameraPic : () {},
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                height: 180,
                width: 120,
                decoration: const BoxDecoration(color: Color(0xFF77B0AA)),
                child: file == null
                    ? const Icon(Icons.add_a_photo_outlined)
                    : file.runtimeType == String
                        ? Image.network(
                            file,
                            fit: BoxFit.cover,
                            errorBuilder: (context, object, stackTrace) =>
                                Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.refresh_outlined),
                              ),
                            ),
                          )
                        : Image.file(
                            file,
                            fit: BoxFit.cover,
                            errorBuilder: (context, object, stackTrace) =>
                                Container(
                              color: Colors.grey.shade300,
                              child: const Center(
                                child: Icon(Icons.refresh_outlined),
                              ),
                            ),
                          ),
              ),
            ),
          ),
          if (index != photos.length)
            Align(
              alignment: Alignment.topRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      photos.removeAt(index);
                    });
                  },
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    color: Colors.amber,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    photos = widget.photos;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = AppTheme().themeData;
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        Container(
          decoration: BoxDecoration(
              color: Colors.black26, borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 7),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...[
                    for (var i = 0; i < photos.length; i++)
                      imageHolder(photos[i], i)
                  ],
                  if (photos.length < maximumPics)
                    imageHolder(null, photos.length),
                ],
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: AppTheme().buttonHeight,
          margin: const EdgeInsets.symmetric(vertical: 7),
          child: TextButton.icon(
            onPressed: takeGalleryPic,
            icon: const Icon(
              Icons.photo_size_select_actual_outlined,
            ),
            label: Text(
              'Gallery',
              style: themeData.textTheme.titleSmall,
            ),
          ),
        ),
      ],
    );
  }
}
