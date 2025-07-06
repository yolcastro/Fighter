import 'package:flutter/material.dart';

class TelaBoasVindas extends StatelessWidget {
  const TelaBoasVindas({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Botão de voltar no topo esquerdo
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  splashRadius: 24,
                ),
              ),
              const SizedBox(height: 24),
              const Icon(
                Icons.sports_martial_arts,
                size: 72,
                color: Color(0xFF8D0000),
              ),
              const SizedBox(height: 24),
              const Text(
                'FIGHTER',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8D0000),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Cadastro concluído com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Aperte em “COMEÇAR” para buscar um parceiro de treino ideal.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Center(
                child: SizedBox(
                  width: 180,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/explorar',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8D0000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      'COMEÇAR',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}