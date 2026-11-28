import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:myportofolio_mobile/models/education.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/screens/education_list_screen.dart';
import 'package:provider/provider.dart';

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

  bool _isSubmitting = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _isSubmitting) return;
    if (!await ensureLoggedIn(context) || !mounted) return;
    final auth = context.read<AuthState>();
    final token = auth.token;
    if (token == null) return;
    setState(() => _isSubmitting = true);
    try {
      final created = await context.read<ApiClient>().createEducation(
        Education(
          institution: _institutionController.text.trim(),
          degree: _degreeController.text.trim(),
          major: _majorController.text.trim(),
          graduationYear: int.parse(_yearController.text.trim()),
        ),
        token: token,
      );
      if (!mounted) return;
      final viewList = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Pendidikan tersimpan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Institusi: ${created.institution}'),
                Text('Gelar: ${created.degree}'),
                Text('Program studi: ${created.major}'),
                Text('Tahun lulus: ${created.graduationYear}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Tutup'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Lihat Pendidikan'),
            ),
          ],
        ),
      );
      if (!mounted) return;
      _formKey.currentState!.reset();
      for (final controller in [
        _institutionController,
        _degreeController,
        _majorController,
        _yearController,
      ]) {
        controller.clear();
      }
      if (viewList == true) {
        Navigator.of(context).pushReplacement<void, void>(
          MaterialPageRoute<void>(builder: (_) => const EducationListScreen()),
        );
      }
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        try {
          await auth.logout();
        } catch (_) {
          /* Local token is cleared even if revocation fails. */
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sesi berakhir. Silakan login kembali.'),
          ),
        );
        await ensureLoggedIn(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menyimpan pendidikan (HTTP ${error.statusCode}).',
            ),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat terhubung ke server.')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
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
                        onPressed: _isSubmitting ? null : _save,
                        icon: const Icon(Icons.save_outlined),
                        label: Text(_isSubmitting ? 'Menyimpan...' : 'Simpan'),
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
