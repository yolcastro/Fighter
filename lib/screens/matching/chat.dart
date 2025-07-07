import 'package:flutter/material.dart';
import 'historico_conversas.dart';
import 'perfil_adversario.dart';
import 'explorar.dart'; 
import 'package:http/http.dart' as http;
import 'dart:convert'; 
import 'dart:async';

// URL base da sua API. Certifique-se de que esta URL está correta e acessível.
const String BASE_URL = 'https://e9f6-187-18-138-85.ngrok-free.app';

class Mensagem {
  final String senderId; // ID do remetente
  final String receiverId; // ID do destinatário
  final String content; // Conteúdo da mensagem
  final DateTime timestamp; // Timestamp da mensagem, agora como DateTime

  Mensagem({
    required this.senderId,
    required this.receiverId,
    required this.content,
    required this.timestamp,
  });

  // Factory constructor para criar Mensagem a partir de JSON da API
  factory Mensagem.fromJson(Map<String, dynamic> json) {
    // Tenta parsear o timestamp. O backend retorna um ISO 8601 String.
    DateTime parsedTimestamp;
    try {
      parsedTimestamp = DateTime.parse(json['timestamp'] as String);
    } catch (e) {
      // Fallback para caso o timestamp não esteja no formato esperado
      print('Erro ao parsear timestamp da mensagem: $e. Usando DateTime.now().');
      parsedTimestamp = DateTime.now();
    }

    return Mensagem(
      senderId: json['senderId'] as String,
      receiverId: json['receiverId'] as String,
      content: json['content'] as String,
      timestamp: parsedTimestamp,
    );
  }

  // Método para converter Mensagem para JSON (útil para envio)
  Map<String, dynamic> toJson() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'timestamp': timestamp.toIso8601String(), // Converte DateTime para String ISO 8601
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
  Timer? _pollingTimer; // Timer para o polling de mensagens

  @override
  void initState() {
    super.initState();
    _fetchMessages(); // Inicia o carregamento das mensagens ao iniciar a tela
    _startPolling(); // Inicia o polling
  }

  // Inicia o timer para buscar mensagens periodicamente
  void _startPolling() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      // Busca mensagens apenas se a tela estiver ativa e não estiver carregando
      if (mounted && !_isLoading) {
        _fetchMessages(isPolling: true);
      }
    });
  }

  // Para a busca de mensagens periódica
  void _stopPolling() {
    _pollingTimer?.cancel();
  }

  Future<void> _fetchMessages({bool isPolling = false}) async {
    // Se não for um polling, mostra o indicador de carregamento
    if (!isPolling) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final response = await http.get(
        Uri.parse('$BASE_URL/api/chats/${widget.chatId}/messages'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> messagesJson = json.decode(response.body);
        final List<Mensagem> fetchedMessages = messagesJson
            .map((json) => Mensagem.fromJson(json as Map<String, dynamic>))
            .toList();

        // Verifica se há novas mensagens para adicionar
        bool newMessagesAdded = false;
        if (fetchedMessages.length > _mensagens.length) {
          // Adiciona apenas as mensagens que ainda não estão na lista
          _mensagens.addAll(fetchedMessages.sublist(_mensagens.length));
          newMessagesAdded = true;
        } else if (fetchedMessages.length < _mensagens.length) {
          // Se por algum motivo a lista do servidor for menor, recarrega tudo
          _mensagens = fetchedMessages;
          newMessagesAdded = true; // Considera como novas mensagens para rolar
        } else {
          // Se o número de mensagens for o mesmo, verifica se o conteúdo mudou
          // Isso é um fallback, idealmente o backend garantiria a ordem e não haveria necessidade
          // de verificar cada mensagem. Para um chat simples, comparar o último elemento pode ser suficiente.
          if (_mensagens.isNotEmpty && fetchedMessages.isNotEmpty &&
              (_mensagens.last.content != fetchedMessages.last.content ||
               _mensagens.last.timestamp != fetchedMessages.last.timestamp)) {
            _mensagens = fetchedMessages;
            newMessagesAdded = true;
          }
        }

        setState(() {
          _isLoading = false; // Finaliza o estado de carregamento
        });

        if (newMessagesAdded) {
          _scrollToBottom(); // Rola para o final apenas se novas mensagens foram adicionadas
        }
      } else {
        print('Falha ao carregar mensagens: ${response.statusCode} ${response.body}');
        if (!isPolling) { // Apenas mostra o SnackBar se não for um polling em segundo plano
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Erro ao carregar mensagens.')),
          );
        }
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar mensagens: $e');
      if (!isPolling) { // Apenas mostra o SnackBar se não for um polling em segundo plano
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro de conexão ao carregar mensagens.')),
        );
      }
      setState(() {
        _isLoading = false;
      });
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
      timestamp: DateTime.now(), // Usar DateTime.now()
    );

    // Adicionar a mensagem à lista local para exibição imediata
    setState(() {
      _mensagens.add(novaMensagem);
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse('$BASE_URL/api/chats/${widget.chatId}/messages/send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(novaMensagem.toJson()),
      );

      if (response.statusCode == 201) { // 201 CREATED é o esperado para o envio de mensagens
        print('Mensagem enviada com sucesso! ${response.body}');
        // O polling se encarregará de buscar a mensagem com o timestamp real do servidor
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
    _stopPolling(); // Importante: Cancelar o timer ao sair da tela
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        // Define uma altura ligeiramente maior para a AppBar
        preferredSize: const Size.fromHeight(kToolbarHeight + 10), // Ajuste a altura conforme necessário
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEFEFEF), // Fundo do appbar
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12), // Sombra mais sutil
                blurRadius: 6,
                offset: const Offset(0, 3), // Deslocamento da sombra
              ),
            ],
          ),
          child: SafeArea( // Garante que o conteúdo não invada a área da notch/status bar
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0), // Ajuste o padding horizontal
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribui o espaço entre os elementos
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    splashRadius: 24,
                  ),
                  Expanded( // Ocupa o espaço restante no centro
                    child: GestureDetector(
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
                        mainAxisAlignment: MainAxisAlignment.center, // Centraliza verticalmente na AppBar
                        mainAxisSize: MainAxisSize.min, // Ocupa o mínimo de altura
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
                            overflow: TextOverflow.ellipsis, // Trunca o texto se for muito longo
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Se você quiser um ícone ou widget à direita, adicione aqui.
                  // Caso contrário, um SizedBox vazio ou Container pode ser usado para balancear.
                  const SizedBox(width: 48), // Espaço para balancear com o ícone de voltar à esquerda
                ],
              ),
            ),
          ),
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
                              // Cor das mensagens enviadas como #f3d1d1
                              color: isMyMessage ? const Color(0xFFF3D1D1) : const Color(0xFFEFEFEF),
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMyMessage ? 16 : 4),
                                bottomRight: Radius.circular(isMyMessage ? 4 : 16),
                              ),
                            ),
                            child: Text(
                              mensagem.content,
                              style: TextStyle(
                                color: isMyMessage ? Colors.black87 : Colors.black87, // Cor do texto ajustada para legibilidade
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
