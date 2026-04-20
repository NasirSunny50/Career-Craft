import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cv_profile.dart';
import 'models/cv_template_meta.dart';
import 'providers/cv_provider.dart';
import 'services/cv_persistence.dart';
import 'screens/editor_screen.dart';
import 'screens/home_screen.dart';
import 'screens/preview_screen.dart';
import 'screens/template_gallery_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final snap = await loadCvSnapshot();
  runApp(CareerCraftApp(
    initialProfile: snap.profile,
    initialTemplate: snap.template,
  ));
}

class CareerCraftApp extends StatefulWidget {
  const CareerCraftApp({
    super.key,
    required this.initialProfile,
    required this.initialTemplate,
  });

  final CvProfile initialProfile;
  final CvTemplateId initialTemplate;

  @override
  State<CareerCraftApp> createState() => _CareerCraftAppState();
}

class _CareerCraftAppState extends State<CareerCraftApp> {
  ThemeMode _mode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CvController(
        profile: widget.initialProfile,
        template: widget.initialTemplate,
      ),
      child: MaterialApp(
        title: 'Career Craft',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: _mode,
        home: AppShell(
          onToggleTheme: () {
            setState(() {
              if (_mode == ThemeMode.system) {
                final b =
                    WidgetsBinding.instance.platformDispatcher.platformBrightness;
                _mode = b == Brightness.dark ? ThemeMode.light : ThemeMode.dark;
              } else {
                _mode =
                    _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
              }
            });
          },
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.onToggleTheme});

  final VoidCallback onToggleTheme;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      context.read<CvController>().flushPersistence();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(
        onToggleTheme: widget.onToggleTheme,
        onGoTab: (i) => setState(() => _index = i),
      ),
      const TemplateGalleryScreen(),
      const EditorScreen(),
      const PreviewScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.palette_outlined),
            selectedIcon: Icon(Icons.palette_rounded),
            label: 'Templates',
          ),
          NavigationDestination(
            icon: Icon(Icons.edit_outlined),
            selectedIcon: Icon(Icons.edit_rounded),
            label: 'Edit',
          ),
          NavigationDestination(
            icon: Icon(Icons.visibility_outlined),
            selectedIcon: Icon(Icons.visibility_rounded),
            label: 'Preview',
          ),
        ],
      ),
    );
  }
}
