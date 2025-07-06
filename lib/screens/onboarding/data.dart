import 'package:flutter/material.dart';
import 'package:fighter_app/usuario.service.dart';
import 'localizacao.dart';

class TelaDataNascimento extends StatefulWidget {
  const TelaDataNascimento({super.key});

  @override
  State<TelaDataNascimento> createState() => _TelaDataNascimentoState();
}

class _TelaDataNascimentoState extends State<TelaDataNascimento> {
  String? dia = '1';
  String? mes = 'janeiro';
  String? ano = '2000';

  final dias = List.generate(31, (i) => '${i + 1}');
  final meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro',
  ];
  final anos = List.generate(100, (i) => '${DateTime.now().year - i}');

  int obterNumeroMes(String mes) {
    return meses.indexOf(mes) + 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBotaoVoltar(context),
              const SizedBox(height: 40),
              _buildTitulo(),
              const SizedBox(height: 32),
              _buildCamposData(),
              const SizedBox(height: 48),
              _buildBotaoProximo(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoVoltar(BuildContext context) {
    return IconButton(
      onPressed: () => Navigator.pop(context),
      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
      splashRadius: 24,
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'Qual sua data de nascimento?',
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFF000000),
      ),
    );
  }

  Widget _buildCamposData() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildDropdown('Dia', dia, dias, (v) => setState(() => dia = v)),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: _buildDropdown('Mês', mes, meses, (v) => setState(() => mes = v)),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: _buildDropdown('Ano', ano, anos, (v) => setState(() => ano = v)),
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? valor, List<String> opcoes, ValueChanged<String?> onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: Color(0xFF343434)),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFDADADA),
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonFormField<String>(
            isDense: true,
            isExpanded: true,
            value: valor,
            items: opcoes.map((item) => DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            )).toList(),
            onChanged: onChange,
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
            style: const TextStyle(fontSize: 16, color: Color(0xFF000000)),
            iconEnabledColor: const Color(0xFF8D0000),
            dropdownColor: const Color(0xFFFFFFFF),
          ),
        ),
      ],
    );
  }

  Widget _buildBotaoProximo(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 56,
        child: ElevatedButton(
          onPressed: () async {
            if (dia == null || mes == null || ano == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Selecione sua data de nascimento')),
              );
              return;
            }

            final numeroMes = obterNumeroMes(mes!);
            final dataNascimento = '$ano-${numeroMes.toString().padLeft(2, '0')}-${dia!.padLeft(2, '0')}';

            String? uid = await UsuarioService.criarUsuario({
              'nome': 'Seu Nome',
              'email': 'exemplo@email.com',
              'sexo': 'Masculino',
              'pesoCategoria': 'Leve',
              'alturaEmCm': 175,
              'arteMarcial': ['Muay Thai'],
              'nivelExperiencia': 'Iniciante',
              'localizacao': 'São Paulo',
              'fotoPerfilUrl': 'https://link-da-foto.jpg',
              'descricao': 'Descrição exemplo',
              'dataNascimento': dataNascimento,
            });

            if (uid != null) {
              print('Usuário criado com UID: $uid');

              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TelaLocalizacao()),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Erro ao criar usuário.')),
              );
            }
          },
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
              color: Colors.white,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}