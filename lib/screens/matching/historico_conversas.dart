import 'package:flutter/material.dart';
import 'chat.dart';
import 'explorar.dart';

class ChatItem {
  final String nome;
  final String foto;
  final String ultimaMensagem;

  ChatItem({
    required this.nome,
    required this.foto,
    required this.ultimaMensagem,
  });
}

class TelaHistoricoChats extends StatelessWidget {
  const TelaHistoricoChats({super.key});

  @override
  Widget build(BuildContext context) {
    final List<ChatItem> chats = [
      ChatItem(
        nome: 'Marina',
        foto: 'assets/marina.jpg',
        ultimaMensagem: 'Vamos marcar uma roda para treinar juntos? 😊',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFEF), // fundo do appbar efefef
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
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
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const TelaExplorar()),
                        );
                      },
                      splashRadius: 24,
                    ),
                  ),
                  const Text(
                    'Histórico de Conversas',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 20),
                itemCount: chats.length,
                separatorBuilder: (_, __) => const Divider(
                  indent: 80,
                  endIndent: 24,
                  thickness: 0.5,
                  color: Colors.black12,
                ),
                itemBuilder: (context, index) {
                  final chat = chats[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(chat.foto),
                      radius: 26,
                      backgroundColor: Colors.transparent,
                    ),
                    title: Text(
                      chat.nome,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      chat.ultimaMensagem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, color: Color(0xFF8D0000)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const TelaChat(),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
