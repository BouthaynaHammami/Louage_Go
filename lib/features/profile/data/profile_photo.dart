import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';

import 'profile_photo_io.dart'
    if (dart.library.js_interop) 'profile_photo_web.dart'
    as platform;

Future<String> persistProfilePhoto(XFile image, String userId) =>
    platform.persistProfilePhoto(image, userId);

ImageProvider<Object>? profilePhotoProvider(String source) =>
    platform.profilePhotoProvider(source);

Future<void> deleteProfilePhoto(String source) =>
    platform.deleteProfilePhoto(source);
