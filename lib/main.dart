import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Clan {
  final String id;
  final String name;
  final List<String> characters;

  Clan({required this.id, required this.name, required this.characters});

  factory Clan.fromJson(Map<String, dynamic> json) {
    return Clan(
      id: json['id'].toString(),
      name: (json['name'] as String?) ?? 'Nome Desconhecido',
      characters: (json['characters'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

Future<List<Clan>> fetchClans() async {
  final response =
      await http.get(Uri.parse('https://dattebayo-api.onrender.com/clans'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> jsonBody =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> jsonList = jsonBody['clans'] as List<dynamic>;
    return jsonList
        .map((json) => Clan.fromJson(json as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception('Falha ao carregar os clãs. Código: ${response.statusCode}');
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Future<List<Clan>> futureClans;

  @override
  void initState() {
    super.initState();
    futureClans = fetchClans();
  }

  void showClanDetails(BuildContext context, Clan clan) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.black87,
          title: Text(
            '🌸 Detalhes do Clã: ${clan.name} 🌸',
            style: const TextStyle(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
              fontFamily: 'Serif',
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🆔 ID do Clã: ${clan.id}',
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                Text('📛 Nome: ${clan.name}',
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                Text('👥 Total de Personagens: ${clan.characters.length}',
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                Text('🎴 IDs dos Personagens:',
                    style: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold)),
                ...clan.characters.map(
                  (charId) => Text('- $charId',
                      style: const TextStyle(color: Colors.white70)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Fechar',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '🇯🇵 Clãs de Naruto 🇯🇵',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.redAccent,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.redAccent,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
          titleLarge: TextStyle(
              color: Colors.redAccent, fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('🌸 Lista de Clãs de Naruto 🌸'),
        ),
        body: Center(
          child: FutureBuilder<List<Clan>>(
            future: futureClans,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final clans = snapshot.data!;
                return ListView.builder(
                  itemCount: clans.length,
                  itemBuilder: (context, index) {
                    final clan = clans[index];
                    return Card(
                      color: Colors.black,
                      elevation: 4,
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.local_fire_department,
                            color: Colors.redAccent),
                        title: Text(
                          clan.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Text('ID: ${clan.id}',
                            style: const TextStyle(color: Colors.white70)),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            color: Colors.redAccent),
                        onTap: () {
                          showClanDetails(context, clan);
                        },
                      ),
                    );
                  },
                );
              } else if (snapshot.hasError) {
                return Text('Erro: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent));
              }
              return const CircularProgressIndicator(
                color: Colors.redAccent,
              );
            },
          ),
        ),
      ),
    );
  }
}
