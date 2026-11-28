import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  final String npm = '2506656495';
  final String nama = 'Attar Rais Hakam';
  final String kelas = 'PBP C';

  final List<ItemHomepage> items = const [
    ItemHomepage('Lihat Proyek', Icons.folder, Color(0xFF1565C0)),
    ItemHomepage('Tambah Proyek', Icons.add_circle, Color(0xFF2E7D32)),
    ItemHomepage('Tambah Pendidikan', Icons.school, Color(0xFF6A1B9A)),
    ItemHomepage('Lihat Pendidikan', Icons.school_outlined, Color(0xFF00695C)),
    ItemHomepage('Logout', Icons.logout, Color(0xFFC62828)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MyPortfolio',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: const LeftDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 960),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textScaler = MediaQuery.textScalerOf(context);
                final minimumCardWidth = 180 * textScaler.scale(14) / 14;
                final columns = (constraints.maxWidth / minimumCardWidth)
                    .floor()
                    .clamp(1, 3);
                final cardWidth =
                    (constraints.maxWidth - (columns - 1) * 10) / columns;

                return Column(
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final card in [
                          InfoCard(title: 'NPM', content: npm),
                          InfoCard(title: 'Name', content: nama),
                          InfoCard(title: 'Class', content: kelas),
                        ])
                          SizedBox(width: cardWidth, child: card),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Text(
                        'Selamat datang di MyPortfolio Mobile!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    GridView.count(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      crossAxisCount: columns,
                      mainAxisExtent: 120 + textScaler.scale(44),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: items.map((item) => ItemCard(item)).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
        child: Column(
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(content, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ItemHomepage {
  final String name;
  final IconData icon;
  final Color color;

  const ItemHomepage(this.name, this.icon, this.color);
}
