import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PerfilAdversarioPage(),
    ),
  );
}

class PerfilAdversarioPage extends StatelessWidget {
  const PerfilAdversarioPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage: AssetImage('assets/images/perfil.png'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Carlos Silva',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('@carlos.s • Peso Leve'),
                    const SizedBox(height: 24),

                    const Text(
                      'ESTATÍSTICAS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _StatBox(label: 'Vitórias', value: '8'),
                        _StatBox(label: 'Derrotas', value: '5'),
                        _StatBox(label: 'Empates', value: '2'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'BIOGRAFIA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Competidor desde 2020 com foco em Jiu-Jitsu e Boxe.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'ESTILOS DE LUTA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: const [
                        _EstiloChip(texto: 'Jiu-Jitsu'),
                        _EstiloChip(texto: 'Boxe'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'DETALHES DO LUTADOR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text('Altura:'), Text('172 cm')],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Nível de Experiência:'),
                            Text('Intermediário'),
                          ],
                        ),
                        SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [Text('Reputação:'), Text('3,45/5')],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF912626),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              // lógica para iniciar conversa
                            },
                            child: const Text(
                              'INICIAR CONVERSA',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              side: const BorderSide(color: Color(0xFF912626)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              // lógica para convidar para sparring
                            },
                            child: const Text(
                              'CHAMAR PARA SPARRING',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF912626),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;

  const _StatBox({required this.label, required this.value, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}

class _EstiloChip extends StatelessWidget {
  final String texto;

  const _EstiloChip({required this.texto, super.key});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(texto),
      backgroundColor: const Color(0xFF912626).withOpacity(0.1),
      labelStyle: const TextStyle(color: Color(0xFF912626)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF912626)),
      ),
    );
  }
}
