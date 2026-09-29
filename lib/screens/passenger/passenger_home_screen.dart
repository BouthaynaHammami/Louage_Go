import 'package:flutter/material.dart';
import '../../core/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/seed_service.dart';
import '../auth/login_screen.dart';
import 'louage_list_screen.dart';

const tunisianCities = [
  'Tunis', 'Sfax', 'Sousse', 'Monastir', 'Nabeul',
  'Bizerte', 'Gabès', 'Kairouan', 'Gafsa', 'Djerba',
];

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  String? from;
  String? to;
  DateTime date = DateTime.now();
  TimeOfDay time = TimeOfDay.now();

  Future<void> _pickCity({required bool isFrom}) async {
    final city = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => ListView(
        children: [
          for (final c in tunisianCities)
            ListTile(
              leading: const Icon(Icons.location_city),
              title: Text(c),
              onTap: () => Navigator.pop(ctx, c),
            ),
        ],
      ),
    );
    if (city == null) return;
    setState(() {
      if (isFrom) {
        from = city;
      } else {
        to = city;
      }
    });
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (d != null) setState(() => date = d);
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: time);
    if (t != null) setState(() => time = t);
  }

  void _search() {
    if (from == null || to == null) {
      _message('Choisissez le départ et la destination');
      return;
    }
    if (from == to) {
      _message('Le départ et la destination doivent être différents');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LouageListScreen(
          from: from!,
          to: to!,
          date: date,
          time: time,
        ),
      ),
    );
  }

  Future<void> _logout() async {
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LouageGo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Ajouter des données de test',
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async {
              await SeedService.seedLouages();
              _message('Données ajoutées dans Firestore ✅');
            },
          ),
          IconButton(
            tooltip: 'Déconnexion',
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Où allez-vous ?',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SelectorTile(
                    icon: Icons.trip_origin,
                    label: 'Départ',
                    value: from,
                    onTap: () => _pickCity(isFrom: true),
                  ),
                  const SizedBox(height: 12),
                  _SelectorTile(
                    icon: Icons.location_on,
                    label: 'Destination',
                    value: to,
                    onTap: () => _pickCity(isFrom: false),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _SelectorTile(
                          icon: Icons.calendar_today,
                          label: 'Date',
                          value: '${date.day}/${date.month}/${date.year}',
                          onTap: _pickDate,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SelectorTile(
                          icon: Icons.access_time,
                          label: 'Heure',
                          value: time.format(context),
                          onTap: _pickTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _search,
                    icon: const Icon(Icons.search),
                    label: const Text('Rechercher un louage'),
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

class _SelectorTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _SelectorTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      value ?? 'Choisir',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}