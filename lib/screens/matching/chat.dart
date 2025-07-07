import 'package:flutter/material.dart';
import 'historico_conversas.dart';
import 'perfil_adversario.dart';

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
        mensagens.add(Mensagem('Show!', false));
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
      MaterialPageRoute(builder: (context) => const TelaHistoricoChats()),
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFFEFEFEF),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const TelaHistoricoChats()),
                        );
                      },
                      splashRadius: 24,
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PerfilAdversarioPage()),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundImage: AssetImage(fotoMarina),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Marina',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: mensagens.length,
                itemBuilder: (context, index) {
                  final msg = mensagens[index];
                  final bool meu = msg.meu;
                  return Align(
                    alignment: meu ? Alignment.centerRight : Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: meu ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!meu) ...[
                          CircleAvatar(
                            radius: 14,
                            backgroundImage: AssetImage(fotoMarina),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Flexible(
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                            decoration: BoxDecoration(
                              color: meu ? const Color(0xFFFADADA) : const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(20),
                                topRight: const Radius.circular(20),
                                bottomLeft: meu ? const Radius.circular(20) : const Radius.circular(4),
                                bottomRight: meu ? const Radius.circular(4) : const Radius.circular(20),
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 3,
                                  offset: Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              msg.texto,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),
                        if (meu) ...[
                          const SizedBox(width: 8),
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
            SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: const BoxDecoration(
                  color: Color(0xFFEFEFEF), // fundo da barra de digitar EFEFEF
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black12),
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.white, // campo de digitação branco
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: _controller,
                          decoration: const InputDecoration(
                            hintText: 'Digite sua mensagem',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.black38),
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 16),
                          ),
                          minLines: 1,
                          maxLines: 4,
                          textInputAction: TextInputAction.send,
                          onSubmitted: (_) => _enviarMensagem(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(30),
                        onTap: _enviarMensagem,
                        child: const Padding(
                          padding: EdgeInsets.all(10),
                          child: Icon(Icons.send, color: Color(0xFF8B2E2E), size: 28),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
