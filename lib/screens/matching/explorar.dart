import 'dart:io';
import 'package:flutter/material.dart';
import 'match.dart';
import '../auth/login.dart';

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

  void _like() {
    if (currentIndex < pessoas.length) {
      if (pessoas[currentIndex].nome == 'Carlos') {
        Navigator.push(
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: currentIndex >= pessoas.length
                ? Row(
                    children: [
                      GestureDetector(
                        onTap: _confirmarSaida,
                        child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Explorar',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _confirmarSaida,
                            child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Explorar',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundImage: AssetImage(pessoas[currentIndex].foto),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${pessoas[currentIndex].nome}, ${pessoas[currentIndex].idade}',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B2E2E),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.location_on, size: 16, color: Colors.black54),
                                  const SizedBox(width: 4),
                                  Text(
                                    pessoas[currentIndex].local,
                                    style: const TextStyle(color: Colors.black54),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${pessoas[currentIndex].genero} | ${pessoas[currentIndex].altura}cm | ${pessoas[currentIndex].peso}kg',
                                style: const TextStyle(color: Colors.black54),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.all(12),
                                margin: const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  pessoas[currentIndex].descricao,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                spacing: 12,
                                runSpacing: 8,
                                alignment: WrapAlignment.center,
                                children: pessoas[currentIndex].modalidades.map((modalidade) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                      horizontal: 16,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF8B2E2E),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      modalidade,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: _dislike,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: const Icon(Icons.close, color: Colors.black54, size: 32),
                                    ),
                                  ),
                                  const SizedBox(width: 40),
                                  GestureDetector(
                                    onTap: _like,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                            offset: Offset(0, 2),
                                          )
                                        ],
                                      ),
                                      child: const Icon(Icons.favorite, color: Color(0xFF8B2E2E), size: 32),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
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
