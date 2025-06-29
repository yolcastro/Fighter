import 'package:flutter/material.dart';

class TelaCaracteristicas extends StatefulWidget {
  const TelaCaracteristicas({super.key});

  @override
  State<TelaCaracteristicas> createState() => _TelaCaracteristicasState();
}

class _TelaCaracteristicasState extends State<TelaCaracteristicas> {
  String generoSelecionado = 'Feminino';
  final List<String> generos = ['Feminino', 'Masculino', 'Outro'];

  final TextEditingController pesoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();

  String? ultimoPesoValido;
  String? ultimaAlturaValida;

  @override
  void initState() {
    super.initState();
    
    pesoController.text = '70';
    alturaController.text = '170';
    ultimoPesoValido = pesoController.text;
    ultimaAlturaValida = alturaController.text;
  }

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
              const SizedBox(height: 32),
              _buildCampoGenero(),
              const SizedBox(height: 24),
              _buildCampoPeso(),
              const SizedBox(height: 24),
              _buildCampoAltura(),
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
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'Monte o seu perfil',
      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildCampoGenero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gênero', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            String? selecionado = await showDialog<String>(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  children: generos.map((opcao) {
                    return RadioListTile<String>(
                      value: opcao,
                      groupValue: generoSelecionado,
                      onChanged: (value) {
                        Navigator.pop(context, value);
                      },
                      title: Text(opcao),
                      activeColor: const Color(0xFF8B2E2E),
                    );
                  }).toList(),
                );
              },
            );
            if (selecionado != null) {
              setState(() {
                generoSelecionado = selecionado;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              generoSelecionado,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampoPeso() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Peso', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        TextField(
          controller: pesoController,
          keyboardType: TextInputType.number,
          decoration: _inputEstilo('kg', 'kg'),
          onChanged: (value) {
            final num? peso = num.tryParse(value);
            if (peso == null || peso < 40 || peso > 150) {
              
              pesoController.text = ultimoPesoValido ?? '';
              pesoController.selection = TextSelection.fromPosition(
                TextPosition(offset: pesoController.text.length),
              );
            } else {
              ultimoPesoValido = value;
            }
          },
        ),
      ],
    );
  }

  Widget _buildCampoAltura() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Altura', style: TextStyle(fontSize: 18)),
        const SizedBox(height: 8),
        TextField(
          controller: alturaController,
          keyboardType: TextInputType.number,
          decoration: _inputEstilo('cm', 'cm'),
          onChanged: (value) {
            final num? altura = num.tryParse(value);
            if (altura == null || altura < 140 || altura > 210) {
              alturaController.text = ultimaAlturaValida ?? '';
              alturaController.selection = TextSelection.fromPosition(
                TextPosition(offset: alturaController.text.length),
              );
            } else {
              ultimaAlturaValida = value;
            }
          },
        ),
      ],
    );
  }

  Widget _buildBotaoProximo(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () {
          
          Navigator.pushNamed(context, '/preferencias');
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

  InputDecoration _inputEstilo(String hint, String sufixo) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[300],
      suffixText: sufixo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    );
  }
}
