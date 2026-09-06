import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Breakpoint untuk beralih dari 1 kolom ke 2 kolom.
const double kWideBreakpoint = 600;

void main() => runApp(const DashboardApp());

class DashboardApp extends StatefulWidget {
  const DashboardApp({super.key});

  @override
  State<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends State<DashboardApp> {
  bool isDark = false; //buat darkmode

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, //hapus debug
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ), //light mode
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.indigo,
      ), //dark mode
      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
      home: DashboardPage(
        isDark: isDark,
        onDarkChanged: (value) => setState(() => isDark = value),
      ), //status theme mode
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    required this.isDark,
    required this.onDarkChanged,
    super.key,
  });
  final bool isDark;
  final ValueChanged<bool> onDarkChanged;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //navbar
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: const Icon(Icons.person, size: 20),
            ),
            const SizedBox(width: 10),
            const Text(
              'Miqba',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ],
        ),
        actions: [
          Semantics(
            label: 'Dark Mode Switch',
            hint: 'Toggles between light and dark theme mode',
            toggled: isDark,
            child: Row(
              children: [
                Icon(
                  isDark ? Icons.dark_mode : Icons.light_mode,
                  semanticLabel: isDark ? 'Dark Mode Icon' : 'Light Mode Icon',
                ),
                const SizedBox(width: 4),
                CupertinoSwitch(value: isDark, onChanged: onDarkChanged),
                const SizedBox(width: 12),
              ],
            ),
          ),
        ],
      ),

      //content
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= kWideBreakpoint;

            const cardNama = DashboardCard(
              title: 'Nama Lengkap',
              value: 'Abdul Ghofur Almiqbadi',
            );
            const cardNim = DashboardCard(title: 'NIM', value: '244107020155');
            const cardMatkul = DashboardCard(
              title: 'Mata Kuliah',
              value: 'Pemrograman Mobile',
            );
            const cardKelas = DashboardCard(title: 'Kelas', value: 'TI-3F');

            //untuk layar lebarr
            if (isWide) {
              return Column(
                children: [
                  //jadi 2x2
                  Row(
                    children: const [
                      Expanded(child: cardNama),
                      SizedBox(width: 16),
                      Expanded(child: cardNim),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: const [
                      Expanded(child: cardMatkul),
                      SizedBox(width: 16),
                      Expanded(child: cardKelas),
                    ],
                  ),
                ],
              );
            } else {
              //jika layar kecill
              return Column(
                children: const [
                  cardNama,
                  SizedBox(height: 16),
                  cardNim,
                  SizedBox(height: 16),
                  cardMatkul,
                  SizedBox(height: 16),
                  cardKelas,
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

//widget card
class DashboardCard extends StatelessWidget {
  const DashboardCard({required this.title, required this.value, super.key});
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: '$title, $value',
      child: Card(
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
