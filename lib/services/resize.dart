import 'dart:io';
import 'package:image/image.dart' as img;

Future<List<int>> resizeAndCompressImage(
    File imageFile, int targetWidth, int targetHeight) async {
  List<int> imageBytes = await imageFile.readAsBytes();
  img.Image? image = img.decodeImage(imageBytes);
  if (image != null) {
    img.Image resizedImage =
        img.copyResize(image, width: targetWidth, height: targetHeight);
    List<int> resizedImageBytes = img.encodeJpg(resizedImage, quality: 85);
    return resizedImageBytes;
  } else {
    throw Exception('Failed to decode the image');
  }
}
