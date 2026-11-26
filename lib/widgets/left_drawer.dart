import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  Future<void> _open(
    BuildContext context,
    Widget page, {
    bool protected = false,
  }) async {
    final navigator = Navigator.of(context);
    navigator.pop();
    // The navigator remains mounted after the drawer closes.
    if (protected && !await ensureLoggedIn(navigator.context)) return;
    if (!navigator.mounted) return;
    navigator.popUntil((route) => route.isFirst);
    await navigator.push<void>(MaterialPageRoute<void>(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = context.watch<AuthState>().isLoggedIn;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.indigo),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Portfolio',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Explore personal projects and experiences!',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          ListTile(
            leading: const Icon(Icons.add_circle_outline),
            title: const Text('Add Project'),
            onTap: () =>
                _open(context, const ProjectFormPage(), protected: true),
          ),
          ListTile(
            leading: const Icon(Icons.folder_open_outlined),
            title: const Text('View Projects'),
            onTap: () => _open(context, const ProjectListScreen()),
          ),
          ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text('Add Education'),
            onTap: () =>
                _open(context, const EducationFormPage(), protected: true),
          ),
          if (!isLoggedIn)
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () => _open(context, const LoginScreen()),
            ),
          if (isLoggedIn)
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final authState = context.read<AuthState>();
                final navigator = Navigator.of(context);
                navigator.pop();
                try {
                  await authState.logout();
                  if (!navigator.mounted) return;
                  navigator.popUntil((route) => route.isFirst);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Logged out.')),
                  );
                } catch (_) {
                  if (!navigator.mounted) return;
                  navigator.popUntil((route) => route.isFirst);
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Logged out on this device.')),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}
