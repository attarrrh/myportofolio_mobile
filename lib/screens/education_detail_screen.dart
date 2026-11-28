import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/education.dart';

class EducationDetailScreen extends StatelessWidget {
  const EducationDetailScreen({required this.education, super.key});
  final Education education;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Education details')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          education.institution,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 20),
        Text('Degree', style: Theme.of(context).textTheme.titleMedium),
        Text(education.degree),
        const SizedBox(height: 16),
        Text('Major', style: Theme.of(context).textTheme.titleMedium),
        Text(education.major),
        const SizedBox(height: 16),
        Text('Graduation year', style: Theme.of(context).textTheme.titleMedium),
        Text('${education.graduationYear}'),
        if (education.id != null) ...[
          const SizedBox(height: 16),
          Text('ID', style: Theme.of(context).textTheme.titleMedium),
          SelectableText(education.id!),
        ],
      ],
    ),
  );
}
