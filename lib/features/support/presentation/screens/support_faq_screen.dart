import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../data/faq_data.dart';
import '../../domain/faq_entry.dart';

class SupportFaqScreen extends ConsumerStatefulWidget {
  const SupportFaqScreen({super.key});

  @override
  ConsumerState<SupportFaqScreen> createState() => _SupportFaqScreenState();
}

class _SupportFaqScreenState extends ConsumerState<SupportFaqScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _category = 'all';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final language = Localizations.localeOf(context).languageCode;
    final questions = supportFaq[language] ?? supportFaq['fr']!;
    final userRole = ref.watch(currentUserProvider).asData?.value?.role;
    final categories = faqCategoryOrder(isDriver: userRole == 'driver');
    final filtered = questions.where((question) {
      final matchesCategory =
          _category == 'all' || question.category == _category;
      final normalizedQuery = normalizeFaqText(_query);
      final matchesQuery =
          normalizedQuery.isEmpty ||
          normalizeFaqText('${question.question} ${question.answer}')
              .contains(normalizedQuery);
      return matchesCategory && matchesQuery;
    }).toList();
    final labels = <String, String>{
      'all': l10n.supportFaqAll,
      'booking': l10n.supportCategoryBooking,
      'payment': l10n.supportCategoryPayment,
      'trip': l10n.supportCategoryTrip,
      'account': l10n.supportCategoryAccount,
      'drivers': l10n.supportCategoryDrivers,
    };
    return Scaffold(
      appBar: AppBar(title: Text(l10n.supportFaqTitle)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 8),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      hintText: l10n.supportFaqSearch,
                      suffixIcon: _query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.supportClearSearch,
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                              icon: const Icon(Icons.clear_rounded),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 56,
                  child: ListView.separated(
                    padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 20,
                    ),
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return ChoiceChip(
                        label: Text(labels[category]!),
                        selected: _category == category,
                        onSelected: (_) => setState(() => _category = category),
                      );
                    },
                  ),
                ),
                Expanded(
                  child: filtered.isEmpty
                      ? EmptyState(
                          icon: Icons.search_off_rounded,
                          title: l10n.supportFaqEmpty,
                        )
                      : ListView.separated(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                            20,
                            8,
                            20,
                            24,
                          ),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) => const SizedBox(height: 8),
                          itemBuilder: (context, index) =>
                              _FaqTile(entry: filtered[index]),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

List<String> faqCategoryOrder({required bool isDriver}) {
  final categories = <String>[
    'all',
    'booking',
    'payment',
    'trip',
    'account',
    'drivers',
  ];
  if (isDriver) {
    categories.remove('drivers');
    categories.insert(0, 'drivers');
  }
  return categories;
}

String normalizeFaqText(String value) {
  const replacements = {
    'à': 'a',
    'á': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'ç': 'c',
    'è': 'e',
    'é': 'e',
    'ê': 'e',
    'ë': 'e',
    'ì': 'i',
    'í': 'i',
    'î': 'i',
    'ï': 'i',
    'ñ': 'n',
    'ò': 'o',
    'ó': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ù': 'u',
    'ú': 'u',
    'û': 'u',
    'ü': 'u',
    'ÿ': 'y',
    'œ': 'oe',
    'æ': 'ae',
  };
  var normalized = value.toLowerCase();
  for (final entry in replacements.entries) {
    normalized = normalized.replaceAll(entry.key, entry.value);
  }
  return normalized;
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.entry});

  final FaqEntry entry;

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.zero,
    child: ExpansionTile(
      title: Text(entry.question),
      childrenPadding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 16),
      children: [
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(
            entry.answer,
            style: Theme.of(context).textTheme.bodyMedium
                ?.copyWith(height: 1.5),
          ),
        ),
      ],
    ),
  );
}
