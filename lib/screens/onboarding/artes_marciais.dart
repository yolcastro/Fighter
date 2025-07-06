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
  final Map<String, String> selecionadas = {};

  bool get podeAvancar => selecionadas.values.any((nivel) => nivel.isNotEmpty);

  Future<void> selecionarArte(String arte) async {
    if (!selecionadas.containsKey(arte)) {
      final nivel = await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        builder: (_) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
          child: Wrap(
            runSpacing: 16,
            children: niveis
                .map((n) => SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, n),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8D0000),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 18),
                        ),
                        child: Text(
                          n,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
        ),
      );
      if (nivel != null) {
        setState(() => selecionadas[arte] = nivel);
      }
    }
  }

  void selecionarNivel(String arte, String nivel) {
    setState(() => selecionadas[arte] = nivel);
  }

  void removerArte(String arte) {
    setState(() => selecionadas.remove(arte));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBotaoVoltar(),
                  const SizedBox(height: 24),
                  _buildTitulo(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildListaArtes()),
                  const SizedBox(height: 24),
                  _buildBotaoProximo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoVoltar() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
      tooltip: 'Voltar',
      onPressed: () => Navigator.pop(context),
      splashRadius: 24,
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'O que você pratica?',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF000000),
      ),
    );
  }

  Widget _buildListaArtes() {
    return ListView.builder(
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
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: selecionada ? const Color(0xFF8D0000).withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: selecionada ? const Color(0xFF8D0000) : const Color(0xFFE0E0E0),
                    width: 1.6,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        arte,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: selecionada ? const Color(0xFF8D0000) : const Color(0xFF000000),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (selecionada)
                      GestureDetector(
                        onTap: () => removerArte(arte),
                        child: const Icon(Icons.close, size: 20, color: Color(0xFF8D0000)),
                      ),
                  ],
                ),
              ),
            ),
            if (selecionada)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Wrap(
                  spacing: 12,
                  children: niveis.map((n) {
                    final ativo = nivelSelecionado == n;
                    return ChoiceChip(
                      label: Text(n),
                      selected: ativo,
                      onSelected: (_) => selecionarNivel(arte, n),
                      selectedColor: const Color(0xFF8D0000),
                      backgroundColor: const Color(0xFFF5F5F5),
                      labelStyle: TextStyle(
                        color: ativo ? Colors.white : const Color(0xFF000000),
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    );
                  }).toList(),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildBotaoProximo() {
    return Center(
      child: SizedBox(
        width: 220,
        height: 56,
        child: ElevatedButton(
          onPressed: podeAvancar ? () => Navigator.pushNamed(context, '/fotoperfil') : null,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
              if (states.contains(MaterialState.disabled)) {
                return const Color(0xFF8D0000).withOpacity(0.5);
              }
              return const Color(0xFF8D0000);
            }),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            ),
            elevation: MaterialStateProperty.resolveWith<double>((states) {
              if (states.contains(MaterialState.disabled)) return 0;
              return 4;
            }),
            shadowColor: MaterialStateProperty.all(Colors.black12),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 14)),
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
    );
  }
}