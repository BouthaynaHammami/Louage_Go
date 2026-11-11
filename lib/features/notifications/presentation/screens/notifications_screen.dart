import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/notification_service.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/skeleton_box.dart';
import '../../../../features/auth/auth_providers.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../models/app_notification.dart';
import '../providers/notifications_provider.dart';

// ─── Palette ───────────────────────────────────────────────────────────────
const _kRed     = Color(0xFFD71935);
const _kRedDeep = Color(0xFF8B0010);
const _kBg      = Color(0xFFF7F8FA);
const _kGreen   = Color(0xFF1B8C5A);
const _kOrange  = Color(0xFFFF8C00);
const _kBlue    = Color(0xFF1565C0);
const _kPurple  = Color(0xFFAB5FFF);
const _kAmber   = Color(0xFFFFB300);

// ─── Category ──────────────────────────────────────────────────────────────
enum _Cat { all, trip, smart, promo, account }

// ─── Type metadata ─────────────────────────────────────────────────────────
class _Meta {
  const _Meta(this.icon, this.color, this.label, this.cat, this.emoji);
  final IconData icon;
  final Color    color;
  final String   label, emoji;
  final _Cat     cat;
}

_Meta _meta(String type, AppLocalizations l10n) => switch (type) {
  'booking' || 'reservation' => _Meta(
    Icons.confirmation_number_rounded, _kGreen,
    'Réservation confirmée', _Cat.trip, '✅'),
  'departure' || 'imminent' => _Meta(
    Icons.departure_board_rounded, _kRed,
    'Départ proche', _Cat.trip, '🚕'),
  'trip_change' || 'schedule_change' => _Meta(
    Icons.edit_calendar_rounded, _kAmber,
    'Modification du trajet', _Cat.trip, '⚠️'),
  'cancellation' => _Meta(
    Icons.cancel_rounded, const Color(0xFFFF3B3B),
    'Annulation', _Cat.trip, '❌'),
  'trip' || 'ride' => _Meta(
    Icons.directions_bus_rounded, _kRed,
    l10n.notificationsTypeTrip, _Cat.trip, '🚌'),
  'smart' || 'suggestion' || 'availability' => _Meta(
    Icons.auto_awesome_rounded, _kBlue,
    'Notification intelligente', _Cat.smart, '💡'),
  'promotion' || 'promo' || 'offer' || 'discount' => _Meta(
    Icons.local_offer_rounded, _kOrange,
    'Promotion', _Cat.promo, '🎁'),
  'account' || 'profile' => _Meta(
    Icons.manage_accounts_rounded, _kBlue,
    'Compte', _Cat.account, '👤'),
  'security' || 'password' || 'login' => _Meta(
    Icons.security_rounded, _kPurple,
    'Sécurité', _Cat.account, '🔐'),
  _ => _Meta(Icons.notifications_rounded, Colors.grey,
    l10n.notificationsTypeSystem, _Cat.all, '🔔'),
};

