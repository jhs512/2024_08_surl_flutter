import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart'; // 추가된 패키지

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends HookWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = useMemoized(() => GoRouter(
          routes: [
            GoRoute(
                path: '/',
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'surls',
                    builder: (context, state) => const SurlListPage(),
                    routes: [
                      GoRoute(
                        path: ':id',
                        builder: (context, state) => SurlDetailPage(
                          id: int.parse(state.pathParameters['id']!),
                        ),
                      ),
                    ],
                  )
                ])
          ],
        ));

    return MaterialApp.router(
      routerConfig: router,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

class HomePage extends HookWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('홈'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            context.go('/surls');
          },
          child: const Text('URL 목록'),
        ),
      ),
    );
  }
}

@immutable
class Surl {
  final int id;
  final DateTime createDate;
  final DateTime modifyDate;
  final String url;
  final String subject;

  const Surl({
    required this.id,
    required this.createDate,
    required this.modifyDate,
    required this.url,
    required this.subject,
  });

  factory Surl.fromJson(Map<String, dynamic> json) {
    return Surl(
      id: json['id'],
      createDate: DateTime.parse(json['createDate']),
      modifyDate: DateTime.parse(json['modifyDate']),
      url: json['url'],
      subject: json['subject'],
    );
  }
}

final fetchGetSurlsProvider =
    FutureProvider.autoDispose<List<Surl>>((ref) async {
  final response = await http.get(
    Uri.parse('http://localhost:8070/api/v1/surls'),
  );

  if (response.statusCode == 200) {
    final List<dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
    return json.map((e) => Surl.fromJson(e)).toList();
  } else {
    throw Exception('Failed to load Surls');
  }
});

final fetchGetSurlProvider =
    FutureProvider.autoDispose.family<Surl, int>((ref, id) async {
  final response = await http.get(
    Uri.parse('http://localhost:8070/api/v1/surls/$id'),
  );

  if (response.statusCode == 200) {
    final Map<String, dynamic> json =
        jsonDecode(utf8.decode(response.bodyBytes));
    return Surl.fromJson(json);
  } else {
    throw Exception('Failed to load Surl');
  }
});

class SurlListPage extends HookConsumerWidget {
  const SurlListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surlAsyncValue = ref.watch(fetchGetSurlsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('URL 목록'),
      ),
      body: surlAsyncValue.when(
        data: (surls) => ListView.builder(
          itemCount: surls.length,
          itemBuilder: (context, index) {
            final surl = surls[index];
            return ListTile(
              title: Text("ID: ${surl.id}, Subject: ${surl.subject}"),
              subtitle: Text('URL: ${surl.url}'),
              onTap: () {
                context.go('/surls/${surl.id}');
              },
              trailing: IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () async {
                  final url = Uri.parse('http://localhost:8070/go/${surl.id}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class SurlDetailPage extends HookConsumerWidget {
  final int id;

  const SurlDetailPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surlAsyncValue = ref.watch(fetchGetSurlProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('URL 상세'),
      ),
      body: surlAsyncValue.when(
        data: (surl) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Id: ${surl.id}',
                  style: Theme.of(context).textTheme.titleLarge),
              Text('Subject: ${surl.subject}',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Text('URL: ${surl.url}',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Text('Created: ${surl.createDate}',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              Text('Modified: ${surl.modifyDate}',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 10),
              SelectableText('Short URL: http://localhost:8070/go/${surl.id}',
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final url = Uri.parse('http://localhost:8070/go/${surl.id}');
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url);
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: const Text('Go'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
