import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TelaFotoDescricao extends StatefulWidget {
  const TelaFotoDescricao({super.key});

  @override
  State<TelaFotoDescricao> createState() => _TelaFotoDescricaoState();
}

class _TelaFotoDescricaoState extends State<TelaFotoDescricao> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _descricaoController = TextEditingController();
  File? _imagemSelecionada;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                    onPressed: () {
                      if (_descricaoController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Escreva uma descrição'),
                          ),
                        );
                        return;
                      }
                      Navigator.pushNamed(context, '/boasvindas');
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
                        fontSize: 18,
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
    );
  }
}
