import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fighter_app/usuario.service.dart'; // ajuste o import conforme sua estrutura

class TelaFotoDescricao extends StatefulWidget {
  const TelaFotoDescricao({super.key});

  @override
  State<TelaFotoDescricao> createState() => _TelaFotoDescricaoState();
}

class _TelaFotoDescricaoState extends State<TelaFotoDescricao> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descricaoController = TextEditingController();
  File? _imagemSelecionada;

  // Variável para armazenar os filtros recebidos
  Map<String, dynamic>? _filtrosRecebidos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Captura os argumentos passados pela rota
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is Map<String, dynamic>) {
      _filtrosRecebidos = args;
    }
  }

  Future<void> _escolherImagem() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imagemSelecionada = File(picked.path));
    }
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    super.dispose();
  }

  void _salvarEDefinirProximo() {
    if (_descricaoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Escreva uma descrição')),
      );
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário logado. Faça login novamente.')),
      );
      return;
    }

    final Map<String, dynamic> updateData = {
      'descricao': _descricaoController.text.trim(),
      'fotoPerfilUrl': _imagemSelecionada?.path ?? '', // Idealmente, você faria o upload da imagem e armazenaria a URL aqui
    };

    UsuarioService.atualizarUsuario(currentUser.uid, updateData).then((success) {
      if (success) {
        print('Descrição e foto salvos com sucesso para ${currentUser.uid}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        // Passa os filtros (incluindo os da tela anterior) para a próxima tela
        Navigator.pushNamed(context, '/boasvindas', arguments: _filtrosRecebidos);
      } else {
        print('Erro ao salvar descrição e foto para ${currentUser.uid}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar perfil.')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
                    splashRadius: 24,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 40),
                  const Center(
                    child: Text(
                      'Mostre quem você é, no ringue ou fora dele.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000000),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Center(
                    child: Text(
                      'Adicione uma foto e escreva algo sobre você pra atrair pessoas que combinem com seu estilo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.4,
                        color: Color(0xFF343434),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        GestureDetector(
                          onTap: _escolherImagem,
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: const Color(0xFFDADADA),
                            backgroundImage: _imagemSelecionada != null
                                ? FileImage(_imagemSelecionada!)
                                : const AssetImage('assets/pfp.jpg') as ImageProvider,
                            child: _imagemSelecionada == null
                                ? const Icon(Icons.camera_alt, size: 32, color: Colors.white70)
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _escolherImagem,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFF8D0000),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _descricaoController,
                    maxLines: 5,
                    maxLength: 250,
                    style: const TextStyle(fontSize: 16, color: Color(0xFF000000)),
                    decoration: InputDecoration(
                      hintText: 'Descreva seu ritmo, estilo de treino ou o que procura por aqui.',
                      hintStyle: const TextStyle(color: Color(0xFF555555), fontSize: 16),
                      filled: true,
                      fillColor: const Color(0xFFDADADA),
                      counterText: '',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _salvarEDefinirProximo,
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
                            letterSpacing: 1.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}