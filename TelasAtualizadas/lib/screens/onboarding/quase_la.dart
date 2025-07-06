import 'package:flutter/material.dart';

class TelaQuaseLa extends StatelessWidget {
  const TelaQuaseLa({super.key});

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
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
                  splashRadius: 24,
                ),
              ),
              const SizedBox(height: 32),
              const Icon(Icons.hourglass_top, size: 64, color: Color(0xFF8D0000)),
              const SizedBox(height: 32),
              const Text(
                'Estamos quase lá!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8D0000),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Só mais alguns dados para completar seu cadastro e encontrar parceiros ideais!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Color(0xFF444444),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: 220,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/dados_pessoais'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D0000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 4,
                    shadowColor: Colors.black12,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                  ),
                  child: const Text(
                    'OK',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1,
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