// ── Time ago helper ─────────────────────────────────────────────────────────
String _ago(String iso) {
  final d = DateTime.tryParse(iso);
  if (d == null) return '';
  final diff = DateTime.now().difference(d);
  if (diff.inMinutes < 1)  return 'À l\'instant';
  if (diff.inHours < 1)    return '${diff.inMinutes} min';
  if (diff.inDays < 1)     return '${diff.inHours}h';
  if (diff.inDays == 1)    return 'Hier';
  if (diff.inDays < 7)     return '${diff.inDays}j';
  return '${d.day}/${d.month}/${d.year}';
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS SCREEN
// ═══════════════════════════════════════════════════════════════════════════
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  _Cat   _filter     = _Cat.all;
  String _search     = '';
  bool   _showSearch = false;
  late final TextEditingController _searchCtrl;
  late final AnimationController   _glowCtrl;
  late final Animation<double>     _glow;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController();
    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
    _glow = CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider).asData?.value;

    return Scaffold(
      backgroundColor: _kBg,
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          _Header(
            glowAnim:        _glow,
            showSearch:      _showSearch,
            searchCtrl:      _searchCtrl,
            onSearchChanged: (v) => setState(() => _search = v),
            onToggleSearch:  () => setState(() {
              _showSearch = !_showSearch;
              if (!_showSearch) { _searchCtrl.clear(); _search = ''; }
            }),
            onMarkAll: user == null
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    ref
                        .read(notificationRepositoryProvider)
                        .markAllRead(user.id);
                  },
            onClear: user == null
                ? null
                : () => _confirmClear(context, l10n, user.id),
            onBack: () => context.pop(),
          ),

          // ── Filter chips ─────────────────────────────────────────────────
          _FilterBar(
            active:   _filter,
            onSelect: (c) {
              HapticFeedback.selectionClick();
              setState(() => _filter = c);
            },
          ),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: user == null
                ? _emptyWidget(l10n)
                : ref.watch(notificationsForUserProvider(user.id)).when(
                    loading: () => _skeletonWidget(),
                    error: (_, _) => EmptyState(
                      icon: Icons.error_outline_rounded,
                      title: l10n.notificationsLoadError),
                    data: (items) =>
                        _buildList(context, items, l10n, user.id),
                  ),
          ),
        ],
      ),
    );
  }

  // ── List builder ─────────────────────────────────────────────────────────
  Widget _buildList(BuildContext ctx, List<AppNotification> all,
      AppLocalizations l10n, String userId) {
    // Filter by category
    var items = _filter == _Cat.all
        ? all
        : all.where((n) => _meta(n.type, l10n).cat == _filter).toList();

    // Filter by search
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      items = items
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.message.toLowerCase().contains(q))
          .toList();
    }

    if (items.isEmpty) {
      return _emptyWidget(l10n,
          label: _search.isNotEmpty
              ? 'Aucun résultat pour "$_search"'
              : l10n.notificationsEmptyTitle);
    }

    // Group by date
    final now   = DateTime.now();
    final today = <AppNotification>[];
    final yest  = <AppNotification>[];
    final week  = <AppNotification>[];
    final old   = <AppNotification>[];

    for (final n in items) {
      final d = DateTime.tryParse(n.createdAt);
      if (d == null || _sameDay(d, now)) {
        today.add(n);
      } else if (_sameDay(d, now.subtract(const Duration(days: 1)))) {
        yest.add(n);
      } else if (now.difference(d).inDays <= 7) {
        week.add(n);
      } else {
        old.add(n);
      }
    }

    final unread = items.where((n) => !n.isRead).length;

    // Build flat item list
    final List<_ListItem> listItems = [];

    if (unread > 0) {
      listItems.add(_ListItem.banner(unread));
    }

    void addGroup(String label, List<AppNotification> ns) {
      if (ns.isEmpty) return;
      listItems.add(_ListItem.header(label));
      for (final n in ns) {
        listItems.add(_ListItem.notification(n));
      }
    }

    addGroup(l10n.notificationsToday,     today);
    addGroup(l10n.notificationsYesterday, yest);
    addGroup('Cette semaine',             week);
    addGroup(l10n.notificationsOlder,     old);

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
      itemCount: listItems.length,
      itemBuilder: (context, i) {
        final item = listItems[i];
        return switch (item.type) {
          _ItemType.banner => _UnreadBanner(
              count: item.count!,
              onMarkAll: () {
                HapticFeedback.mediumImpact();
                ref
                    .read(notificationRepositoryProvider)
                    .markAllRead(userId);
              }),
          _ItemType.header => _GroupHeader(label: item.label!),
          _ItemType.notification => _NotifCard(
              key: ValueKey(item.notification!.id),
              notification: item.notification!,
              index: i,
              onTap: () async {
                HapticFeedback.lightImpact();
                await ref
                    .read(notificationRepositoryProvider)
                    .markRead(item.notification!.id);
                final route =
                    NotificationRouteAllowlist.validate(item.notification!.route);
                if (route != null && ctx.mounted) ctx.go(route);
              },
              onDismiss: () async {
                HapticFeedback.mediumImpact();
                final repo = ref.read(notificationRepositoryProvider);
                await repo.delete(item.notification!.id);
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  content: Text(l10n.notificationsDeleted),
                  action: SnackBarAction(
                    label: l10n.favoritesUndo,
                    onPressed: () => repo.restore(item.notification!)),
                ));
              },
            ),
        };
      },
    );
  }

  Widget _skeletonWidget() => ListView(
        padding: const EdgeInsets.all(16),
        children: List.generate(
          4,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: SkeletonBox(
                height: 80, borderRadius: BorderRadius.circular(16)),
          ),
        ),
      );

  Widget _emptyWidget(AppLocalizations l10n, {String? label}) => Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 68, height: 68,
            decoration: BoxDecoration(
              color: _kRed.withValues(alpha: 0.08),
              shape: BoxShape.circle),
            child:
                const Icon(Icons.notifications_off_outlined, color: _kRed, size: 30)),
          const SizedBox(height: 14),
          Text(
            label ?? l10n.notificationsEmptyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14.5,
              fontWeight: FontWeight.w500)),
        ]),
      );

  Future<void> _confirmClear(
      BuildContext ctx, AppLocalizations l10n, String userId) async {
    final ok = await showDialog<bool>(
      context: ctx,
      builder: (_) => _ClearDialog(l10n: l10n));
    if (ok == true && ctx.mounted) {
      ref.read(notificationRepositoryProvider).clear(userId);
    }
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}

