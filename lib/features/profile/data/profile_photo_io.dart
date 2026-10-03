import 'dart:convert';
import 'dart:io';

import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

Future<String> persistProfilePhoto(XFile image, String userId) async {
  final documents = await getApplicationDocumentsDirectory();
  final dot = image.path.lastIndexOf('.');
  final extension = dot < 0
      ? '.jpg'
      : image.path.substring(dot).replaceAll(RegExp(r'[^.a-zA-Z0-9]'), '');
  final target =
      '${documents.path}${Platform.pathSeparator}profile_${userId}_${DateTime.now().microsecondsSinceEpoch}$extension';
  return (await File(image.path).copy(target)).path;
}

ImageProvider<Object>? profilePhotoProvider(String source) {
  final marker = source.indexOf(';base64,');
  if (source.startsWith('data:image/') && marker >= 0) {
    try {
      return MemoryImage(base64Decode(source.substring(marker + 8)));
    } on FormatException {
      return null;
    }
  }
  return source.isEmpty ? null : FileImage(File(source));
}

Future<void> deleteProfilePhoto(String source) async {
  if (source.startsWith('data:image/')) return;
  final file = File(source);
  if (await file.exists()) await file.delete();
}
