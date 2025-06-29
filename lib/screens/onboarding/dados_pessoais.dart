import 'package:flutter/material.dart';

class TelaDadosPessoais extends StatefulWidget {
  const TelaDadosPessoais({super.key});

  @override
  State<TelaDadosPessoais> createState() => _TelaDadosPessoaisState();
}

class _TelaDadosPessoaisState extends State<TelaDadosPessoais> {
  final nomeController = TextEditingController();

  String? dia = '1';
  String? mes = 'janeiro';
  String? ano = '2000';

  final dias = List.generate(31, (i) => '${i + 1}');
  final meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];
  final anos = List.generate(100, (i) => '${DateTime.now().year - i}');

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
              const SizedBox(height: 24),
              _buildCampoNome(),
              const SizedBox(height: 24),
              _buildCamposData(),
              const Spacer(),
              _buildBotaoProximo(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoVoltar(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
      onPressed: () => Navigator.pop(context),
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'Qual seu nome e data de nascimento?',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCampoNome() {
    return TextField(
      controller: nomeController,
      decoration: _inputEstilo('Seu nome'),
    );
  }

  Widget _buildCamposData() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Dia'),
              const SizedBox(height: 6),
              _dropdown(dia, dias, (v) => setState(() => dia = v)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Mês'),
              const SizedBox(height: 6),
              _dropdown(mes, meses, (v) => setState(() => mes = v)),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ano'),
              const SizedBox(height: 6),
              _dropdown(ano, anos, (v) => setState(() => ano = v)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoProximo(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          if (nomeController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Digite seu nome')),
            );
            return;
          }
          Navigator.pushNamed(context, '/localizacao');
        },
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
    );
  }

  InputDecoration _inputEstilo(String texto) {
    return InputDecoration(
      hintText: texto,
      filled: true,
      fillColor: Colors.grey[300],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }

  Widget _dropdown(String? valor, List<String> itens, ValueChanged<String?> onChange) {
    return DropdownButtonFormField<String>(
      value: valor,
      items: itens.map((item) => DropdownMenuItem(value: item, child: Text(item))).toList(),
      onChanged: onChange,
      decoration: _inputEstilo(''),
    );
  }
}