// ─── List item model ────────────────────────────────────────────────────────
enum _ItemType { banner, header, notification }

class _ListItem {
  const _ListItem._({required this.type, this.count, this.label, this.notification});
  final _ItemType          type;
  final int?               count;
  final String?            label;
  final AppNotification?   notification;

  factory _ListItem.banner(int count) =>
      _ListItem._(type: _ItemType.banner, count: count);
  factory _ListItem.header(String label) =>
      _ListItem._(type: _ItemType.header, label: label);
  factory _ListItem.notification(AppNotification n) =>
      _ListItem._(type: _ItemType.notification, notification: n);
}

// ═══════════════════════════════════════════════════════════════════════════
// HEADER — dark gradient + glow
// ═══════════════════════════════════════════════════════════════════════════
class _Header extends StatelessWidget {
  const _Header({
    required this.glowAnim,
    required this.showSearch,
    required this.searchCtrl,
    required this.onSearchChanged,
    required this.onToggleSearch,
    required this.onMarkAll,
    required this.onClear,
    required this.onBack,
  });

  final Animation<double>     glowAnim;
  final bool                  showSearch;
  final TextEditingController searchCtrl;
  final ValueChanged<String>  onSearchChanged;
  final VoidCallback          onToggleSearch;
  final VoidCallback?         onMarkAll, onClear, onBack;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: glowAnim,
      builder: (_, child) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0C0C14), Color(0xFF14141F), _kRedDeep],
            stops: [0.0, 0.60, 1.0],
          ),
        ),
        child: Stack(children: [
          // Glow orb
          Positioned(
            right: -40, top: 0,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  _kRed.withValues(alpha: 0.16 * glowAnim.value),
                  Colors.transparent,
                ])),
            ),
          ),
          child!,
        ]),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white, size: 20),
                  onPressed: onBack),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 260),
                    child: showSearch
                        ? _SearchBox(
                            key: const ValueKey('s'),
                            ctrl: searchCtrl,
                            onChanged: onSearchChanged)
                        : const SizedBox(key: ValueKey('t')),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    showSearch ? Icons.close_rounded : Icons.search_rounded,
                    color: Colors.white),
                  onPressed: onToggleSearch),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  color: const Color(0xFF1E1E2E),
                  onSelected: (v) {
                    if (v == 'mark') onMarkAll?.call();
                    if (v == 'clear') onClear?.call();
                  },
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'mark',
                      child: Row(children: [
                        Icon(Icons.done_all_rounded,
                            size: 18, color: _kGreen),
                        const SizedBox(width: 10),
                        const Text('Tout marquer comme lu',
                            style: TextStyle(color: Colors.white)),
                      ])),
                    PopupMenuItem(
                      value: 'clear',
                      child: Row(children: [
                        const Icon(Icons.delete_sweep_rounded,
                            size: 18, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        const Text('Effacer tout',
                            style: TextStyle(color: Colors.redAccent)),
                      ])),
                  ],
                ),
              ]),

              // Title
              if (!showSearch)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                  child: Row(children: [
                    _BellIcon(),
                    const SizedBox(width: 12),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Centre d\'activité',
                          style: TextStyle(
                            color: Colors.white, fontSize: 20,
                            fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                        const Text('LouageGo',
                          style: TextStyle(
                            color: _kRed, fontSize: 11.5,
                            fontWeight: FontWeight.w600, letterSpacing: 1.0)),
                      ],
                    ),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bell icon (static, no animation on header) ──────────────────────────────
class _BellIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40, height: 40,
      decoration: BoxDecoration(
        color: _kRed.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: _kRed.withValues(alpha: 0.30), width: 1.5)),
      child: const Icon(Icons.notifications_rounded, color: _kRed, size: 20));
  }
}

// ── Search box ───────────────────────────────────────────────────────────────
class _SearchBox extends StatelessWidget {
  const _SearchBox({super.key, required this.ctrl, required this.onChanged});
  final TextEditingController ctrl;
  final ValueChanged<String>  onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: Colors.white.withValues(alpha: 0.15), width: 1)),
      child: TextField(
        controller: ctrl,
        onChanged: onChanged,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Rechercher...',
          hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.45), fontSize: 14),
          prefixIcon: Icon(Icons.search_rounded,
              color: Colors.white.withValues(alpha: 0.60), size: 18),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 9)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// FILTER BAR
