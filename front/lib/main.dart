import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
                        path: 'add',
                        builder: (context, state) => const SurlAddPage(),
                      ),
                      GoRoute(
                        path: 'detail/:id',
                        builder: (context, state) => SurlDetailPage(
                          id: int.parse(state.pathParameters['id']!),
                        ),
                        routes: [
                          GoRoute(
                            path: 'edit',
                            builder: (context, state) => SurlEditPage(
                              id: int.parse(state.pathParameters['id']!),
                            ),
                          ),
                        ],
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
class RsData<T> {
  final String resultCode;
  final String msg;
  final T body;

  const RsData({
    required this.resultCode,
    required this.msg,
    required this.body,
  });

  factory RsData.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    return RsData(
      resultCode: json['resultCode'],
      msg: json['msg'],
      body: fromJsonT(json['body']),
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

Future<void> deleteSurl(int id) async {
  final response = await http.delete(
    Uri.parse('http://localhost:8070/api/v1/surls/$id'),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete Surl');
  }
}

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
                context.go('/surls/detail/${surl.id}');
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.open_in_new),
                    onPressed: () async {
                      final url =
                          Uri.parse('http://localhost:8070/go/${surl.id}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('삭제 확인'),
                            content: const Text('정말로 이 항목을 삭제하시겠습니까?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false); // 아니오 선택
                                },
                                child: const Text('아니오'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true); // 예 선택
                                },
                                child: const Text('예'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        try {
                          await deleteSurl(surl.id);
                          // 삭제 후 화면 갱신
                          ref.invalidate(fetchGetSurlsProvider);
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete: $e')),
                            );
                          }
                        }
                      }
                    },
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/surls/detail/${surl.id}/edit');
                    },
                    child: const Text('Edit'),
                  ),
                ],
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/surls/add');
        },
        child: const Icon(Icons.add),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final url =
                          Uri.parse('http://localhost:8070/go/${surl.id}');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      } else {
                        throw 'Could not launch $url';
                      }
                    },
                    child: const Text('Go'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('삭제 확인'),
                            content: const Text('정말로 이 항목을 삭제하시겠습니까?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false); // 아니오 선택
                                },
                                child: const Text('아니오'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true); // 예 선택
                                },
                                child: const Text('예'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm == true) {
                        try {
                          await deleteSurl(surl.id);
                          ref.invalidate(fetchGetSurlsProvider);
                          if (context.mounted) {
                            context.pop(); // 삭제 후 이전 화면으로 돌아감
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Failed to delete: $e')),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Delete'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/surls/detail/${surl.id}/edit');
                    },
                    child: const Text('Edit'),
                  ),
                ],
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

class SurlEditPage extends HookConsumerWidget {
  final int id;

  const SurlEditPage({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlController = useTextEditingController();
    final subjectController = useTextEditingController();

    Future<void> submitForm() async {
      final url = urlController.text;
      final subject = subjectController.text;

      if (url.isEmpty || subject.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 필드를 입력하세요.')),
        );
        return;
      }

      final response = await http.put(
        Uri.parse('http://localhost:8070/api/v1/surls/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url, 'subject': subject}),
      );

      if (response.statusCode == 200) {
        final RsData<Surl> rsData = RsData.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
          (json) => Surl.fromJson(json),
        );

        ref.invalidate(fetchGetSurlProvider(id));
        ref.invalidate(fetchGetSurlsProvider);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(rsData.msg)),
          );

          context.go('/surls/detail/${rsData.body.id}');
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to edit Surl')),
          );
        }
      }
    }

    final surlAsyncValue = ref.watch(fetchGetSurlProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('URL 수정'),
      ),
      body: surlAsyncValue.when(
        data: (surl) => Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: urlController..text = surl.url,
                decoration: const InputDecoration(labelText: 'URL'),
              ),
              TextField(
                controller: subjectController..text = surl.subject,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: submitForm,
                child: const Text('수정'),
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

class SurlAddPage extends HookConsumerWidget {
  const SurlAddPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final urlController = useTextEditingController();
    final subjectController = useTextEditingController();

    Future<void> submitForm() async {
      final url = urlController.text;
      final subject = subjectController.text;

      if (url.isEmpty || subject.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모든 필드를 입력하세요.')),
        );
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost:8070/api/v1/surls'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'url': url, 'subject': subject}),
      );

      if (response.statusCode == 200) {
        final RsData<Surl> rsData = RsData.fromJson(
          jsonDecode(utf8.decode(response.bodyBytes)),
          (json) => Surl.fromJson(json),
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(rsData.msg)),
          );

          context.go('/surls/detail/${rsData.body.id}');
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to add Surl')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('URL 추가'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: urlController,
              decoration: const InputDecoration(labelText: 'URL'),
            ),
            TextField(
              controller: subjectController,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: submitForm,
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }
}
