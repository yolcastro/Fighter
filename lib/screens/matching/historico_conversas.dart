import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importe para obter o UID do usuário logado
import 'package:http/http.dart' as http; // Importe para fazer requisições HTTP
import 'dart:convert'; // Importe para trabalhar com JSON
import 'chat.dart'; // Importe a tela de chat
import 'explorar.dart'; // Importe para usar a classe Pessoa

// URL base da sua API. Certifique-se de que esta URL está correta e acessível.
const String BASE_URL = 'https://e9f6-187-18-138-85.ngrok-free.app';

// Modelo para o objeto Chat retornado pela API (GET /api/chats/user/{userId})
class ChatBackend {
  final String chatId; // Corresponde ao 'id' no Java Chat POJO
  final String user1Id;
  final String user2Id;
  final String lastMessage; // Adicionado do POJO
  final String lastMessageSenderId; // Adicionado do POJO
  final DateTime? lastMessageAt; // Adicionado do POJO, pode ser nulo

  ChatBackend({
    required this.chatId,
    required this.user1Id,
    required this.user2Id,
    required this.lastMessage,
    required this.lastMessageSenderId,
    this.lastMessageAt,
  });

  factory ChatBackend.fromJson(Map<String, dynamic> json) {
    // Lida com a conversão de lastMessageAt, que pode ser um timestamp ou uma string ISO
    DateTime? parsedLastMessageAt;
    if (json['lastMessageAt'] != null) {
      if (json['lastMessageAt'] is int) {
        parsedLastMessageAt = DateTime.fromMillisecondsSinceEpoch(json['lastMessageAt']);
      } else if (json['lastMessageAt'] is String) {
        try {
          parsedLastMessageAt = DateTime.parse(json['lastMessageAt']);
        } catch (e) {
          print('Erro ao parsear lastMessageAt como String: $e');
        }
      }
    }

    return ChatBackend(
      chatId: json['id']?.toString() ?? '', // CORREÇÃO: Usar 'id' do POJO
      user1Id: json['user1Id']?.toString() ?? '',
      user2Id: json['user2Id']?.toString() ?? '',
      lastMessage: json['lastMessage']?.toString() ?? '', // Mapeia lastMessage
      lastMessageSenderId: json['lastMessageSenderId']?.toString() ?? '', // Mapeia lastMessageSenderId
      lastMessageAt: parsedLastMessageAt, // Usa o DateTime parseado
    );
  }
}

// Modelo de dados para exibir um item de chat na lista da UI
// Combina o ID do chat com o objeto Pessoa do outro usuário e a última mensagem
class ChatDisplayItem {
  final String chatId;
  final String otherUserId;
  final Pessoa otherUser; // O objeto Pessoa completo do outro usuário no chat
  final String lastMessage; // Última mensagem para exibição
  final DateTime? lastMessageAt; // Timestamp da última mensagem

  ChatDisplayItem({
    required this.chatId,
    required this.otherUserId,
    required this.otherUser,
    required this.lastMessage,
    this.lastMessageAt,
  });
}

class TelaHistoricoChats extends StatefulWidget {
  const TelaHistoricoChats({super.key});

  @override
  State<TelaHistoricoChats> createState() => _TelaHistoricoChatsState();
}

class _TelaHistoricoChatsState extends State<TelaHistoricoChats> {
  String? _currentUserId; // ID do usuário logado
  List<ChatDisplayItem> _chats = []; // Lista de chats a serem exibidos
  bool _isLoading = true; // Estado de carregamento
  String? _errorMessage; // Mensagem de erro, se houver

  @override
  void initState() {
    super.initState();
    _loadUserDataAndChats(); // Inicia o carregamento dos dados ao criar a tela
  }

