/// Base URL for the Django REST API.
///
/// Android emulators reach the host machine through 10.0.2.2. Override this
/// value for Flutter Web or a deployed backend with --dart-define=API_BASE_URL.
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
