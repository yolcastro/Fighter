import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fighter_app/usuario.service.dart';

class TelaLocalizacao extends StatefulWidget {
  const TelaLocalizacao({super.key});

  @override
  State<TelaLocalizacao> createState() => _TelaLocalizacaoState();
}

class _TelaLocalizacaoState extends State<TelaLocalizacao> {
  final List<String> estados = ['CE', 'SP', 'RJ', 'MG'];

  final Map<String, String> nomesEstados = {
    'CE': 'Ceará',
    'SP': 'São Paulo',
    'RJ': 'Rio de Janeiro',
    'MG': 'Minas Gerais',
  };

  final Map<String, List<String>> cidadesPorEstado = {
    'CE': ['Fortaleza', 'Caucaia', 'Itaitinga', 'Maracanaú'],
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

    // Obter UID do usuário logado
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário logado. Faça login novamente.')),
      );
      return;
    }

    // Preparar dados para atualização: localização concatenada
    final String localizacao = '$cidadeSelecionada - $estadoSelecionado';

    final Map<String, dynamic> updateData = {
      'localizacao': localizacao,
    };

    print('Enviando updateData: $updateData');

    // Chamar a função de atualização sem await e sem loading
    UsuarioService.atualizarUsuario(currentUser.uid, updateData).then((success) {
      if (success) {
        print('Localização atualizada com sucesso para o UID: ${currentUser.uid}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Localização atualizada com sucesso!')),
        );
      } else {
        print('Erro ao atualizar localização para o UID: ${currentUser.uid}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar localização.')),
        );
      }
    });

    // Navegar imediatamente para a próxima tela
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
        cidadeSelecionada = null;
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
              const SizedBox(height: 24),
              _buildLabel('Localização selecionada'),
              const SizedBox(height: 8),
              _buildConcatenacao(),
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

  Widget _buildConcatenacao() {
    return Container(
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
        cidadeSelecionada != null
            ? '$cidadeSelecionada - $estadoSelecionado'
            : 'Nenhuma cidade selecionada',
        style: const TextStyle(fontSize: 16, color: Colors.black87),
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
              fontSize: 15,
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