  // Função para carregar o ID do usuário logado e, em seguida, os chats
  Future<void> _loadUserDataAndChats() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Usuário não logado. Por favor, faça login.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _currentUserId = user.uid;
    });

    await _fetchChats(); // Chama a função para buscar os chats
  }

  // Função para buscar os chats do usuário logado na API
  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true; // Ativa o estado de carregamento
      _errorMessage = null; // Limpa qualquer mensagem de erro anterior
    });

    if (_currentUserId == null) {
      setState(() {
        _errorMessage = 'ID do usuário não disponível.';
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(Uri.parse('$BASE_URL/api/chats/user/$_currentUserId'));

      if (response.statusCode == 200) {
        List<dynamic> chatsJson = json.decode(utf8.decode(response.bodyBytes));
        List<ChatBackend> fetchedChats = chatsJson.map((json) => ChatBackend.fromJson(json as Map<String, dynamic>)).toList();

        List<ChatDisplayItem> displayItems = [];
        for (var chatBackend in fetchedChats) {
          // Determina o ID do outro usuário no chat
          String otherUserId = chatBackend.user1Id == _currentUserId ? chatBackend.user2Id : chatBackend.user1Id;

          // Busca os detalhes do perfil do outro usuário usando o endpoint /api/usuarios/{id}
          Pessoa? otherUser = await _fetchPessoaDetails(otherUserId);

          if (otherUser != null) {
            displayItems.add(ChatDisplayItem(
              chatId: chatBackend.chatId,
              otherUserId: otherUserId,
              otherUser: otherUser,
              lastMessage: chatBackend.lastMessage, // Passa a última mensagem
              lastMessageAt: chatBackend.lastMessageAt, // Passa o timestamp
            ));
          } else {
            print('Aviso: Não foi possível carregar o perfil do usuário $otherUserId para o chat ${chatBackend.chatId}');
          }
        }

        setState(() {
          _chats = displayItems;
          _isLoading = false; // Desativa o estado de carregamento
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar chats: ${response.statusCode} - ${response.body}';
          _isLoading = false;
        });
        print('Erro API chats: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erro de conexão ao carregar chats: $e';
        _isLoading = false;
      });
      print('Erro de exceção ao carregar chats: $e');
    }
  }

  // Função auxiliar para buscar os detalhes de um usuário específico
  Future<Pessoa?> _fetchPessoaDetails(String userId) async {
    try {
      final response = await http.get(Uri.parse('$BASE_URL/api/usuarios/$userId'));
      if (response.statusCode == 200) {
        return Pessoa.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        print('Falha ao carregar perfil do usuário $userId: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Erro ao buscar perfil do usuário $userId: $e');
      return null;
    }
  }

  // Função auxiliar para obter ImageProvider (reutilizada de chat.dart ou explorador.dart)
  ImageProvider _getImageProvider(String fotoUrl) {
    if (fotoUrl.startsWith('assets/')) {
      return AssetImage(fotoUrl);
    } else if (fotoUrl.startsWith('http://') || fotoUrl.startsWith('https://')) {
      return NetworkImage(fotoUrl);
    } else {
      // Placeholder para URLs inválidas ou vazias
      return const AssetImage('assets/placeholder_profile.png'); // Certifique-se de ter esta imagem
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Cabeçalho da tela (AppBar customizada)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFEF), // Fundo do appbar
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
                        // Ao voltar, substitui a rota para ir para a TelaExplorar
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

            // Corpo da tela (lista de chats ou mensagens de status)
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF8B2E2E), // Cor do indicador de carregamento
                      ),
                    )
                  : _errorMessage != null // Exibe mensagem de erro se houver
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                                const SizedBox(height: 16),
                                Text(
                                  'Erro ao carregar chats: $_errorMessage',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.black54, fontSize: 16),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: _fetchChats, // Tentar recarregar
                                  icon: const Icon(Icons.refresh, color: Colors.white),
                                  label: const Text('Tentar Novamente', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF8B2E2E),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : _chats.isEmpty // Exibe mensagem se não houver chats
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(24.0),
                                child: Text(
                                  'Nenhum chat encontrado. Comece a explorar para encontrar parceiros de treino!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black54, fontSize: 16),
                                ),
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              itemCount: _chats.length,
                              separatorBuilder: (_, __) => const Divider(
                                indent: 80,
                                endIndent: 24,
                                thickness: 0.5,
                                color: Colors.black12,
                              ),
                              itemBuilder: (context, index) {
                                final chatItem = _chats[index];
                                return ListTile(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                  leading: CircleAvatar(
                                    // Usa a foto do outro usuário obtida do objeto Pessoa
                                    backgroundImage: _getImageProvider(chatItem.otherUser.foto),
                                    radius: 26,
                                    backgroundColor: Colors.transparent,
                                  ),
                                  title: Text(
                                    chatItem.otherUser.nome, // Nome do outro usuário
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  // Exibe a última mensagem do chat
                                  subtitle: Text(
                                    chatItem.lastMessage.isNotEmpty
                                        ? chatItem.lastMessage
                                        : 'Nenhuma mensagem.',
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
                                    // Navega para a TelaChat, passando todos os dados necessários
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TelaChat(
                                          chatId: chatItem.chatId,
                                          currentUserId: _currentUserId!, // ID do usuário logado
                                          otherUserId: chatItem.otherUserId, // ID do outro usuário
                                          otherUserNome: chatItem.otherUser.nome, // Nome do outro usuário
                                          otherUserFoto: chatItem.otherUser.foto, // Foto do outro usuário
                                          otherUser: chatItem.otherUser, // Objeto Pessoa completo do outro usuário
                                        ),
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
