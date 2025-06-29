import 'package:flutter/material.dart';
import 'explorar.dart';

class Mensagem {
  final String texto;
  final bool meu;

  Mensagem(this.texto, this.meu);
}

class TelaChat extends StatefulWidget {
  const TelaChat({super.key});

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final List<Mensagem> mensagens = [
    Mensagem('Vi que você também treina Capoeira. Qual sua música favorita?', false),
    Mensagem('Adoro a batida do São Bento Grande! E você?', true),
    Mensagem('Também curto bastante.\nVamos marcar uma roda para treinar juntos? 😊', false),
  ];

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _enviarMensagem() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      mensagens.add(Mensagem(texto, true));
      _controller.clear();
    });

    _scrollToBottom();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        mensagens.add(Mensagem('Legal! 😊', false));
      });
      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<bool> _onWillPop() async {
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const TelaExplorar()),
    );
    return false;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const String fotoMarina = 'assets/marina.jpg';
    const String fotoUsuario = 'assets/usuario.jpg';

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(fotoMarina),
              ),
              const SizedBox(width: 8),
              const Text(
                'Marina',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: mensagens.length,
                itemBuilder: (context, index) {
                  final msg = mensagens[index];
                  final bool meu = msg.meu;
                  return Align(
                    alignment: meu ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment:
                          meu ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!meu) ...[
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: AssetImage(fotoMarina),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: meu ? const Color(0xFFFADADA) : const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft:
                                    meu ? const Radius.circular(20) : const Radius.circular(4),
                                bottomRight:
                                    meu ? const Radius.circular(4) : const Radius.circular(20),
                              ),
                            ),
                            child: Text(
                              msg.texto,
                              style: const TextStyle(fontSize: 15, color: Colors.black87),
                            ),
                          ),
                        ),
                        if (meu) ...[
                          const SizedBox(width: 6),
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: AssetImage(fotoUsuario),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Digite sua mensagem',
                          border: InputBorder.none,
                        ),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _enviarMensagem,
                    child: const Icon(Icons.send, color: Color(0xFF8B2E2E)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