// ═══════════════════════════════════════════════════════════════════════════
class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.active, required this.onSelect});
  final _Cat active;
  final ValueChanged<_Cat> onSelect;

  static const _tabs = [
    (_Cat.all,     Icons.apps_rounded,           'Tout'),
    (_Cat.trip,    Icons.directions_bus_rounded, 'Voyages'),
    (_Cat.smart,   Icons.auto_awesome_rounded,   'Alertes'),
    (_Cat.promo,   Icons.local_offer_rounded,    'Promos'),
    (_Cat.account, Icons.person_rounded,         'Compte'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      color: Colors.white,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemCount: _tabs.length,
        itemBuilder: (_, i) {
          final (cat, icon, label) = _tabs[i];
          final on = cat == active;
          return GestureDetector(
            onTap: () => onSelect(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: on ? _kRed : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: on ? _kRed : Colors.grey.shade300, width: 1),
                boxShadow: on
                    ? [BoxShadow(
                        color: _kRed.withValues(alpha: 0.25),
                        blurRadius: 8, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 13,
                    color: on ? Colors.white : Colors.grey.shade500),
                const SizedBox(width: 5),
                Text(label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: on ? FontWeight.w700 : FontWeight.w400,
                      color: on ? Colors.white : Colors.grey.shade600)),
              ]),
            ),
          );
        },
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// UNREAD BANNER
// ═══════════════════════════════════════════════════════════════════════════
class _UnreadBanner extends StatelessWidget {
  const _UnreadBanner({required this.count, required this.onMarkAll});
  final int count;
  final VoidCallback onMarkAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _kRed.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kRed.withValues(alpha: 0.22), width: 1),
      ),
      child: Row(children: [
        Container(
          width: 30, height: 30,
          decoration: const BoxDecoration(color: _kRed, shape: BoxShape.circle),
          child: Center(
            child: Text('$count',
              style: const TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.w800)))),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            count == 1 ? '1 notification non lue' : '$count non lues',
            style: const TextStyle(
              color: _kRed, fontWeight: FontWeight.w600, fontSize: 13))),
        GestureDetector(
          onTap: onMarkAll,
          child: const Text('Tout lire',
            style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: _kRed))),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// GROUP HEADER
// ═══════════════════════════════════════════════════════════════════════════
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 14, 0, 6),
      child: Row(children: [
        Container(
          width: 3, height: 14,
          decoration: BoxDecoration(
            color: _kRed, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label,
          style: const TextStyle(
            color: Color(0xFF888888), fontSize: 11.5,
            fontWeight: FontWeight.w600, letterSpacing: 0.6)),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: Colors.grey.shade200, thickness: 1)),
      ]),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// NOTIFICATION CARD — animated entry + swipe dismiss
// ═══════════════════════════════════════════════════════════════════════════
class _NotifCard extends StatefulWidget {
  const _NotifCard({
    super.key,
    required this.notification,
    required this.index,
    required this.onTap,
    required this.onDismiss,
  });
  final AppNotification         notification;
  final int                     index;
  final VoidCallback            onTap;
  final Future<void> Function() onDismiss;

  @override
  State<_NotifCard> createState() => _NotifCardState();
}

