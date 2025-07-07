import 'package:flutter/material.dart';
import 'historico_conversas.dart';
import 'perfil_adversario.dart';
import 'explorar.dart'; // Certifique-se de que a classe Pessoa está definida aqui e importada
import 'package:http/http.dart' as http; // Importar pacote HTTP
import 'dart:convert'; // Importar para trabalhar com JSON

class Mensagem {
  final String senderId; // ID do remetente
  final String receiverId; // ID do destinatário (opcional para exibição, mas útil para o envio)
  final String content; // Conteúdo da mensagem
  final String timestamp; // Timestamp da mensagem

  Mensagem({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor para criar Mensagem a partir de JSON da API
  // A propriedade 'meu' é calculada aqui para simplificar a lógica na UI
  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      timestamp: json['timestamp'] as String,
    );
  }

  // Método para converter Mensagem para JSON (útil para envio)
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp, // Timestamp pode ser gerado no backend, mas incluo por completude
    };
  }
}

class TelaChat extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserNome;
  final String otherUserFoto;
  final Pessoa otherUser;

  const TelaChat({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserNome,
    required this.otherUserFoto,
    required this.otherUser,
  });

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  List<Mensagem> _mensagens = []; // Lista de mensagens vazia inicialmente
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true; // Estado para controlar o carregamento

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Inicia o carregamento das mensagens ao iniciar a tela
  }

  Future<void> _fetchMessages() async {
    setState(() {
      _isLoading = true; // Inicia o estado de carregamento
    });
    try {
      final response = await http.get(
        Uri.parse('https://e9f6-187-18-138-85.ngrok-free.app/api/chats/${widget.chatId}/messages'),
        // Certifique-se de que a URL base e a porta estão corretas
        // Se sua API estiver em outro local, ajuste 'localhost:8080'
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        setState(() {
          _mensagens = messagesJson
              .map((json) => Mensagem.fromJson(json))
              .toList();
          _isLoading = false; // Finaliza o estado de carregamento
        });
        _scrollToBottom(); // Rola para o final após carregar as mensagens
      } else {
        print('Falha ao carregar mensagens: ${response.statusCode} ${response.body}');
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao carregar mensagens.')),
        );
      }
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão ao carregar mensagens.')),
      );
    }
  }

  void _enviarMensagem() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    // Criar o objeto Mensagem para enviar à API
    final Mensagem novaMensagem = Mensagem(
      senderId: widget.currentUserId,
      receiverId: widget.otherUserId,
      content: texto,
      timestamp: DateTime.now().toIso8601String(), // Timestamp local, pode ser sobrescrito pelo backend
    );

    // Adicionar a mensagem à lista local para exibição imediata
    setState(() {
      _mensagens.add(novaMensagem);
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await http.post(
       Uri.parse('https://e9f6-187-18-138-85.ngrok-free.app/api/chats/${widget.chatId}/messages/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(novaMensagem.toJson()),
      );

      if (response.statusCode == 201) { // 201 CREATED é o esperado para o envio de mensagens
        print('Mensagem enviada com sucesso! ${response.body}');
        // Se desejar, você pode refetch as mensagens para obter o timestamp exato do servidor,
        // ou atualizar apenas o timestamp da mensagem localmente.
        // Por simplicidade, mantemos a adição local imediata.
      } else {
        print('Falha ao enviar mensagem: ${response.statusCode} ${response.body}');
        // Remover a mensagem que foi adicionada localmente se o envio falhar
        setState(() {
          _mensagens.removeLast();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao enviar mensagem.')),
        );
      }
    } catch (e) {
      print('Erro de conexão ao enviar mensagem: $e');
      // Remover a mensagem que foi adicionada localmente se houver erro de conexão
      setState(() {
        _mensagens.removeLast();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro de conexão ao enviar mensagem.')),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PerfilAdversarioPage(
                  adversario: widget.otherUser,
                ),
              ),
            );
          },
          child: Column(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: widget.otherUserFoto.startsWith('http')
                    ? NetworkImage(widget.otherUserFoto) as ImageProvider
                    : AssetImage(widget.otherUserFoto),
              ),
              const SizedBox(height: 4),
              Text(
                widget.otherUserNome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B2E2E),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      itemCount: _mensagens.length,
                      itemBuilder: (context, index) {
                        final mensagem = _mensagens[index];
                        // Determinar se a mensagem é do usuário logado ou do adversário
                        final bool isMyMessage = mensagem.senderId == widget.currentUserId;

                        return Align(
                          alignment: isMyMessage ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMyMessage ? const Color(0xFF8B2E2E) : const Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMyMessage ? 16 : 4),
                                bottomRight: Radius.circular(isMyMessage ? 4 : 16),
                              ),
                            ),
                            child: Text(
                              mensagem.content, // Usar 'content' em vez de 'texto'
                              style: TextStyle(
                                color: isMyMessage ? Colors.white : Colors.black87,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
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
          ],
        ),
      ),
    );
  }
}