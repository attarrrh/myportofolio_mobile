import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

class EducationFormPage extends StatefulWidget {
  const EducationFormPage({super.key});

  @override
  State<EducationFormPage> createState() => _EducationFormPageState();
}

class _EducationFormPageState extends State<EducationFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _institutionController = TextEditingController();
  final _degreeController = TextEditingController();
  final _majorController = TextEditingController();
  final _yearController = TextEditingController();

  String? _required(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field wajib diisi.';
    }
    return null;
  }

  String? _validateYear(String? value) {
    final requiredError = _required(value, 'Tahun lulus');
    if (requiredError != null) return requiredError;
    final year = int.tryParse(value!.trim());
    if (year == null || year < 1900 || year > DateTime.now().year + 10) {
      return 'Masukkan tahun yang valid.';
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ringkasan Pendidikan'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Institusi: ${_institutionController.text.trim()}'),
              Text('Gelar: ${_degreeController.text.trim()}'),
              Text('Program studi: ${_majorController.text.trim()}'),
              Text('Tahun lulus: ${_yearController.text.trim()}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _institutionController.dispose();
    _degreeController.dispose();
    _majorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label) => InputDecoration(
    labelText: label,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
  );

  Widget _textInput({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: _decoration(label),
        keyboardType: keyboardType,
        textInputAction: TextInputAction.next,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Pendidikan'),
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
                    _textInput(
                      label: 'Institusi',
                      controller: _institutionController,
                      validator: (value) => _required(value, 'Institusi'),
                    ),
                    _textInput(
                      label: 'Gelar',
                      controller: _degreeController,
                      validator: (value) => _required(value, 'Gelar'),
                    ),
                    _textInput(
                      label: 'Program studi',
                      controller: _majorController,
                      validator: (value) => _required(value, 'Program studi'),
                    ),
                    _textInput(
                      label: 'Tahun lulus',
                      controller: _yearController,
                      validator: _validateYear,
                      keyboardType: TextInputType.number,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: _save,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Simpan'),
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
