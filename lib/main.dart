import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.apiClient, this.initialToken, this.home});

  final ApiClient? apiClient;
  final String? initialToken;
  final Widget? home;

  @override
  Widget build(BuildContext context) {
    final client = apiClient ?? ApiClient();
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => client,
          dispose: (_, value) => value.close(),
        ),
        ChangeNotifierProvider<AuthState>(
          create: (context) =>
              AuthState(context.read<ApiClient>(), initialToken: initialToken),
        ),
      ],
      child: MaterialApp(
        title: 'MyPortfolio',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            secondary: Colors.amber[700],
          ),
          useMaterial3: true,
        ),
        home: home ?? const MyHomePage(),
      ),
    );
  }
}
