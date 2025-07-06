import 'dart:io';
import 'package:flutter/material.dart';
import 'match.dart';
import '../auth/login.dart';
import 'historico_conversas.dart';
import 'perfil_usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Pessoa {
  final String nome;
  final int idade;
  final String foto;
  final String local;
  final String genero;
  final int altura;
  final int peso;
  final String descricao;
  final List<String> modalidades;

  Pessoa({
    required this.nome,
    required this.idade,
    required this.foto,
    required this.local,
    required this.genero,
    required this.altura,
    required this.peso,
    required this.descricao,
    required this.modalidades,
  });

  factory Pessoa.fromJson(Map<String, dynamic> json) {
    return Pessoa(
      nome: json['nome'],
      idade: json['idade'],
      foto: json['foto'], // ajuste conforme seu backend
      local: json['local'],
      genero: json['sexo'],
      altura: json['altura'],
      peso: json['peso'],
      descricao: json['descricao'],
      modalidades: List<String>.from(json['modalidades']),
    );
  }
}

class TelaExplorar extends StatefulWidget {
  final Map<String, dynamic>? filtros;

  const TelaExplorar({super.key, this.filtros});

  @override
  State<TelaExplorar> createState() => _TelaExplorarState();
}

class _TelaExplorarState extends State<TelaExplorar> {
  List<Pessoa> pessoas = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _buscarUsuariosFiltrados();
  }

  Future<void> _buscarUsuariosFiltrados() async {
    final filtros = widget.filtros ?? {};
    final queryParams = filtros.entries
        .where((entry) => entry.value != null && entry.value.toString().isNotEmpty)
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');

    final url = Uri.parse('https://e9f6-187-18-138-85.ngrok-free.app/api/usuarios/filtrar?$queryParams');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          pessoas = data.map((json) => Pessoa.fromJson(json)).toList();
        });
      } else {
        print('Erro ao buscar usuários: ${response.statusCode}');
      }
    } catch (e) {
      print('Erro: $e');
    }
  }

  String categoriaPesoUFC(int peso) {
    if (peso <= 56) return 'Peso Mosca';
    if (peso <= 61) return 'Peso Galo';
    if (peso <= 66) return 'Peso Pena';
    if (peso <= 70) return 'Peso Leve';
    if (peso <= 77) return 'Peso Meio-Médio';
    if (peso <= 84) return 'Peso Médio';
    if (peso <= 93) return 'Peso Meio-Pesado';
    if (peso <= 120) return 'Peso Pesado';
    return 'Categoria Fora do UFC';
  }

  Future<void> _like() async {
    if (currentIndex < pessoas.length) {
      if (pessoas[currentIndex].nome == 'Marina') {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaMatch(
              nome1: 'Você',
              foto1: 'assets/usuario.jpg',
              nome2: pessoas[currentIndex].nome,
              foto2: pessoas[currentIndex].foto,
            ),
          ),
        );
      }
      setState(() => currentIndex++);
    }
  }

  void _dislike() {
    if (currentIndex < pessoas.length - 1) {
      setState(() => currentIndex++);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Não há mais perfis para mostrar.'),
          backgroundColor: const Color(0xFF8B2E2E),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  Future<void> _confirmarSaida() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Deseja sair da conta?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sair', style: TextStyle(color: Color(0xFF8B2E2E))),
              ),
            ],
          )
        ],
      ),
    );

    if (confirmar == true) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TelaLogin()),
      );
    }
  }

  Future<bool> _onWillPop() async {
    exit(0);
  }

  Widget _buildPerfil() {
    if (currentIndex >= pessoas.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('🥊', style: TextStyle(fontSize: 50)),
            SizedBox(height: 16),
            Text(
              'Nenhum parceiro encontrado\ncom esses filtros.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Tente ajustar seus filtros\npara encontrar mais parceiros!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      );
    }

    final pessoa = pessoas[currentIndex];

    return SingleChildScrollView(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(pessoa.foto),
              ),
              const SizedBox(height: 20),
              Text(
                '${pessoa.nome}, ${pessoa.idade}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B2E2E),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    pessoa.local,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${pessoa.genero} • ${pessoa.altura} cm • ${categoriaPesoUFC(pessoa.peso)}',
                style: const TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  pessoa.descricao,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: pessoa.modalidades.map((modalidade) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B2E2E),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      modalidade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _dislike,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close, color: Color(0xFF8B2E2E), size: 45),
                    ),
                  ),
                  const SizedBox(width: 60),
                  GestureDetector(
                    onTap: _like,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B2E2E),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.sports_mma, color: Colors.white, size: 40),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoVoltar() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
      onPressed: _confirmarSaida,
      splashRadius: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildBotaoVoltar(),
                        const SizedBox(width: 12),
                        const Text(
                          'Explorar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(Icons.person, color: Color(0xFF8B2E2E)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const PerfilUsuarioPage()),
                            );
                          },
                          tooltip: 'Perfil',
                        ),
                        const SizedBox(width: 12),
                        IconButton(
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                )
                              ],
                            ),
                            child: const Icon(Icons.chat_bubble_outline, color: Color(0xFF8B2E2E)),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => TelaHistoricoChats()),
                            );
                          },
                          tooltip: 'Conversas',
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Perfil ou mensagem de vazio
                Expanded(child: _buildPerfil()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
