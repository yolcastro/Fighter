import 'dart:io';
import 'package:flutter/material.dart';
import 'match.dart';
import '../auth/login.dart';
import 'historico_conversas.dart';
import 'perfil_usuario.dart';

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
}

class TelaExplorar extends StatefulWidget {
  const TelaExplorar({super.key});

  @override
  State<TelaExplorar> createState() => _TelaExplorarState();
}

class _TelaExplorarState extends State<TelaExplorar> {
  final List<Pessoa> pessoas = [
    Pessoa(
      nome: 'Ana',
      idade: 23,
      foto: 'assets/ana.jpg',
      local: 'Fortaleza, Ceará',
      genero: 'Mulher',
      altura: 165,
      peso: 58,
      descricao: 'Praticante de Muay Thai, adoro treinos intensos e disciplina.',
      modalidades: ['Muay Thai - Intermediário'],
    ),
    Pessoa(
      nome: 'Carlos',
      idade: 29,
      foto: 'assets/carlos.jpg',
      local: 'Fortaleza, Ceará',
      genero: 'Homem',
      altura: 178,
      peso: 75,
      descricao: 'Faixa roxa de Jiu-Jitsu, buscando novos desafios.',
      modalidades: ['Jiu-Jitsu - Avançado'],
    ),
    Pessoa(
      nome: 'Marina',
      idade: 26,
      foto: 'assets/marina.jpg',
      local: 'Fortaleza, Ceará',
      genero: 'Mulher',
      altura: 170,
      peso: 62,
      descricao: 'Capoeirista com alma leve. Treino é conexão.',
      modalidades: ['Capoeira - Intermediário'],
    ),
  ];

  int currentIndex = 0;

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

                if (currentIndex >= pessoas.length)
                  const Center(
                    child: Text(
                      'Não há mais perfis para mostrar.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),

                if (currentIndex < pessoas.length)
                  Expanded(
                    child: SingleChildScrollView(
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
                                backgroundImage: AssetImage(pessoas[currentIndex].foto),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                '${pessoas[currentIndex].nome}, ${pessoas[currentIndex].idade}',
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
                                    pessoas[currentIndex].local,
                                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${pessoas[currentIndex].genero} • ${pessoas[currentIndex].altura} cm • ${categoriaPesoUFC(pessoas[currentIndex].peso)}',
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
                                  pessoas[currentIndex].descricao,
                                  style: const TextStyle(fontSize: 15, height: 1.4),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Wrap(
                                spacing: 12,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: pessoas[currentIndex].modalidades.map((modalidade) {
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
                                      child: const Icon(Icons.favorite, color: Colors.white, size: 40),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}