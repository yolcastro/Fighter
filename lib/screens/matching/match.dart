import 'package:flutter/material.dart';
import 'explorar.dart';

class TelaMatch extends StatelessWidget {
  final String nome1;
  final String foto1;
  final String nome2;
  final String foto2;

  const TelaMatch({
    super.key,
    required this.nome1,
    required this.foto1,
    required this.nome2,
    required this.foto2,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final avatarSize = size.width * 0.3;
    final paddingHorizontal = size.width * 0.06;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.5),
            radius: 1.2,
            colors: [Color(0xFFF5DCDC), Colors.white],
          ),
        ),
        padding: EdgeInsets.symmetric(horizontal: paddingHorizontal, vertical: size.height * 0.06),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PARCERIA\nFORMADA',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.08,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF7A1F1F),
                height: 1.3,
              ),
            ),
            SizedBox(height: size.height * 0.04),
            SizedBox(
              height: avatarSize + 20,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: size.width * 0.15,
                    child: _fotoCircular(foto1, avatarSize),
                  ),
                  Positioned(
                    right: size.width * 0.15,
                    child: _fotoCircular(foto2, avatarSize),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.04),
            Text(
              'Match na medida. Manda um\nsalve e bora treinar juntos!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: size.width * 0.045,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            SizedBox(height: size.height * 0.05),
            SizedBox(
              width: size.width * 0.6,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/chat');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B2E2E),
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.025),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Text(
                  'Enviar mensagem',
                  style: TextStyle(
                    fontSize: size.width * 0.038,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.02),
            SizedBox(
              width: size.width * 0.6,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const TelaExplorar()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3CFCF),
                  padding: EdgeInsets.symmetric(vertical: size.height * 0.025),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                child: Text(
                  'Continuar explorando',
                  style: TextStyle(
                    fontSize: size.width * 0.038,
                    color: const Color(0xFF4D1F1F),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fotoCircular(String foto, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: AssetImage(foto), fit: BoxFit.cover),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
