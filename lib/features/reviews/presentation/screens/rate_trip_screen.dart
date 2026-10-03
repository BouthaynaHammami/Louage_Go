import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/review.dart';
import '../../domain/review_exception.dart';
import '../providers/reviews_provider.dart';
import '../widgets/review_stars.dart';

class RateTripScreen extends ConsumerWidget {
  const RateTripScreen({required this.tripId, super.key});

  final String tripId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider).asData?.value;
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.reviewsWriteTitle)),
        body: EmptyState(
          icon: Icons.lock_outline,
          title: l10n.reviewsSignInRequired,
        ),
      );
    }
    return ref
        .watch(reviewTripContextProvider((user.id, tripId)))
        .when(
          loading: () => Scaffold(
            appBar: AppBar(title: Text(l10n.reviewsWriteTitle)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (error, stackTrace) => Scaffold(
            appBar: AppBar(title: Text(l10n.reviewsWriteTitle)),
            body: EmptyState(
              icon: Icons.error_outline,
              title: l10n.reviewsLoadError,
            ),
          ),
          data: (tripContext) {
            if (tripContext == null) {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.reviewsWriteTitle)),
                body: EmptyState(
                  icon: Icons.event_busy_outlined,
                  title: l10n.reviewsUnavailable,
                ),
              );
            }
            if (!tripContext.eligible) {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.reviewsWriteTitle)),
                body: EmptyState(
                  icon: Icons.rate_review_outlined,
                  title: l10n.reviewsNotEligible,
                ),
              );
            }
            if (tripContext.existingReview != null &&
                !tripContext.canEditReview) {
              return Scaffold(
                appBar: AppBar(title: Text(l10n.reviewsEditTitle)),
                body: SafeArea(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Padding(
                        padding: const EdgeInsetsDirectional.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ReviewStars(
                              rating: tripContext.existingReview!.rating
                                  .round(),
                              size: 30,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              tripContext.existingReview!.comment.isEmpty
                                  ? l10n.reviewsNoComment
                                  : tripContext.existingReview!.comment,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              l10n.reviewsWindowExpired,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  tripContext.existingReview == null
                      ? l10n.reviewsWriteTitle
                      : l10n.reviewsEditTitle,
                ),
              ),
              body: SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.all(20),
                      child: RateTripSheet(
                        userId: user.id,
                        tripId: tripId,
                        driverId: tripContext.driverId,
                        existingReview: tripContext.existingReview,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
  }
}

class RateTripSheet extends ConsumerStatefulWidget {
  const RateTripSheet({
    required this.userId,
    required this.tripId,
    required this.driverId,
    this.existingReview,
    super.key,
  });

  final String userId;
  final String tripId;
  final String driverId;
  final Review? existingReview;

  @override
  ConsumerState<RateTripSheet> createState() => _RateTripSheetState();
}

class _RateTripSheetState extends ConsumerState<RateTripSheet> {
  late final TextEditingController _commentController;
  late int _rating;

  @override
  void initState() {
    super.initState();
    _rating = widget.existingReview?.rating.round() ?? 0;
    _commentController = TextEditingController(
      text: widget.existingReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context)!;
    if (_rating == 0) {
      _showMessage(l10n.reviewsInvalidRating);
      return;
    }
    final controller = ref.read(reviewControllerProvider.notifier);
    try {
      if (widget.existingReview == null) {
        await controller.submit(
          userId: widget.userId,
          tripId: widget.tripId,
          driverId: widget.driverId,
          rating: _rating,
          comment: _commentController.text,
        );
      } else {
        await controller.updateReview(
          userId: widget.userId,
          reviewId: widget.existingReview!.id,
          rating: _rating,
          comment: _commentController.text,
        );
      }
      if (!mounted) return;
      _showMessage(
        widget.existingReview == null ? l10n.reviewsSaved : l10n.reviewsUpdated,
      );
      context.pop();
    } on ReviewException catch (error) {
      if (mounted) _showMessage(_reviewError(l10n, error.code));
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
      if (mounted) _showMessage(l10n.reviewsLoadError);
    }
  }

  Future<void> _delete() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.reviewsDelete),
        content: Text(l10n.reviewsDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: Text(l10n.reviewsCancelAction),
          ),
          TextButton(
            onPressed: () => context.pop(true),
            child: Text(l10n.reviewsDeleteAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    try {
      await ref
          .read(reviewsRepositoryProvider)
          .deleteReview(
            userId: widget.userId,
            reviewId: widget.existingReview!.id,
          );
      if (!mounted) return;
      _showMessage(l10n.reviewsDeleted);
      context.pop();
    } on ReviewException catch (error) {
      if (mounted) _showMessage(_reviewError(l10n, error.code));
    } catch (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(exception: error, stack: stackTrace),
      );
      if (mounted) _showMessage(l10n.reviewsLoadError);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final loading = ref.watch(reviewControllerProvider).isLoading;
    final ratingText = switch (_rating) {
      1 => l10n.reviewsRating1,
      2 => l10n.reviewsRating2,
      3 => l10n.reviewsRating3,
      4 => l10n.reviewsRating4,
      5 => l10n.reviewsRating5,
      _ => l10n.reviewsRatingPrompt,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.reviewsRatingPrompt,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Center(
          child: ReviewStars(
            rating: _rating,
            size: 34,
            interactive: true,
            onSelected: (rating) => setState(() => _rating = rating),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ratingText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(color: colors.secondary),
        ),
        const SizedBox(height: 20),
        AppTextField(
          label: l10n.reviewsComment,
          icon: Icons.rate_review_outlined,
          controller: _commentController,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: 3,
          maxLines: 5,
          maxLength: 300,
        ),
        const SizedBox(height: 20),
        AppButton(
          label: widget.existingReview == null
              ? l10n.reviewsSubmit
              : l10n.reviewsUpdate,
          onPressed: _submit,
          isLoading: loading,
        ),
        if (widget.existingReview != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: loading ? null : _delete,
            child: Text(l10n.reviewsDelete),
          ),
        ],
      ],
    );
  }
}

Future<void> showRateTripSheet(
  BuildContext context, {
  required String userId,
  required String tripId,
  required String driverId,
  Review? existingReview,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (context) => Padding(
    padding: EdgeInsetsDirectional.fromSTEB(
      20,
      24,
      20,
      MediaQuery.viewInsetsOf(context).bottom + 20,
    ),
    child: SingleChildScrollView(
      child: RateTripSheet(
        userId: userId,
        tripId: tripId,
        driverId: driverId,
        existingReview: existingReview,
      ),
    ),
  ),
);

String _reviewError(AppLocalizations l10n, ReviewExceptionCode code) =>
    switch (code) {
      ReviewExceptionCode.notEligible => l10n.reviewsNotEligible,
      ReviewExceptionCode.alreadyReviewed => l10n.reviewsAlreadyReviewed,
      ReviewExceptionCode.invalidRating => l10n.reviewsInvalidRating,
      ReviewExceptionCode.invalidComment => l10n.reviewsInvalidComment,
      ReviewExceptionCode.reviewNotFound => l10n.reviewsNotFound,
      ReviewExceptionCode.editingWindowExpired => l10n.reviewsWindowExpired,
      ReviewExceptionCode.signInRequired => l10n.reviewsSignInRequired,
    };
