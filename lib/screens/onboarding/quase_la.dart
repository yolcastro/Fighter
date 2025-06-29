import 'package:flutter/material.dart';

class TelaQuaseLa extends StatelessWidget {
  const TelaQuaseLa({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBotaoVoltar(context),
              const SizedBox(height: 40),
              _buildTitulo(),
              const SizedBox(height: 16),
              _buildDescricao(),
              const Spacer(),
              _buildBotaoOk(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoVoltar(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(
        Icons.arrow_back_ios_new,
        color: Color(0xFF8B2E2E),
      ),
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'Estamos quase lá',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDescricao() {
    return const Text(
      'Precisamos de mais algumas informações para completar seu cadastro.',
      style: TextStyle(fontSize: 16, height: 1.4),
    );
  }

  Widget _buildBotaoOk(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, '/dados_pessoais');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B2E2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
        ),
        child: const Text(
          'OK',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }
}
