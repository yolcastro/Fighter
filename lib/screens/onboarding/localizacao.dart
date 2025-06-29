import 'package:flutter/material.dart';

class TelaLocalizacao extends StatefulWidget {
  const TelaLocalizacao({super.key});

  @override
  State<TelaLocalizacao> createState() => _TelaLocalizacaoState();
}

class _TelaLocalizacaoState extends State<TelaLocalizacao> {
  final TextEditingController cidadeController = TextEditingController();

  final List<String> estados = [
    'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO',
    'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI',
    'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO',
  ];

  final Map<String, String> nomesEstados = {
    'AC': 'Acre', 'AL': 'Alagoas', 'AP': 'Amapá', 'AM': 'Amazonas',
    'BA': 'Bahia', 'CE': 'Ceará', 'DF': 'Distrito Federal', 'ES': 'Espírito Santo',
    'GO': 'Goiás', 'MA': 'Maranhão', 'MT': 'Mato Grosso', 'MS': 'Mato Grosso do Sul',
    'MG': 'Minas Gerais', 'PA': 'Pará', 'PB': 'Paraíba', 'PR': 'Paraná',
    'PE': 'Pernambuco', 'PI': 'Piauí', 'RJ': 'Rio de Janeiro', 'RN': 'Rio Grande do Norte',
    'RS': 'Rio Grande do Sul', 'RO': 'Rondônia', 'RR': 'Roraima', 'SC': 'Santa Catarina',
    'SP': 'São Paulo', 'SE': 'Sergipe', 'TO': 'Tocantins',
  };

  String estadoSelecionado = 'CE';

  void avancar() {
    if (cidadeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite sua cidade')),
      );
      return;
    }

    Navigator.pushNamed(context, '/caracteristicas');
  }

  Future<void> selecionarEstado() async {
    final selecionado = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        children: estados.map((sigla) {
          return RadioListTile<String>(
            value: sigla,
            groupValue: estadoSelecionado,
            onChanged: (v) => Navigator.pop(context, v),
            title: Text('${nomesEstados[sigla]} ($sigla)'),
            activeColor: const Color(0xFF8B2E2E),
          );
        }).toList(),
      ),
    );

    if (selecionado != null) {
      setState(() => estadoSelecionado = selecionado);
    }
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
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 32),

            const Text(
              'Agora, onde você se localiza?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            const Text('Estado', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: selecionarEstado,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                width: double.infinity,
                child: Text(estadoSelecionado, style: const TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Cidade', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),

            TextField(
              controller: cidadeController,
              decoration: InputDecoration(
                hintText: 'Digite sua cidade',
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const Spacer(),

            Center(
              child: ElevatedButton(
                onPressed: avancar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B2E2E),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
                ),
                child: const Text(
                  'PRÓXIMO',
                  style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
