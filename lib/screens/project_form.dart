import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  final _formKey = GlobalKey<FormState>();
  static const _defaultCategory = 'Web Development';
  static const _categories = [
    _defaultCategory,
    'Mobile Development',
    'Machine Learning',
    'Data Science',
    'Other',
  ];

  String _projectName = '';
  String _description = '';
  String _category = _defaultCategory;
  String _technologies = '';
  String _projectLink = '';

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _projectName = '';
      _description = '';
      _category = _defaultCategory;
      _technologies = '';
      _projectLink = '';
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Nama Proyek: ${_projectName.trim()}'),
                Text('Deskripsi: ${_description.trim()}'),
                Text('Kategori: $_category'),
                Text('Teknologi: ${_technologies.trim()}'),
                Text('Tautan: ${_projectLink.trim()}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _resetForm();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Project Form'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      decoration: _decoration('Nama Proyek'),
                      onChanged: (value) =>
                          setState(() => _projectName = value),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama proyek tidak boleh kosong!';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      maxLines: 5,
                      decoration: _decoration('Deskripsi Proyek'),
                      onChanged: (value) =>
                          setState(() => _description = value),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Deskripsi proyek tidak boleh kosong!';
                        }
                        return null;
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: DropdownButtonFormField<String>(
                      decoration: _decoration('Kategori Proyek'),
                      initialValue: _defaultCategory,
                      isExpanded: true,
                      items: _categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) setState(() => _category = value);
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      decoration: _decoration(
                        'Teknologi yang Digunakan',
                        hint: 'Contoh: Flutter, Django, Figma',
                      ),
                      onChanged: (value) =>
                          setState(() => _technologies = value),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: TextFormField(
                      decoration: _decoration(
                        'Tautan Proyek',
                        hint: 'URL Proyek (opsional)',
                      ),
                      keyboardType: TextInputType.url,
                      onChanged: (value) =>
                          setState(() => _projectLink = value),
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _submit,
                        child: const Text('Save'),
                      ),
                    ),
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
