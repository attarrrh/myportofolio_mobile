import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Project details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (project.projectImageUrl.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                project.projectImageUrl,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const SizedBox(
                  height: 220,
                  child: Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
          Text(
            project.title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 12),
          Text(project.description),
          const SizedBox(height: 20),
          Text('Tech stack', style: Theme.of(context).textTheme.titleMedium),
          Text(project.techStack),
          if (project.projectUrl.isNotEmpty) ...[
            const SizedBox(height: 20),
            Text('Project URL', style: Theme.of(context).textTheme.titleMedium),
            SelectableText(project.projectUrl),
          ],
        ],
      ),
    );
  }
}
