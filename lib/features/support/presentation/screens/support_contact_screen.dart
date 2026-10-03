import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../domain/support_exception.dart';
import '../../support_providers.dart';

class SupportContactScreen extends ConsumerStatefulWidget {
  const SupportContactScreen({super.key});

  @override
  ConsumerState<SupportContactScreen> createState() =>
      _SupportContactScreenState();
}

class _SupportContactScreenState extends ConsumerState<SupportContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripId = TextEditingController();
  final _message = TextEditingController();
  String? _category;

  @override
  void dispose() {
    _tripId.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (!_formKey.currentState!.validate()) return;
    final user = ref.read(currentUserProvider).asData?.value;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.supportSignInRequired)),
      );
      return;
    }
    try {
      await ref
          .read(supportControllerProvider.notifier)
          .submit(
            authorId: user.id,
            category: _category!,
            message: _message.text,
            tripId: _tripId.text.trim(),
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.supportRequestSent)),
      );
      context.goNamed('supportRequests');
    } on SupportException catch (error) {
      if (!mounted) return;
      final message = switch (error.code) {
        SupportExceptionCode.signInRequired => l10n.supportSignInRequired,
        SupportExceptionCode.invalidCategory => l10n.supportCategoryRequired,
        SupportExceptionCode.invalidMessage => l10n.supportMessageInvalid,
        SupportExceptionCode.tooManyOpenRequests =>
          l10n.supportTooManyOpenRequests,
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } on Exception {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.supportSubmissionFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userState = ref.watch(currentUserProvider);
    final isLoading = ref.watch(supportControllerProvider).isLoading;
    final categories = <(String, String)>[
      ('booking', l10n.supportCategoryBooking),
      ('payment', l10n.supportCategoryPayment),
      ('driver', l10n.supportCategoryDrivers),
      ('bug', l10n.supportCategoryBug),
      ('other', l10n.supportCategoryOther),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportContactTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: userState.isLoading
                ? const Padding(
                    padding: EdgeInsetsDirectional.all(20),
                    child: Column(
                      children: [
                        SkeletonBox(height: 56),
                        SizedBox(height: 16),
                        SkeletonBox(height: 120),
                      ],
                    ),
                  )
                : userState.hasError
                ? EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: l10n.supportLoadFailed,
                    actionLabel: l10n.supportRetry,
                    onAction: () => ref.invalidate(currentUserProvider),
                  )
                : Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                        20,
                        16,
                        20,
                        24,
                      ),
                      children: [
                        DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: InputDecoration(
                            labelText: l10n.supportCategoryLabel,
                          ),
                          items: [
                            for (final (value, label) in categories)
                              DropdownMenuItem(
                                value: value,
                                child: Text(label),
                              ),
                          ],
                          onChanged: (value) =>
                              setState(() => _category = value),
                          validator: (value) => value == null
                              ? l10n.supportCategoryRequired
                              : null,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _tripId,
                          label: l10n.supportTripReference,
                          icon: Icons.confirmation_number_outlined,
                          textInputAction: TextInputAction.next,
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _message,
                          label: l10n.supportMessageLabel,
                          icon: Icons.message_outlined,
                          minLines: 5,
                          maxLines: 8,
                          maxLength: 1000,
                          onChanged: (_) => setState(() {}),
                          validator: (value) {
                            final length = value?.trim().length ?? 0;
                            return length < 10 || length > 1000
                                ? l10n.supportMessageInvalid
                                : null;
                          },
                        ),
                        Align(
                          alignment: AlignmentDirectional.centerEnd,
                          child: Text(
                            '${_message.text.length}/1000',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          label: l10n.supportSendRequest,
                          onPressed: isLoading ? null : _submit,
                          isLoading: isLoading,
                          icon: Icons.send_outlined,
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
