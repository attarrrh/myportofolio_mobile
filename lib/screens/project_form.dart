import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _techStackController = TextEditingController();
  final _projectUrlController = TextEditingController();
  final _imageUrlController = TextEditingController();
  bool _isSubmitting = false;

  InputDecoration _decoration(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );

  String? _required(String? value, String label) =>
      value == null || value.trim().isEmpty ? '$label cannot be empty.' : null;

  String? _validateUrl(String? value, {required bool isRequired}) {
    final normalized = value?.trim() ?? '';
    if (normalized.isEmpty) {
      return isRequired ? 'Project URL cannot be empty.' : null;
    }
    final uri = Uri.tryParse(normalized);
    if (uri == null ||
        !uri.hasAuthority ||
        !{'http', 'https'}.contains(uri.scheme.toLowerCase())) {
      return 'Enter a valid HTTP or HTTPS URL.';
    }
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final allowed = await ensureLoggedIn(context);
    if (!mounted || !allowed) return;

    final token = context.read<AuthState>().token;
    if (token == null) return;
    setState(() => _isSubmitting = true);
    final project = Project(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      techStack: _techStackController.text.trim(),
      projectUrl: _projectUrlController.text.trim(),
      projectImageUrl: _imageUrlController.text.trim(),
    );

    try {
      final created = await context.read<ApiClient>().createProject(
        project,
        token: token,
      );
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Project created'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Title: ${created.title}'),
                Text('Description: ${created.description}'),
                Text('Tech stack: ${created.techStack}'),
                Text('Project URL: ${created.projectUrl}'),
                if (created.projectImageUrl.isNotEmpty)
                  Text('Image URL: ${created.projectImageUrl}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        try {
          await context.read<AuthState>().logout();
        } catch (_) {
          // The local token is cleared in AuthState.logout even if revocation fails.
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please log in again.'),
          ),
        );
        await ensureLoggedIn(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save project (HTTP ${error.statusCode}).'),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not connect to the server.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _techStackController.dispose();
    _projectUrlController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? hint,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      decoration: _decoration(label, hint: hint),
      keyboardType: keyboardType,
      maxLines: maxLines,
      textInputAction: maxLines == 1
          ? TextInputAction.next
          : TextInputAction.newline,
      validator: validator,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _input(
                      label: 'Title',
                      controller: _titleController,
                      validator: (value) => _required(value, 'Title'),
                    ),
                    _input(
                      label: 'Description',
                      controller: _descriptionController,
                      validator: (value) => _required(value, 'Description'),
                      maxLines: 4,
                    ),
                    _input(
                      label: 'Tech stack',
                      controller: _techStackController,
                      validator: (value) => _required(value, 'Tech stack'),
                    ),
                    _input(
                      label: 'Project URL (optional)',
                      controller: _projectUrlController,
                      validator: (value) =>
                          _validateUrl(value, isRequired: false),
                      keyboardType: TextInputType.url,
                    ),
                    _input(
                      label: 'Project Image URL (optional)',
                      controller: _imageUrlController,
                      validator: (value) =>
                          _validateUrl(value, isRequired: false),
                      keyboardType: TextInputType.url,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _isSubmitting ? null : _submit,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
