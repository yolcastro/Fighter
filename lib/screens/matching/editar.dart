import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // Importe para usar DateFormat

import 'package:fighter_app/usuario.service.dart';
import 'editar_artes.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final TextEditingController nomeController = TextEditingController();
  final TextEditingController generoController = TextEditingController();
  final TextEditingController alturaController = TextEditingController();
  final TextEditingController descricaoController = TextEditingController();

  File? _imagemSelecionada;

  String? pesoCategoriaSelecionada;

  int diaSelecionado = 1;
  String mesSelecionado = 'janeiro';
  int anoSelecionado = 2000;

  String? estadoSelecionado;
  String? cidadeSelecionada;

  final List<int> dias = List.generate(31, (index) => index + 1);
  final List<String> meses = [
    'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
    'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
  ];
  final List<int> anos = List.generate(100, (index) => DateTime.now().year - index);

  final List<String> categoriasPesoUFC = [
    'Peso Mosca (até 56.7kg)',
    'Peso Galo (até 61.2kg)',
    'Peso Pena (até 65.8kg)',
    'Peso Leve (até 70.3kg)',
    'Peso Meio-Médio (até 77.1kg)',
    'Peso Médio (até 83.9kg)',
    'Peso Meio-Pesado (até 93.0kg)',
    'Peso Pesado (até 120.2kg)',
  ];

  final List<String> generos = ['Masculino', 'Feminino', 'Outro'];

  final Map<String, String> nomesEstados = {
    'CE': 'Ceará',
    'SP': 'São Paulo',
    'RJ': 'Rio de Janeiro',
    'MG': 'Minas Gerais',
  };

  final Map<String, List<String>> cidadesPorEstado = {
    'CE': ['Fortaleza', 'Caucaia', 'Itaitinga', 'Maracanaú'],
  };

  @override
  void initState() {
    super.initState();
    carregarDadosUsuario();
  }

  // Função auxiliar para obter o número do mês a partir do nome
  int _obterNumeroMes(String mesNome) {
    return meses.indexOf(mesNome) + 1;
  }

  // Função auxiliar para obter o nome do mês a partir do número
  String _obterNomeMes(int mesNumero) {
    if (mesNumero >= 1 && mesNumero <= 12) {
      return meses[mesNumero - 1];
    }
    return 'janeiro'; // Padrão
  }

  Future<void> carregarDadosUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dados = await UsuarioService.buscarUsuarioPorId(user.uid);
    if (dados == null) return;

    setState(() {
      nomeController.text = dados['nome'] ?? '';
      generoController.text = dados['sexo'] ?? '';
      alturaController.text = (dados['alturaEmCm'] ?? '').toString();
      descricaoController.text = dados['descricao'] ?? '';

      pesoCategoriaSelecionada = categoriasPesoUFC.contains(dados['pesoCategoria'])
          ? dados['pesoCategoria']
          : categoriasPesoUFC[0];

      if (dados['localizacao'] != null && dados['localizacao'].contains('-')) {
        final partes = dados['localizacao'].split(' - ');
        cidadeSelecionada = partes[0].trim();
        estadoSelecionado = partes[1].trim();
      }

      // CORREÇÃO: Parsear dataNascimento no formato DD/MM/YYYY
      if (dados['dataNascimento'] != null && dados['dataNascimento'].isNotEmpty) {
        try {
          final DateTime parsedDate = DateFormat('dd/MM/yyyy').parse(dados['dataNascimento']);
          diaSelecionado = parsedDate.day;
          mesSelecionado = _obterNomeMes(parsedDate.month);
          anoSelecionado = parsedDate.year;
        } catch (e) {
          print('Erro ao parsear dataNascimento (DD/MM/YYYY) em EditarPerfil: $e');
          // Manter valores padrão se o parse falhar
        }
      }
    });
  }

  Future<void> salvarPerfil() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic> dadosAtualizados = {};

    if (nomeController.text.trim().isNotEmpty) {
      dadosAtualizados['nome'] = nomeController.text.trim();
    }
    if (generoController.text.trim().isNotEmpty) {
      dadosAtualizados['sexo'] = generoController.text.trim();
    }
    if (alturaController.text.trim().isNotEmpty) {
      final altura = int.tryParse(alturaController.text.trim());
      if (altura != null) dadosAtualizados['alturaEmCm'] = altura;
    }
    if (descricaoController.text.trim().isNotEmpty) {
      final descricao = descricaoController.text.trim();
      if (descricao.length > 250) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('A descrição deve ter no máximo 250 caracteres.')),
        );
        return;
      }
      dadosAtualizados['descricao'] = descricao;
    }
    if (pesoCategoriaSelecionada != null) {
      dadosAtualizados['pesoCategoria'] = pesoCategoriaSelecionada;
    }
    if (cidadeSelecionada != null && estadoSelecionado != null) {
      dadosAtualizados['localizacao'] = '$cidadeSelecionada - $estadoSelecionado';
    }

    // CORREÇÃO: Formatar dataNascimento para DD/MM/YYYY antes de salvar
    final String formattedDay = diaSelecionado.toString().padLeft(2, '0');
    final String formattedMonth = _obterNumeroMes(mesSelecionado).toString().padLeft(2, '0');
    final String formattedYear = anoSelecionado.toString();
    dadosAtualizados['dataNascimento'] = '$formattedDay/$formattedMonth/$formattedYear';


    if (dadosAtualizados.isNotEmpty) {
      await UsuarioService.atualizarUsuario(user.uid, dadosAtualizados);
    }

    Navigator.pop(context, true);
  }

  Future<void> _escolherImagem() async {
    final picker = ImagePicker();
    final imagem = await picker.pickImage(source: ImageSource.gallery);
    if (imagem != null) {
      setState(() {
        _imagemSelecionada = File(imagem.path);
      });
    }
  }

  void _mostrarPopupGenero() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFEFEFEF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: generos.map((genero) {
                return RadioListTile<String>(
                  title: Text(genero),
                  value: genero,
                  groupValue: generoController.text,
                  activeColor: const Color(0xFF8D0000),
                  onChanged: (value) {
                    setState(() {
                      generoController.text = value!;
                    });
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    nomeController.dispose();
    generoController.dispose();
    alturaController.dispose();
    descricaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  children: [
                    _buildFoto(),
                    const SizedBox(height: 30),
                    _buildCampo('Nome', nomeController),
                    _buildDataNascimentoCampo(),
                    _buildEstadoCidadeCampos(),
                    _buildCampo('Gênero', generoController),
                    _buildAlturaCampo(),
                    _buildDropdownCampo('Categoria de Peso', pesoCategoriaSelecionada, categoriasPesoUFC),
                    _buildDescricaoCampo(),
                    const SizedBox(height: 30),
                    _buildAlterarArtesButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFFEFEFEF),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const Text(
            'Edite seu perfil',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.save, color: Color(0xFF8B2E2E)),
              onPressed: salvarPerfil,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoto() {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        CircleAvatar(
          radius: 70,
          backgroundImage: _imagemSelecionada != null
              ? FileImage(_imagemSelecionada!)
              : const AssetImage('assets/usuario.jpg') as ImageProvider,
        ),
        Positioned(
          bottom: 0,
          right: 4,
          child: GestureDetector(
            onTap: _escolherImagem,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Color(0xFF8B2E2E),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCampo(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: label == 'Gênero' ? _mostrarPopupGenero : null,
          child: AbsorbPointer(
            absorbing: label == 'Gênero',
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 4),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const Divider(thickness: 1, color: Colors.black),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDescricaoCampo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Descrição (máx. 250 caracteres)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: descricaoController,
          maxLines: null,
          maxLength: 250,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        const Divider(thickness: 1, color: Colors.black),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAlturaCampo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Altura', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        TextField(
          controller: alturaController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 4),
            suffixText: 'cm',
          ),
          style: const TextStyle(fontSize: 16),
        ),
        const Divider(thickness: 1, color: Colors.black),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDataNascimentoCampo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data de nascimento', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            _buildDropdown(diaSelecionado, dias, (value) => setState(() => diaSelecionado = value)),
            const SizedBox(width: 8),
            _buildDropdown(mesSelecionado, meses, (value) => setState(() => mesSelecionado = value)),
            const SizedBox(width: 8),
            _buildDropdown(anoSelecionado, anos, (value) => setState(() => anoSelecionado = value)),
          ],
        ),
        const Divider(thickness: 1, color: Colors.black),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDropdown<T>(T value, List<T> items, void Function(T) onChanged) {
    return Expanded(
      child: DropdownButtonFormField<T>(
        value: value,
        items: items.map((item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(item.toString(), style: const TextStyle(fontSize: 16)),
          );
        }).toList(),
        onChanged: (newValue) => onChanged(newValue!),
        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
      ),
    );
  }

  Widget _buildEstadoCidadeCampos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estado e Cidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            _buildDropdown<String>(
              estadoSelecionado ?? nomesEstados.keys.first,
              nomesEstados.keys.toList(),
              (value) {
                setState(() {
                  estadoSelecionado = value;
                  cidadeSelecionada = cidadesPorEstado[value]?.first;
                });
              },
            ),
            const SizedBox(width: 8),
            _buildDropdown<String>(
              cidadeSelecionada ?? '',
              (cidadesPorEstado[estadoSelecionado] ?? []),
              (value) => setState(() => cidadeSelecionada = value),
            ),
          ],
        ),
        const Divider(thickness: 1, color: Colors.black),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDropdownCampo(String label, String? value, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        DropdownButtonFormField<String>(
          value: value,
          items: options.map((option) {
            return DropdownMenuItem<String>(
              value: option,
              child: Text(option, style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
          onChanged: (newValue) => setState(() => pesoCategoriaSelecionada = newValue),
          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
        ),
        const Divider(thickness: 1, color: Colors.black),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAlterarArtesButton() {
    return SizedBox(
      width: 200,
      height: 48,
      child: ElevatedButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EditarArtes())),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8D0000),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
          elevation: 4,
          shadowColor: Colors.black12,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text('Alterar artes marciais', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
      ),
    );
  }
}
