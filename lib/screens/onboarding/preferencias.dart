import 'package:flutter/material.dart';
import 'artes_marciais.dart';

class PreferenciasParceiroPage extends StatefulWidget {
  const PreferenciasParceiroPage({super.key});

  @override
  _PreferenciasParceiroPageState createState() => _PreferenciasParceiroPageState();
}

class _PreferenciasParceiroPageState extends State<PreferenciasParceiroPage> {
  String generoSelecionado = 'Feminino';
  RangeValues faixaEtaria = const RangeValues(18, 80);
  Set<String> experienciasSelecionadas = {'Intermediário'};
  RangeValues faixaPeso = const RangeValues(40, 150);
  RangeValues faixaAltura = const RangeValues(140, 210);

  final List<String> generos = ['Masculino', 'Feminino', 'Outro'];
  final List<String> niveis = ['Iniciante', 'Intermediário', 'Avançado'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
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
                'Personalize a sua experiência',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Escolha suas preferências de parceiro de treino.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gênero', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ...generos.map(
                      (g) => RadioListTile<String>(
                        value: g,
                        groupValue: generoSelecionado,
                        activeColor: const Color(0xFF8B2E2E),
                        onChanged: (value) => setState(() => generoSelecionado = value!),
                        title: Text(g),
                      ),
                    ),
                    const Divider(),
                    const Text('Faixa etária', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    RangeSlider(
                      values: faixaEtaria,
                      onChanged: (values) => setState(() => faixaEtaria = values),
                      min: 18,
                      max: 80,
                      activeColor: const Color(0xFF8B2E2E),
                      divisions: 62,
                      labels: RangeLabels(
                        '${faixaEtaria.start.round()} anos',
                        '${faixaEtaria.end.round()} anos',
                      ),
                    ),
                    Text('De ${faixaEtaria.start.round()} até ${faixaEtaria.end.round()} anos'),
                    const Divider(),
                    const Text('Níveis de experiência', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ...niveis.map(
                      (n) => CheckboxListTile(
                        title: Text(n),
                        value: experienciasSelecionadas.contains(n),
                        activeColor: const Color(0xFF8B2E2E),
                        onChanged: (bool? selecionado) {
                          setState(() {
                            if (selecionado == true) {
                              experienciasSelecionadas.add(n);
                            } else {
                              experienciasSelecionadas.remove(n);
                            }
                          });
                        },
                      ),
                    ),
                    const Divider(),
                    const Text('Faixa de peso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    RangeSlider(
                      values: faixaPeso,
                      onChanged: (values) => setState(() => faixaPeso = values),
                      min: 40,
                      max: 150,
                      activeColor: const Color(0xFF8B2E2E),
                      labels: RangeLabels(
                        '${faixaPeso.start.round()} kg',
                        '${faixaPeso.end.round()} kg',
                      ),
                    ),
                    Text('De ${faixaPeso.start.round()} até ${faixaPeso.end.round()} kg'),
                    const Divider(),
                    const Text('Faixa de altura', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    RangeSlider(
                      values: faixaAltura,
                      onChanged: (values) => setState(() => faixaAltura = values),
                      min: 140,
                      max: 210,
                      activeColor: const Color(0xFF8B2E2E),
                      labels: RangeLabels(
                        '${faixaAltura.start.round()} cm',
                        '${faixaAltura.end.round()} cm',
                      ),
                    ),
                    Text('De ${faixaAltura.start.round()} até ${faixaAltura.end.round()} cm'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TelaArtesMarciais()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B2E2E),
                    padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
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
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
