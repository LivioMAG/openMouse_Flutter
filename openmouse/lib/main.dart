import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/config/app_config.dart';
import 'core/config/config_loader.dart';
import 'core/services/supabase_client.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/logic/auth_controller.dart';
import 'features/auth/pages/login_page.dart';
import 'features/user/data/user_repository.dart';
import 'features/user/logic/user_controller.dart';
import 'features/workspaces/data/workspace_repository.dart';
import 'features/workspaces/logic/workspace_controller.dart';
import 'features/workspaces/pages/workspaces_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await ConfigLoader.load();
  await SupabaseClientService.init(config);
  runApp(OpenMouseApp(config: config));
}

class OpenMouseApp extends StatelessWidget {
  const OpenMouseApp({super.key, required this.config});

  final AppConfig config;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AppConfig>.value(value: config),
        Provider(create: (_) => AuthRepository()),
        Provider(create: (_) => UserRepository()),
        ChangeNotifierProvider(
          create: (context) => UserController(context.read<UserRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthController(
            context.read<AuthRepository>(),
            context.read<UserController>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => WorkspaceController(
            WorkspaceRepository(),
            context.read<UserController>(),
          ),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: config.appName,
        theme: ThemeData(
          scaffoldBackgroundColor: const Color(0xFFF6F6F8),
          cardTheme: const CardThemeData(
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          useMaterial3: true,
        ),
        home: const AppShell(),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.read<AuthController>().isAuthenticated) {
        context.read<UserController>().loadOrCreateProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return auth.isAuthenticated ? const WorkspacesPage() : const LoginPage();
  }
}
