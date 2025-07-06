import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'editar_artes.dart';

class EditarPerfil extends StatefulWidget {
  const EditarPerfil({super.key});

  @override
  State<EditarPerfil> createState() => _EditarPerfilState();
}

class _EditarPerfilState extends State<EditarPerfil> {
  final TextEditingController nomeController = TextEditingController(text: 'Jonas');
  final TextEditingController generoController = TextEditingController(text: 'Masculino');
  final TextEditingController alturaController = TextEditingController(text: '180');

  File? _imagemSelecionada;

  String? categoriaPesoSelecionada = 'Peso Leve (até 70.3kg)';

  int diaSelecionado = 14;
  String mesSelecionado = 'novembro';
  int anoSelecionado = 2001;

  String? estadoSelecionado = 'CE';
  String? cidadeSelecionada = 'Fortaleza';

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
    // adicione mais estados e cidades conforme necessário
  };

  Future<void> _escolherImagem() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imagem = await picker.pickImage(source: ImageSource.gallery);

    if (imagem != null) {
      setState(() {
        _imagemSelecionada = File(imagem.path);
      });
    }
  }

  void _mostrarPopupGenero() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Selecione o gênero', textAlign: TextAlign.center),
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
                    _buildDropdownCampo('Categoria de Peso', categoriaPesoSelecionada, categoriasPesoUFC),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
              onPressed: () {
                Navigator.pop(context);
              },
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
              onPressed: () {
                Navigator.pop(context, {
                  'nome': nomeController.text,
                  'dataNascimento': '$diaSelecionado de $mesSelecionado de $anoSelecionado',
                  'estado': estadoSelecionado,
                  'cidade': cidadeSelecionada,
                  'genero': generoController.text,
                  'altura': alturaController.text,
                  'peso': categoriaPesoSelecionada,
                  'imagem': _imagemSelecionada,
                });
              },
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
    bool isGenero = label == 'Gênero';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        GestureDetector(
          onTap: isGenero ? _mostrarPopupGenero : null,
          child: AbsorbPointer(
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
            Expanded(
              child: DropdownButtonFormField<int>(
                value: diaSelecionado,
                items: dias.map((dia) {
                  return DropdownMenuItem<int>(
                    value: dia,
                    child: Text(dia.toString(), style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    diaSelecionado = newValue!;
                  });
                },
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: mesSelecionado,
                items: meses.map((mes) {
                  return DropdownMenuItem<String>(
                    value: mes,
                    child: Text(mes, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    mesSelecionado = newValue!;
                  });
                },
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<int>(
                value: anoSelecionado,
                items: anos.map((ano) {
                  return DropdownMenuItem<int>(
                    value: ano,
                    child: Text(ano.toString(), style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    anoSelecionado = newValue!;
                  });
                },
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ),
            ),
          ],
        ),
        const Divider(thickness: 1, color: Colors.black),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildEstadoCidadeCampos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Estado e Cidade', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: estadoSelecionado,
                items: estados.map((uf) {
                  return DropdownMenuItem<String>(
                    value: uf,
                    child: Text('$uf - ${nomesEstados[uf] ?? uf}', style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    estadoSelecionado = newValue;
                    final cidades = cidadesPorEstado[newValue!] ?? [];
                    cidadeSelecionada = cidades.isNotEmpty ? cidades[0] : null;
                  });
                },
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: cidadeSelecionada,
                items: (cidadesPorEstado[estadoSelecionado] ?? []).map((cidade) {
                  return DropdownMenuItem<String>(
                    value: cidade,
                    child: Text(cidade, style: const TextStyle(fontSize: 16)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    cidadeSelecionada = newValue;
                  });
                },
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
              ),
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
          onChanged: (newValue) {
            setState(() {
              categoriaPesoSelecionada = newValue;
            });
          },
          decoration: const InputDecoration(border: InputBorder.none, isDense: true),
        ),
        const Divider(thickness: 1, color: Colors.black),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildAlterarArtesButton() {
    return Center(
      child: SizedBox(
        width: 200,
        height: 48,
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const EditarArtes()));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8D0000),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
            elevation: 4,
            shadowColor: Colors.black12,
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child: const Text(
            'Alterar artes marciais',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ),
    );
  }
}