class _NotifCardState extends State<_NotifCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double>   _fade;
  late final Animation<Offset>   _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    // Stagger by index (max 7 items visible)
    final delay = (widget.index.clamp(0, 7)) * 40;
    Future.delayed(Duration(milliseconds: delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final m      = _meta(widget.notification.type, l10n);
    final isRead = widget.notification.isRead;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Dismissible(
          key: ValueKey('dis_${widget.notification.id}'),
          direction: DismissDirection.endToStart,
          onDismissed: (_) => widget.onDismiss(),
          background: Container(
            margin: const EdgeInsets.only(bottom: 10),
            alignment: AlignmentDirectional.centerEnd,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade700,
              borderRadius: BorderRadius.circular(16)),
            child: Column(mainAxisSize: MainAxisSize.min, children: const [
              Icon(Icons.delete_rounded, color: Colors.white, size: 20),
              SizedBox(height: 2),
              Text('Supprimer',
                style: TextStyle(color: Colors.white, fontSize: 10)),
            ]),
          ),
          child: GestureDetector(
            onTapDown:   (_) => setState(() => _pressed = true),
            onTapUp:     (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: AnimatedScale(
              scale: _pressed ? 0.97 : 1.0,
              duration: const Duration(milliseconds: 90),
              child: _CardBody(
                notification: widget.notification,
                meta: m,
                isRead: isRead),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Card body (no BackdropFilter — performance) ────────────────────────────
class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.notification,
    required this.meta,
    required this.isRead,
  });
  final AppNotification notification;
  final _Meta           meta;
  final bool            isRead;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isRead
            ? Colors.white
            : meta.color.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? Colors.grey.shade200
              : meta.color.withValues(alpha: 0.20),
          width: isRead ? 1 : 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8, offset: const Offset(0, 2)),
          if (!isRead)
            BoxShadow(
              color: meta.color.withValues(alpha: 0.06),
              blurRadius: 10, spreadRadius: 1),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: meta.color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: meta.color.withValues(alpha: 0.20), width: 1)),
            child: Center(
              child: Text(meta.emoji,
                style: const TextStyle(fontSize: 18)))),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(children: [
                  Expanded(
                    child: Text(
                      notification.title.isEmpty
                          ? meta.label
                          : notification.title,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight:
                            isRead ? FontWeight.w500 : FontWeight.w700,
                        color: const Color(0xFF1A1A1A),
                        height: 1.2))),
                  if (!isRead)
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        color: meta.color,
                        shape: BoxShape.circle)),
                ]),

                // Message
                if (notification.message.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(notification.message,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey.shade600,
                      height: 1.4)),
                ],

                const SizedBox(height: 8),

                // Footer
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: meta.color.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6)),
                    child: Text(meta.label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: meta.color))),
                  const Spacer(),
                  Icon(Icons.access_time_rounded,
                      size: 10, color: Colors.grey.shade400),
                  const SizedBox(width: 3),
                  Text(_ago(notification.createdAt),
                    style: TextStyle(
                        fontSize: 10.5, color: Colors.grey.shade400)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// CLEAR DIALOG
// ═══════════════════════════════════════════════════════════════════════════
class _ClearDialog extends StatelessWidget {
  const _ClearDialog({required this.l10n});
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Effacer tout ?',
        style: TextStyle(
            color: Color(0xFF1A1A1A), fontWeight: FontWeight.w700)),
      content: Text(
        'Toutes les notifications seront supprimées définitivement.',
        style: TextStyle(color: Colors.grey.shade600)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.authCancel,
            style: TextStyle(color: Colors.grey.shade600))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _kRed,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12))),
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Effacer',
            style: TextStyle(color: Colors.white))),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// LEGACY TOAST (kept for backward compatibility)
// ═══════════════════════════════════════════════════════════════════════════
void showBookingConfirmationToast(
  BuildContext context, {
  required String from,
  required String to,
  required String date,
  required String time,
}) {
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _LegacyToast(
      from: from, to: to, date: date, time: time,
      onClose: () => entry.remove()),
  );
  Overlay.of(context).insert(entry);
}

class _LegacyToast extends StatefulWidget {
  const _LegacyToast({
    required this.from,
    required this.to,
    required this.date,
    required this.time,
    required this.onClose,
  });
  final String from, to, date, time;
  final VoidCallback onClose;

  @override
  State<_LegacyToast> createState() => _LegacyToastState();
}

class _LegacyToastState extends State<_LegacyToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset>   _slide;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _slide = Tween<Offset>(
        begin: const Offset(0, -1.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  void _dismiss() {
    if (mounted) {
      _ctrl.reverse().then((_) { if (mounted) widget.onClose(); });
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.viewPaddingOf(context).top;
    return Positioned(
      top: topPad + 12, left: 16, right: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _kGreen.withValues(alpha: 0.30), width: 1.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 20, offset: const Offset(0, 6)),
                  ],
                ),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: _kGreen.withValues(alpha: 0.10),
                      shape: BoxShape.circle),
                    child: const Icon(Icons.check_rounded,
                        color: _kGreen, size: 22)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Réservation confirmée !',
                        style: TextStyle(
                          color: Color(0xFF1A1A1A), fontSize: 14,
                          fontWeight: FontWeight.w800)),
                      const SizedBox(height: 2),
                      Text('${widget.from} → ${widget.to}',
                        style: const TextStyle(
                          color: _kGreen, fontSize: 13,
                          fontWeight: FontWeight.w600)),
                    ],
                  )),
                  const Icon(Icons.close_rounded,
                      color: Colors.black26, size: 16),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
