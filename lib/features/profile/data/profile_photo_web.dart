import 'dart:convert';

import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';

Future<String> persistProfilePhoto(XFile image, String userId) async {
  final bytes = await image.readAsBytes();
  final mimeType = image.mimeType;
  final safeMimeType = mimeType != null && mimeType.startsWith('image/')
      ? mimeType
      : 'image/jpeg';
  return 'data:$safeMimeType;base64,${base64Encode(bytes)}';
}

ImageProvider<Object>? profilePhotoProvider(String source) {
  final marker = source.indexOf(';base64,');
  if (!source.startsWith('data:image/') || marker < 0) return null;
  try {
    return MemoryImage(base64Decode(source.substring(marker + 8)));
  } on FormatException {
    return null;
  }
}

Future<void> deleteProfilePhoto(String source) async {}
