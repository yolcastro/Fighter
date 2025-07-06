import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fighter_app/usuario.service.dart';

class TelaCaracteristicas extends StatefulWidget {
  const TelaCaracteristicas({super.key});

  @override
  State<TelaCaracteristicas> createState() => _TelaCaracteristicasState();
}

class _TelaCaracteristicasState extends State<TelaCaracteristicas> {
  String generoSelecionado = 'Feminino';
  final List<String> generos = ['Feminino', 'Masculino', 'Outro'];

  final List<String> categoriasPesoUFC = [
    'Peso Mosca (até 56,7kg)',
    'Peso Galo (até 61,2kg)',
    'Peso Pena (até 65,8kg)',
    'Peso Leve (até 70,3kg)',
    'Peso Meio Médio (até 77,1kg)',
    'Peso Médio (até 83,9kg)',
    'Peso Meio Pesado (até 93,0kg)',
    'Peso Pesado (até 120,2kg)',
  ];
  String categoriaPesoSelecionada = 'Peso Mosca (até 56,7kg)';

  final TextEditingController alturaController = TextEditingController(text: '170');
  String? ultimaAlturaValida = '170';

  String? erroAltura;

  @override
  void initState() {
    super.initState();
    _validarAltura(alturaController.text);
  }

  @override
  void dispose() {
    alturaController.dispose();
    super.dispose();
  }

  bool get alturaValida =>
      erroAltura == null && (ultimaAlturaValida != null && ultimaAlturaValida!.isNotEmpty);

  void avancar() {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário logado. Faça login novamente.')),
      );
      return;
    }

    final Map<String, dynamic> updateData = {
      'pesoCategoria': categoriaPesoSelecionada,
      'alturaEmCm': int.tryParse(ultimaAlturaValida ?? '0'),
      'sexo': generoSelecionado,
    };

    print('Enviando updateData: $updateData');

    UsuarioService.atualizarUsuario(currentUser.uid, updateData).then((success) {
      if (success) {
        print('Características atualizadas com sucesso para o UID: ${currentUser.uid}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Características atualizadas com sucesso!')),
        );
      } else {
        print('Erro ao atualizar características para o UID: ${currentUser.uid}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao atualizar características.')),
        );
      }
    });

    Navigator.pushNamed(context, '/preferencias');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: SingleChildScrollView( // ✅ PREVINE OVERFLOW
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBotaoVoltar(),
                const SizedBox(height: 40),
                _buildTitulo(),
                const SizedBox(height: 32),
                _buildCampoGenero(),
                const SizedBox(height: 24),
                _buildCampoPeso(),
                const SizedBox(height: 24),
                _buildCampoAltura(),
                if (erroAltura != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      erroAltura!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 40), // substitui Spacer por altura fixa
                _buildBotaoProximo(),
                const SizedBox(height: 24),
              ],
            ),
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
      'Monte o seu perfil',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF000000),
      ),
    );
  }

  Widget _buildCampoGenero() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Gênero', style: TextStyle(fontSize: 18, color: Color(0xFF343434))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _selecionarGenero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: const Color(0xFFDADADA),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Text(
              generoSelecionado,
              style: const TextStyle(fontSize: 16, color: Color(0xFF000000)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selecionarGenero() async {
    final selecionado = await showDialog<String>(
      context: context,
      builder: (_) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        children: generos.map((opcao) {
          return RadioListTile<String>(
            value: opcao,
            groupValue: generoSelecionado,
            onChanged: (v) => Navigator.pop(context, v),
            title: Text(opcao),
            activeColor: const Color(0xFF8D0000),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        }).toList(),
      ),
    );
    if (selecionado != null) {
      setState(() => generoSelecionado = selecionado);
    }
  }

  Widget _buildCampoPeso() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categoria de peso (UFC)', style: TextStyle(fontSize: 18, color: Color(0xFF343434))),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFDADADA),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
          ),
          child: DropdownButton<String>(
            isExpanded: true,
            value: categoriaPesoSelecionada,
            iconEnabledColor: const Color(0xFF8D0000),
            underline: const SizedBox(),
            style: const TextStyle(color: Color(0xFF000000), fontSize: 16),
            items: categoriasPesoUFC
                .map((cat) => DropdownMenuItem<String>(value: cat, child: Text(cat)))
                .toList(),
            onChanged: (value) => setState(() => categoriaPesoSelecionada = value!),
          ),
        ),
      ],
    );
  }

  Widget _buildCampoAltura() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Altura', style: TextStyle(fontSize: 18, color: Color(0xFF343434))),
        const SizedBox(height: 8),
        TextField(
          controller: alturaController,
          keyboardType: TextInputType.number,
          decoration: _inputEstilo('cm', 'cm'),
          style: const TextStyle(color: Color(0xFF000000), fontSize: 16),
          onChanged: _validarAltura,
        ),
      ],
    );
  }

  void _validarAltura(String value) {
    final num? altura = num.tryParse(value);
    String? mensagemErro;

    if (altura == null) {
      mensagemErro = 'Informe um número válido.';
    } else if (altura < 140) {
      mensagemErro = 'Altura mínima é 140 cm.';
    } else if (altura > 210) {
      mensagemErro = 'Altura máxima é 210 cm.';
    }

    setState(() {
      erroAltura = mensagemErro;
      if (mensagemErro == null) {
        ultimaAlturaValida = value;
      }
    });
  }

  Widget _buildBotaoProximo() {
    return Center(
      child: SizedBox(
        width: 220,
        height: 56,
        child: ElevatedButton(
          onPressed: alturaValida ? avancar : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8D0000),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            shadowColor: Colors.black12,
            padding: const EdgeInsets.symmetric(vertical: 20),
            elevation: 4,
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

  InputDecoration _inputEstilo(String hint, String sufixo) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 16),
      filled: true,
      fillColor: const Color(0xFFDADADA),
      suffixText: sufixo,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    );
  }
}
