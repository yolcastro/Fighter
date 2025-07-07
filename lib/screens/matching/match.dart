import 'dart:io';
import 'package:flutter/material.dart';
import 'explorar.dart'; // Certifique-se de que este import está correto
import 'chat.dart'; // Importe a tela de chat


class TelaMatch extends StatelessWidget {
  final String chatId;
  final String currentUserId;

  // NOVO: Adiciona o objeto Pessoa completo para ambos os usuários
  final Pessoa currentUser; // O usuário logado
  final Pessoa otherUser;  // O usuário com quem deu match

  const TelaMatch({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.currentUser, // REQUERIDO
    required this.otherUser,   // REQUERIDO
    // REMOVA as requisições de nome e foto individuais aqui
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final avatarSize = size.width * 0.3;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: size.width * 0.08,
            vertical: size.height * 0.06,
          ),
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment(0, -0.5),
              radius: 1.2,
              colors: [Color(0xFFF5DCDC), Colors.white],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTitle(size),
              SizedBox(height: size.height * 0.04),
              _buildAvatarsRow(size, avatarSize),
              SizedBox(height: size.height * 0.04),
              _buildSubtitle(size),
              SizedBox(height: size.height * 0.06),
              _buildPrimaryButton(size, context), // Passa o contexto aqui
              SizedBox(height: size.height * 0.03),
              _buildSecondaryButton(size, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(Size size) {
    return Text(
      'PARCERIA\nFORMADA',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size.width * 0.085,
        fontWeight: FontWeight.w900,
        color: const Color(0xFF7A1F1F),
        height: 1.3,
        letterSpacing: 1.2,
      ),
    );
  }

   Widget _buildAvatarsRow(Size size, double avatarSize) {
    return SizedBox(
      height: avatarSize + 30,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: size.width * 0.18,
            child: _fotoCircular(currentUser.foto, avatarSize), // Usar currentUser.foto
          ),
          Positioned(
            right: size.width * 0.18,
            child: _fotoCircular(otherUser.foto, avatarSize),   // Usar otherUser.foto
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle(Size size) {
    return Text(
      'Match na medida. Manda um\nsalve e bora treinar juntos!',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: size.width * 0.048,
        color: Colors.black87,
        height: 1.5,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildPrimaryButton(Size size, BuildContext context) {
    return SizedBox(
      width: size.width * 0.75,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaChat(
                chatId: chatId,
                currentUserId: currentUserId,
                otherUserId: otherUser.id, // Acessa o ID do objeto Pessoa
                otherUserNome: otherUser.nome, // Acessa o nome do objeto Pessoa
                otherUserFoto: otherUser.foto, // Acessa a foto do objeto Pessoa
                otherUser: otherUser, // PASSA O OBJETO PESSOA COMPLETO
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B2E2E),
          padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          shadowColor: Colors.black45,
          elevation: 6,
        ),
        child: const Text(
          'Enviar mensagem',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(Size size, BuildContext context) {
    return SizedBox(
      width: size.width * 0.75,
      child: OutlinedButton(
        onPressed: () {
          // Usa Navigator.pop para fechar a TelaMatch e retornar à tela anterior (TelaExplorar)
          // Isso fará com que o `await Navigator.push` em _like() seja concluído
          Navigator.pop(context);
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF8B2E2E)),
          padding: EdgeInsets.symmetric(vertical: size.height * 0.03),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          foregroundColor: const Color(0xFF8B2E2E),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        child: const Text('Continuar explorando'),
      ),
    );
  }

  Widget _fotoCircular(String foto, double size) {
    ImageProvider imageProvider;
    // Verifica se a string da foto é um caminho de asset local
    if (foto.startsWith('assets/')) {
      imageProvider = AssetImage(foto);
    }
    // Verifica se a string da foto é um caminho de arquivo local (ex: de image_picker)
    else if (foto.startsWith('/data/') || foto.startsWith('file://')) { // Adicionado 'file://' para robustez
      imageProvider = FileImage(File(foto.replaceFirst('file://', ''))); // Remove 'file://' se presente
    }
    // Assume que é uma URL de rede
    else {
      imageProvider = NetworkImage(foto);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
        ],
      ),
    );
  }
}