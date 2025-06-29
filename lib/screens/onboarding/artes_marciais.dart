import 'package:flutter/material.dart';

class TelaArtesMarciais extends StatefulWidget {
  const TelaArtesMarciais({super.key});

  @override
  State<TelaArtesMarciais> createState() => _TelaArtesMarciaisState();
}

class _TelaArtesMarciaisState extends State<TelaArtesMarciais> {
  final List<String> artes = [
    'Boxe',
    'Capoeira',
    'Jiu-Jitsu',
    'Judô',
    'Karatê',
    'Krav Maga',
    'MMA',
    'Muay Thai',
    'Taekwondo',
  ];

  final List<String> niveis = ['Iniciante', 'Intermediário', 'Avançado'];

  Map<String, String> selecionadas = {};

  bool get podeAvancar => selecionadas.values.any((nivel) => nivel.isNotEmpty);

  void selecionarArte(String arte) {
    if (!selecionadas.containsKey(arte)) {
      setState(() {
        selecionadas[arte] = '';
      });
    }
  }

  void selecionarNivel(String arte, String nivel) {
    setState(() {
      selecionadas[arte] = nivel;
    });
  }

  void removerArte(String arte) {
    setState(() {
      selecionadas.remove(arte);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
            ),
            const SizedBox(height: 24),
            const Text(
              'O que você pratica?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: artes.length,
                itemBuilder: (context, index) {
                  final arte = artes[index];
                  final selecionada = selecionadas.containsKey(arte);
                  final nivelSelecionado = selecionadas[arte] ?? '';

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => selecionarArte(arte),
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: selecionada
                                ? const Color(0xFF8B2E2E).withOpacity(0.1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(
                              color: selecionada
                                  ? const Color(0xFF8B2E2E)
                                  : Colors.grey[400]!,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selecionada && nivelSelecionado.isNotEmpty
                                    ? '$arte • $nivelSelecionado'
                                    : arte,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: selecionada
                                      ? const Color(0xFF8B2E2E)
                                      : Colors.black87,
                                ),
                              ),
                              if (selecionada)
                                GestureDetector(
                                  onTap: () => removerArte(arte),
                                  child: const Text(
                                    'Remover',
                                    style: TextStyle(
                                      color: Color(0xFF8B2E2E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (selecionada)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          child: Wrap(
                            spacing: 12,
                            children: niveis.map((n) {
                              final ativo = nivelSelecionado == n;
                              return ChoiceChip(
                                label: Text(n),
                                selected: ativo,
                                onSelected: (_) => selecionarNivel(arte, n),
                                selectedColor: const Color(0xFF8B2E2E),
                                backgroundColor: Colors.grey[200],
                                labelStyle: TextStyle(
                                  color: ativo ? Colors.white : Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: SizedBox(
                width: 140,
                child: ElevatedButton(
                  onPressed: podeAvancar
                      ? () {
                          Navigator.pushNamed(context, '/fotoperfil');
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B2E2E),
                    disabledBackgroundColor: const Color(0xFF8B2E2E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(140, 40),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'PRÓXIMO',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
