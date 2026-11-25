import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

void main() {
  test('getProjects requests and parses the public project list', () async {
    late http.Request captured;
    final client = ApiClient(
      baseUrl: 'http://localhost:8000',
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode([
            {
              'id': 'project-uuid',
              'title': 'Portfolio',
              'description': 'Personal site',
              'tech_stack': 'Django',
              'project_url': 'https://example.com',
              'project_image_url': null,
            },
          ]),
          200,
        );
      }),
    );

    final projects = await client.getProjects();

    expect(captured.method, 'GET');
    expect(captured.url.path, '/api/v1/projects/');
    expect(captured.headers['accept'], 'application/json');
    expect(projects.single.id, 'project-uuid');
    expect(projects.single.techStack, 'Django');
    expect(projects.single.projectImageUrl, '');
    client.close();
  });

  test('createProject sends the API schema and token', () async {
    late http.Request captured;
    final client = ApiClient(
      baseUrl: 'http://localhost:8000',
      client: MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode({
            'id': 'created-uuid',
            'title': 'Portfolio',
            'description': 'Personal site',
            'tech_stack': 'Flutter',
            'project_url': 'https://example.com',
            'project_image_url': '',
          }),
          201,
        );
      }),
    );
    const project = Project(
      id: 'client-id-is-ignored',
      title: 'Portfolio',
      description: 'Personal site',
      techStack: 'Flutter',
      projectUrl: 'https://example.com',
    );

    final created = await client.createProject(project, token: 'secret-token');
    final body = jsonDecode(captured.body) as Map<String, dynamic>;

    expect(captured.method, 'POST');
    expect(captured.url.path, '/api/v1/projects/');
    expect(captured.headers['authorization'], 'Token secret-token');
    expect(
      body.keys,
      containsAll(['title', 'description', 'tech_stack', 'project_url']),
    );
    expect(body, isNot(contains('id')));
    expect(created.id, 'created-uuid');
    client.close();
  });

  test('token login and logout use the authentication endpoints', () async {
    final requests = <http.Request>[];
    final client = ApiClient(
      baseUrl: 'http://localhost:8000',
      client: MockClient((request) async {
        requests.add(request);
        if (request.url.path.endsWith('/auth/token/')) {
          return http.Response(jsonEncode({'token': 'abc123'}), 200);
        }
        return http.Response('', 204);
      }),
    );

    expect(await client.obtainToken('attar', 'password'), 'abc123');
    await client.logout(token: 'abc123');

    expect(requests[0].url.path, '/api/v1/auth/token/');
    expect(jsonDecode(requests[0].body), {
      'username': 'attar',
      'password': 'password',
    });
    expect(requests[1].url.path, '/api/v1/auth/logout/');
    expect(requests[1].headers['authorization'], 'Token abc123');
    client.close();
  });

  test(
    'non-success response throws an ApiException with status code',
    () async {
      final client = ApiClient(
        baseUrl: 'http://localhost:8000',
        client: MockClient((_) async => http.Response('Unauthorized', 401)),
      );

      await expectLater(
        client.getProjects(),
        throwsA(
          isA<ApiException>().having(
            (error) => error.statusCode,
            'statusCode',
            401,
          ),
        ),
      );
      client.close();
    },
  );
}
