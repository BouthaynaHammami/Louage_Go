import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/storage/hive_service.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../features/auth/domain/auth_exception.dart';
import '../../../../features/auth/presentation/auth_error_message.dart';
import '../../../../features/auth/presentation/widgets/phone_change_action.dart';
import '../../../../features/profile/data/profile_photo.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/app_user.dart';
import '../../../../models/station.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _picker = ImagePicker();
  AppUser? _user;
  String? _city;
  String? _photoPath;
  String? _pendingPhotoPath;
  bool _initialized = false;
  bool _loading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    final pendingPhoto = _pendingPhotoPath;
    if (pendingPhoto != null) {
      unawaited(_deleteFile(pendingPhoto));
    }
    super.dispose();
  }

  Future<void> _deleteFile(String path) async {
    await deleteProfilePhoto(path);
  }

  List<String> _cities() {
    final cities =
        HiveService.stations.values
            .map(Station.fromMap)
            .map((station) => station.city.trim())
            .where((city) => city.isNotEmpty)
            .toSet()
            .toList()
          ..sort();
    final currentCity = _city;
    if (currentCity != null &&
        currentCity.isNotEmpty &&
        !cities.contains(currentCity)) {
      cities.add(currentCity);
      cities.sort();
    }
    return cities;
  }

  Future<void> _pickPhoto() async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(l10n.profileChooseGallery),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: Text(l10n.profileChooseCamera),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked == null || !mounted) return;
      final userId = _user?.id ?? 'profile';
      final savedPhoto = await persistProfilePhoto(picked, userId);
      final oldPending = _pendingPhotoPath;
      setState(() {
        _photoPath = savedPhoto;
        _pendingPhotoPath = savedPhoto;
      });
      if (oldPending != null) await _deleteFile(oldPending);
    } on Exception {
      if (!mounted) return;
      _showMessage(l10n.profilePhotoError);
    }
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context)!;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final updated = await ref
          .read(authControllerProvider.notifier)
          .updateProfile(
            name: '${_firstName.text.trim()} ${_lastName.text.trim()}'.trim(),
            email: _email.text.trim(),
            city: _city ?? '',
            photo: _photoPath ?? '',
          );
      final oldPhoto = _user?.photo ?? '';
      final pendingPhoto = _pendingPhotoPath;
      _pendingPhotoPath = null;
      var cleanupFailed = false;
      if (oldPhoto.isNotEmpty &&
          oldPhoto != updated.photo &&
          oldPhoto != pendingPhoto) {
        try {
          await _deleteFile(oldPhoto);
        } on Exception catch (error) {
          debugPrint('Could not remove replaced profile avatar: $error');
          cleanupFailed = true;
        }
      }
      if (!mounted) return;
      _user = updated;
      final messenger = ScaffoldMessenger.of(context);
      context.pop();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            cleanupFailed
                ? l10n.profilePhotoCleanupWarning
                : l10n.profileUpdated,
          ),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      _showMessage(authErrorMessage(l10n, error.code));
    } catch (_) {
      if (!mounted) return;
      _showMessage(l10n.authUnexpectedError);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _initialize(AppUser user) {
    if (_initialized) return;
    _initialized = true;
    _user = user;
    final nameParts = user.name.trim().split(RegExp(r'\s+'));
    _firstName.text = nameParts.isEmpty ? '' : nameParts.first;
    _lastName.text = nameParts.length < 2 ? '' : nameParts.skip(1).join(' ');
    _email.text = user.email;
    _city = user.city;
    _photoPath = user.photo.isEmpty ? null : user.photo;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref
        .watch(currentUserProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    if (user != null) _initialize(user);
    final cities = _cities();
    final photoProvider = _photoPath == null
        ? null
        : profilePhotoProvider(_photoPath!);

    return PopScope(
      canPop: !_loading,
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.profileEditTitle)),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: user == null
                  ? Center(child: Text(l10n.profileUnavailable))
                  : Form(
                      key: _formKey,
                      child: ListView(
                        padding: const EdgeInsetsDirectional.all(20),
                        children: [
                          Center(
                            child: Semantics(
                              button: true,
                              label: l10n.profileChangePhoto,
                              child: InkWell(
                                onTap: _loading ? null : _pickPhoto,
                                customBorder: const CircleBorder(),
                                child: CircleAvatar(
                                  radius: 54,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .secondaryContainer,
                                  child: _photoPath == null
                                      ? const Icon(
                                          Icons.person_outline,
                                          size: 48,
                                        )
                                      : photoProvider == null
                                      ? const Icon(
                                          Icons.person_outline,
                                          size: 48,
                                        )
                                      : ClipOval(
                                          child: Image(
                                            image: photoProvider,
                                            width: 108,
                                            height: 108,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, _, _) =>
                                                const Icon(
                                                  Icons.person_outline,
                                                  size: 48,
                                                ),
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: TextButton(
                              onPressed: _loading ? null : _pickPhoto,
                              child: Text(l10n.profileChangePhoto),
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _firstName,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.profileFirstNameLabel,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? l10n.formRequiredFields
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _lastName,
                            textInputAction: TextInputAction.next,
                            decoration: InputDecoration(
                              labelText: l10n.profileLastNameLabel,
                              border: const OutlineInputBorder(),
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? l10n.formRequiredFields
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _email,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              final email = value?.trim() ?? '';
                              if (email.isEmpty ||
                                  RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                      .hasMatch(email)) {
                                return null;
                              }
                              return l10n.authInvalidEmail;
                            },
                            decoration: InputDecoration(
                              labelText: l10n.registerEmailOptional,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<String>(
                            initialValue: _city ?? '',
                            decoration: InputDecoration(
                              labelText: l10n.profileCityLabel,
                              border: const OutlineInputBorder(),
                            ),
                            items: [
                              DropdownMenuItem(
                                value: '',
                                child: Text(l10n.profileCityNotSet),
                              ),
                              for (final city in cities)
                                DropdownMenuItem(
                                  value: city,
                                  child: Text(city),
                                ),
                            ],
                            onChanged: _loading
                                ? null
                                : (value) => setState(() => _city = value),
                          ),
                          const SizedBox(height: 16),
                          InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.loginPhoneLabel,
                              border: const OutlineInputBorder(),
                            ),
                            child: Text(user.phone),
                          ),
                          Align(
                            alignment: AlignmentDirectional.centerStart,
                            child: PhoneChangeAction(),
                          ),
                          const SizedBox(height: 24),
                          AppButton(
                            label: l10n.profileSaveAction,
                            onPressed: _loading ? null : _save,
                            isLoading: _loading,
                          ),
                        ],
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
