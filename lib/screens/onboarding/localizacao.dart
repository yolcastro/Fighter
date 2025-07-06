import 'package:flutter/material.dart';

class TelaLocalizacao extends StatefulWidget {
  const TelaLocalizacao({super.key});

  @override
  State<TelaLocalizacao> createState() => _TelaLocalizacaoState();
}

class _TelaLocalizacaoState extends State<TelaLocalizacao> {
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

  final Map<String, List<String>> cidadesPorEstado = {
    'CE': ['Fortaleza', 'Caucaia', 'Juazeiro do Norte', 'Maracanaú'],
    'SP': ['São Paulo', 'Campinas', 'Santos', 'São Bernardo do Campo'],
    'RJ': ['Rio de Janeiro', 'Niterói', 'Duque de Caxias', 'Nova Iguaçu'],
    'MG': ['Belo Horizonte', 'Contagem', 'Uberlândia', 'Juiz de Fora'],
    // adicione mais estados e cidades conforme necessidade
  };

  String estadoSelecionado = 'CE';
  String? cidadeSelecionada;

  void avancar() {
    if (cidadeSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione sua cidade')),
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
            title: Text(
              '${nomesEstados[sigla]} ($sigla)',
              style: const TextStyle(fontSize: 16, color: Color(0xFF343434)),
            ),
            activeColor: const Color(0xFF8D0000),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        }).toList(),
      ),
    );

    if (selecionado != null) {
      setState(() {
        estadoSelecionado = selecionado;
        cidadeSelecionada = null; // reseta a cidade ao trocar de estado
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cidades = cidadesPorEstado[estadoSelecionado] ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBotaoVoltar(),
              const SizedBox(height: 40),
              _buildTitulo(),
              const SizedBox(height: 32),
              _buildLabel('Estado'),
              const SizedBox(height: 8),
              _buildEstadoSelector(),
              const SizedBox(height: 24),
              _buildLabel('Cidade'),
              const SizedBox(height: 8),
              _buildDropdownCidade(cidades),
              const Spacer(),
              _buildBotaoProximo(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoVoltar() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
      onPressed: () => Navigator.pop(context),
      splashRadius: 24,
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'Agora, onde você se localiza?',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF000000),
      ),
    );
  }

  Widget _buildLabel(String texto) {
    return Text(
      texto,
      style: const TextStyle(fontSize: 16, color: Color(0xFF343434)),
    );
  }

  Widget _buildEstadoSelector() {
    return GestureDetector(
      onTap: selecionarEstado,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '${nomesEstados[estadoSelecionado]} ($estadoSelecionado)',
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildDropdownCidade(List<String> cidades) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: cidadeSelecionada,
          hint: const Text(
            'Selecione sua cidade',
            style: TextStyle(color: Color(0xFF555555), fontSize: 16),
          ),
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: Colors.black54),
          items: cidades.map((cidade) {
            return DropdownMenuItem<String>(
              value: cidade,
              child: Text(
                cidade,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
            );
          }).toList(),
          onChanged: (valor) {
            setState(() {
              cidadeSelecionada = valor;
            });
          },
        ),
      ),
    );
  }

  Widget _buildBotaoProximo() {
    return Center(
      child: SizedBox(
        width: 220,
        height: 56,
        child: ElevatedButton(
          onPressed: avancar,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8D0000),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            elevation: 4,
            shadowColor: Colors.black12,
            padding: const EdgeInsets.symmetric(vertical: 20),
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