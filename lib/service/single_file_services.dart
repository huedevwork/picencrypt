import 'package:image_picker/image_picker.dart';

Future<String?> singleFileServices() async {
  try {
    XFile? xFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (xFile == null) {
      return null;
    }

    return xFile.path;
  } catch (e) {
    rethrow;
  }
}
