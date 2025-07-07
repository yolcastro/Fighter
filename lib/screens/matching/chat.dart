// chat.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importe http para requisições HTTP
import 'dart:convert'; // Importe dart:convert para manipulação JSON
import 'package:firebase_auth/firebase_auth.dart'; // Importe para obter o ID do usuário atual
import 'historico_conversas.dart'; // Mantido caso seja usado na navegação de voltar
import 'perfil_adversario.dart'; // Mantido caso seja usado para exibir o perfil do adversário

// Classe Mensagem atualizada para corresponder à estrutura da API
class Mensagem {
  final String id; // ID da mensagem (opcional, mas bom para unicidade)
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime timestamp;

  Mensagem({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  factory Mensagem.fromJson(Map<String, dynamic> json) {
    return Mensagem(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      // Assumindo que timestamp é uma string ISO 8601 que DateTime.parse pode converter
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}

class TelaChat extends StatefulWidget {
  final String chatId;
  final String currentUserId;
  final String otherUserId;
  final String otherUserNome;
  final String otherUserFoto;

  const TelaChat({
    super.key,
    required this.chatId,
    required this.currentUserId,
    required this.otherUserId,
    required this.otherUserNome,
    required this.otherUserFoto,
  });

  @override
  State<TelaChat> createState() => _TelaChatState();
}

class _TelaChatState extends State<TelaChat> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<Mensagem> _messages = [];
  bool _isLoadingChat = true;

  // URL base para o seu backend. Use a mesma URL de explorar.dart
  final String _baseUrl = 'https://e9f6-187-18-138-85.ngrok-free.app'; 

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Busca as mensagens ao iniciar a tela
  }

  // Método para buscar mensagens do chat via API
  Future<void> _fetchMessages() async {
    setState(() {
      _isLoadingChat = true;
    });

    final String apiUrl = '$_baseUrl/api/chats/${widget.chatId}/messages';
    print('Buscando mensagens de: $apiUrl');

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _messages = data.map((json) => Mensagem.fromJson(json)).toList();
          _isLoadingChat = false;
        });
        _scrollToBottom();
        print('Mensagens buscadas com sucesso: ${_messages.length}');
      } else {
        print('Falha ao carregar mensagens: ${response.statusCode} - ${response.body}');
        setState(() {
          _isLoadingChat = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar mensagens: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Erro ao buscar mensagens: $e');
      setState(() {
        _isLoadingChat = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão ao carregar mensagens.')),
      );
    }
  }

  // Método para enviar mensagem via API
  void _enviarMensagem() async {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;

    // Adiciona a mensagem à UI imediatamente para uma melhor experiência do usuário
    // Ela será atualizada com o ID e timestamp reais da API
    setState(() {
      _messages.add(Mensagem(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // ID temporário
        senderId: widget.currentUserId,
        receiverId: widget.otherUserId,
        content: texto,
        timestamp: DateTime.now(),
      ));
      _controller.clear();
    });
    _scrollToBottom();

    final String apiUrl = '$_baseUrl/api/chats/${widget.chatId}/send';
    print('Enviando mensagem para: $apiUrl com conteúdo: $texto');

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'senderId': widget.currentUserId,
          'receiverId': widget.otherUserId,
          'content': texto,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newMessageJson = json.decode(response.body);
        final sentMessage = Mensagem.fromJson(newMessageJson);
        setState(() {
          // Substitui a mensagem temporária pela mensagem real da API
          _messages[_messages.indexWhere((msg) => msg.id == _messages.last.id)] = sentMessage;
        });
        _scrollToBottom();
        print('Mensagem enviada com sucesso!');
      } else {
        print('Falha ao enviar mensagem: ${response.statusCode} - ${response.body}');
        // Se o envio falhar, remova a mensagem da UI ou marque-a como falha.
        setState(() {
          _messages.removeWhere((msg) => msg.id == _messages.last.id); // Remove a mensagem temporária
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar mensagem: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print('Erro ao enviar mensagem: $e');
      setState(() {
        _messages.removeWhere((msg) => msg.id == _messages.last.id); // Remove a mensagem temporária
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão ao enviar mensagem.')),
      );
    }
  }

  // Permanece igual
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

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: const Color(0xFFF5F5F5),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
                    onPressed: () {
                      Navigator.pop(context); // Volta para a tela anterior (TelaMatch ou Histórico de Chats)
                    },
                    splashRadius: 24,
                  ),
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(widget.otherUserFoto), // Foto do outro usuário
                    backgroundColor: Colors.grey[200],
                  ),
                  const SizedBox(width: 12),
                  Text(
                    widget.otherUserNome, // Nome do outro usuário
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF424242),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.videocam_outlined, color: Color(0xFF8D0000)),
                    onPressed: () {
                      // Implementar funcionalidade de chamada de vídeo
                    },
                    splashRadius: 24,
                  ),
                  IconButton(
                    icon: const Icon(Icons.info_outline, color: Color(0xFF8D0000)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PerfilAdversarioPage()),
                      );
                    },
                    splashRadius: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoadingChat
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF8B2E2E)))
                : (_messages.isEmpty
                    ? const Center(child: Text('Comece a conversar!'))
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(12),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          // Verifica se a mensagem foi enviada pelo usuário atual
                          final isMe = message.senderId == widget.currentUserId;
                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: isMe ? const Color(0xFFDCF8C6) : const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                message.content,
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                              ),
                            ),
                          );
                        },
                      )),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  // Permanece igual
  Widget _buildMessageComposer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade300),
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
    );
  }
}

// Classe _fotoCircular reutilizada de TelaMatch (pode ser um arquivo de utilidade)
class _fotoCircular extends StatelessWidget {
  final String foto;
  final double size;

  const _fotoCircular(this.foto, this.size);

  @override
  Widget build(BuildContext context) {
    ImageProvider imageProvider;
    if (foto.startsWith('assets/')) {
      imageProvider = AssetImage(foto);
    } else if (foto.startsWith('/data/') || foto.startsWith('file://')) {
      imageProvider = FileImage(File(foto.replaceFirst('file://', '')));
    } else {
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