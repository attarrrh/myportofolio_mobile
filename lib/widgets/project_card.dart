import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/screens/education_form.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:provider/provider.dart';

class ItemCard extends StatelessWidget {
  final ItemHomepage item;

  const ItemCard(this.item, {super.key});

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    return Material(
      color: item.color,
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () async {
          final messenger = ScaffoldMessenger.of(context);
          if (item.name != 'Logout') {
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text('Kamu telah menekan tombol ${item.name}!'),
                ),
              );
          }

          if (item.name == 'Tambah Proyek' ||
              item.name == 'Tambah Pendidikan') {
            final allowed = await ensureLoggedIn(context);
            if (!context.mounted || !allowed) return;
          }

          if (item.name == 'Tambah Proyek') {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const ProjectFormPage(),
              ),
            );
          } else if (item.name == 'Tambah Pendidikan') {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const EducationFormPage(),
              ),
            );
          } else if (item.name == 'Lihat Proyek') {
            Navigator.push<void>(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const ProjectListScreen(),
              ),
            );
          } else if (item.name == 'Logout') {
            if (!context.read<AuthState>().isLoggedIn) {
              messenger.showSnackBar(
                const SnackBar(content: Text('You are not logged in.')),
              );
              return;
            }
            try {
              await context.read<AuthState>().logout();
              if (!context.mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('Logged out.')),
              );
            } catch (_) {
              if (!context.mounted) return;
              messenger.showSnackBar(
                const SnackBar(content: Text('Logged out on this device.')),
              );
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(item.icon, color: Colors.white, size: 30),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
