import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: MeuPerfilPage()),
  );
}

class MeuPerfilPage extends StatelessWidget {
  const MeuPerfilPage({super.key});

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
                    // Ícone de configurações
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ConfiguracoesPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey,
                      backgroundImage: AssetImage('assets/images/perfil.png'),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nome do Lutador',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text('@usuario • Peso Medio'),
                    const SizedBox(height: 24),

                    const Text(
                      'ESTATÍSTICAS',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: const [
                        _StatBox(label: 'Vitórias', value: '12'),
                        _StatBox(label: 'Derrotas', value: '3'),
                        _StatBox(label: 'Empates', value: '1'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'BIOGRAFIA',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Lutador apaixonado por Muay Thai desde 2019.\n'
                      'Treina 5x por semana e participa de campeonatos locais.',
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
                        _EstiloChip(texto: 'Muay Thai'),
                        _EstiloChip(texto: 'Jiu-Jitsu'),
                        _EstiloChip(texto: 'Boxe'),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // NOVA SEÇÃO – Detalhes do lutador
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'DETALHES DO LUTADOR',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [Text('Altura:'), Text('178 cm')],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Nível de Experiência:'),
                            Text('Avançado'),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [Text('Reputação:'), Text('3,45/5')],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF912626),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditarPerfilPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'EDITAR PERFIL',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
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

class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        backgroundColor: const Color(0xFF912626),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ListTile(
              leading: Icon(Icons.lock),
              title: Text('Alterar Senha'),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notificações'),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(Icons.language),
              title: Text('Idioma'),
            ),
            const Spacer(),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                side: const BorderSide(color: Color(0xFF912626)),
              ),
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text(
                'SAIR DA CONTA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF912626),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EditarPerfilPage extends StatelessWidget {
  const EditarPerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final nomeController = TextEditingController(text: 'Nome do Lutador');
    final usuarioController = TextEditingController(text: '@usuario');
    final bioController = TextEditingController(
      text: 'Lutador apaixonado por Muay Thai desde 2019...',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: const Color(0xFF912626),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Nome'),
            TextField(controller: nomeController),
            const SizedBox(height: 16),
            const Text('Usuário'),
            TextField(controller: usuarioController),
            const SizedBox(height: 16),
            const Text('Biografia'),
            TextField(controller: bioController, maxLines: 4),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF912626),
              ),
              onPressed: () {
                // Aqui você pode salvar os dados depois
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }
}
