import 'package:flutter/material.dart';
import 'artes_marciais.dart';

class PreferenciasParceiroPage extends StatefulWidget {
  const PreferenciasParceiroPage({super.key});

  @override
  State<PreferenciasParceiroPage> createState() => _PreferenciasParceiroPageState();
}

class _PreferenciasParceiroPageState extends State<PreferenciasParceiroPage> {
  Set<String> generosSelecionados = {'Feminino'};
  RangeValues faixaEtaria = const RangeValues(18, 80);
  Set<String> experienciasSelecionadas = {'Intermediário'};
  Set<String> categoriasPesoSelecionadas = {'Peso Mosca (até 56,7kg)'};

  final generos = ['Masculino', 'Feminino', 'Outro'];
  final niveis = ['Iniciante', 'Intermediário', 'Avançado'];
  final pesos = [
    'Peso Mosca (até 56,7kg)',
    'Peso Galo (até 61,2kg)',
    'Peso Pena (até 65,8kg)',
    'Peso Leve (até 70,3kg)',
    'Peso Meio Médio (até 77,1kg)',
    'Peso Médio (até 83,9kg)',
    'Peso Meio Pesado (até 93,0kg)',
    'Peso Pesado (até 120,2kg)',
  ];

  bool get podeAvancar =>
      generosSelecionados.isNotEmpty &&
      experienciasSelecionadas.isNotEmpty &&
      categoriasPesoSelecionadas.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
                    onPressed: () => Navigator.pop(context),
                    splashRadius: 24,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Preferências de parceiro',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildCheckboxGroup('Gênero', generos, generosSelecionados),
                        const SizedBox(height: 24),
                        const Text(
                          'Faixa etária',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        RangeSlider(
                          values: faixaEtaria,
                          onChanged: (v) => setState(() => faixaEtaria = v),
                          min: 18,
                          max: 80,
                          divisions: 62,
                          activeColor: const Color(0xFF8D0000),
                          labels: RangeLabels(
                            '${faixaEtaria.start.round()} anos',
                            '${faixaEtaria.end.round()} anos',
                          ),
                        ),
                        Text(
                          'De ${faixaEtaria.start.round()} até ${faixaEtaria.end.round()} anos',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 24),
                        _buildCheckboxGroup('Nível de experiência', niveis, experienciasSelecionadas),
                        const SizedBox(height: 24),
                        _buildCheckboxGroup('Categoria de peso (UFC)', pesos, categoriasPesoSelecionadas),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: podeAvancar
                            ? () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const TelaArtesMarciais()),
                                )
                            : null,
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.disabled)) {
                              return const Color(0xFF8D0000).withOpacity(0.5); // vermelho claro desativado
                            }
                            return const Color(0xFF8D0000); // vermelho normal ativo
                          }),
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
                          ),
                          elevation: MaterialStateProperty.resolveWith<double>((states) {
                            if (states.contains(MaterialState.disabled)) return 0;
                            return 4;
                          }),
                          shadowColor: MaterialStateProperty.all(Colors.black12),
                          padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 20)),
                        ),
                        child: const Text(
                          'PRÓXIMO',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxGroup(String title, List<String> opcoes, Set<String> selecionadas) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...opcoes.map(
          (opcao) => CheckboxListTile(
            title: Text(opcao, style: const TextStyle(fontSize: 14)),
            value: selecionadas.contains(opcao),
            onChanged: (val) => setState(() {
              val! ? selecionadas.add(opcao) : selecionadas.remove(opcao);
            }),
            activeColor: const Color(0xFF8D0000),
            contentPadding: EdgeInsets.zero,
            dense: true,
            visualDensity: const VisualDensity(vertical: -2),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}