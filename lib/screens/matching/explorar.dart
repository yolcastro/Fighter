import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'match.dart';
import '../auth/login.dart';
import 'historico_conversas.dart';
import 'perfil_usuario.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class Pessoa {
  final String id;
  final String nome;
  final int idade;
  final String foto;
  final String local;
  final String genero;
  final int altura;
  final int peso;
  final String descricao;
  final List<String> modalidades;
  final String dataNascimento;

  Pessoa({
    required this.id,
    required this.nome,
    required this.idade,
    required this.foto,
    required this.local,
    required this.genero,
    required this.altura,
    required this.peso,
    required this.descricao,
    required this.modalidades,
    required this.dataNascimento,
  });

  factory Pessoa.fromJson(Map<String, dynamic> json) {
    const String defaultPlaceholderImage = 'https://e-quester.com/placeholder-image-person-jpg/';

    int calculatedAge = 0;
    String rawDataNascimento = json['dataNascimento'] ?? '';

    if (rawDataNascimento.isNotEmpty) {
      try {
        DateTime birthDate = DateFormat('dd/MM/yyyy').parse(rawDataNascimento);
        DateTime today = DateTime.now();
        calculatedAge = today.year - birthDate.year;
        if (today.month < birthDate.month ||
            (today.month == birthDate.month && today.day < birthDate.day)) {
          calculatedAge--;
        }
        if (calculatedAge < 0) {
          calculatedAge = 0;
        }
      } catch (e) {
        print('Erro ao parsear data de nascimento "$rawDataNascimento" com formato dd/MM/AAAA: $e');
      }
    }

    return Pessoa(
      id: json['id'] ?? '',
      nome: json['nome'] ?? 'Nome Desconhecido',
      idade: calculatedAge,
      foto: (json['fotoPerfilUrl'] != null && json['fotoPerfilUrl'].toString().isNotEmpty)
          ? json['fotoPerfilUrl']
          : defaultPlaceholderImage,
      local: json['localizacao'] ?? 'Local Desconhecido',
      genero: json['sexo'] ?? 'Não informado',
      altura: json['alturaEmCm'] ?? 0,
      peso: json['peso'] ?? 0,
      descricao: json['descricao'] ?? 'Sem descrição.',
      modalidades: List<String>.from(json['arteMarcial'] ?? []),
      dataNascimento: rawDataNascimento,
    );
  }
}

class TelaExplorar extends StatefulWidget {
  final Map<String, dynamic> filtros;

  const TelaExplorar({super.key, this.filtros = const {}});

  @override
  State<TelaExplorar> createState() => _TelaExplorarState();
}

class _TelaExplorarState extends State<TelaExplorar> {
  List<Pessoa> pessoas = [];
  int currentIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPessoas();
  }

  // Método para buscar pessoas, agora com filtro de likes
  Future<void> _fetchPessoas() async {
    setState(() {
      _isLoading = true;
    });

    final User? currentUser = FirebaseAuth.instance.currentUser;
    final String? currentUid = currentUser?.uid;

    if (currentUid == null) {
      print('Usuário não logado. Redirecionando para login.');
      // Opcional: redirecionar para a tela de login se o UID for nulo
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const TelaLogin()), (route) => false);
      return;
    }

    // 1. Obter lista de usuários que o 'currentUid' já deu like
    List<String> likedUserIds = [];
    try {
      final likedUsersResponse = await http.get(
        Uri.parse('https://e9f6-187-18-138-85.ngrok-free.app/api/likes/sent/$currentUid'),
      );

      if (likedUsersResponse.statusCode == 200) {
        likedUserIds = List<String>.from(json.decode(likedUsersResponse.body));
        print('Usuários já curtidos por $currentUid: $likedUserIds');
      } else {
        print('Erro ao buscar usuários curtidos: ${likedUsersResponse.statusCode} - ${likedUsersResponse.body}');
      }
    } catch (e) {
      print('Erro de rede ao buscar usuários curtidos: $e');
    }

    // 2. Buscar todos os usuários filtrados
    String baseUrl = 'https://e9f6-187-18-138-85.ngrok-free.app/api/usuarios/filtrar';
    Map<String, String> queryParams = {};
    if (widget.filtros.isNotEmpty) {
      widget.filtros.forEach((key, value) {
        if (value != null && value.toString().isNotEmpty) {
          queryParams[key] = value.toString();
        }
      });
    }

    String queryString = Uri(queryParameters: queryParams).query;
    String requestUrl = '$baseUrl?$queryString';

    print('URL da Requisição: $requestUrl');

    try {
      final response = await http.get(Uri.parse(requestUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Pessoa> fetchedPessoas = data.map((json) => Pessoa.fromJson(json)).toList();

        // 3. Filtrar: remover o próprio usuário e usuários já curtidos
        fetchedPessoas = fetchedPessoas.where((pessoa) =>
            pessoa.id != currentUid && // Remove o próprio usuário
            !likedUserIds.contains(pessoa.id) // Remove usuários já curtidos
        ).toList();

        setState(() {
          pessoas = fetchedPessoas;
          currentIndex = 0; // Reinicia o índice para o primeiro perfil após a filtragem
          _isLoading = false;
        });
        print('Pessoas após filtragem: ${pessoas.map((p) => p.nome).toList()}');
      } else {
        print('Erro na requisição: ${response.statusCode}');
        print('Corpo da resposta: ${response.body}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar pessoas: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String categoriaPesoUFC(int peso) {
    if (peso <= 56) return 'Peso Mosca';
    if (peso <= 61) return 'Peso Galo';
    if (peso <= 66) return 'Peso Pena';
    if (peso <= 70) return 'Peso Leve';
    if (peso <= 77) return 'Peso Meio-Médio';
    if (peso <= 84) return 'Peso Médio';
    if (peso <= 93) return 'Peso Meio-Pesado';
    if (peso <= 120) return 'Peso Pesado';
    return 'Categoria Fora do UFC';
  }

  Future<void> _like() async {
    if (currentIndex < pessoas.length) {
      final User? currentUser = FirebaseAuth.instance.currentUser;
      final String? senderId = currentUser?.uid;
      final String receiverId = pessoas[currentIndex].id;
      print('DEBUG: SenderId being sent: $senderId');
      print('DEBUG: ReceiverId being sent: $receiverId');

      if (senderId == null || senderId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro: ID do remetente não encontrado. Faça login novamente.')),
        );
        return;
      }

       final Uri likeUri = Uri.parse(
        'https://e9f6-187-18-138-85.ngrok-free.app/api/likes/create'
        '?senderId=$senderId&receiverId=$receiverId',
      );

      try {
        final likeResponse = await http.post(
          likeUri,
        );

        if (likeResponse.statusCode == 200 || likeResponse.statusCode == 201) {
          print('Like enviado com sucesso de $senderId para $receiverId');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Like enviado!')),
          );

          // NOVO: Verificar se houve um match
          try {
            final Uri checkMatchUri = Uri.parse(
              'https://e9f6-187-18-138-85.ngrok-free.app/api/likes/check?senderId=$receiverId&receiverId=$senderId',
            );
            final checkMatchResponse = await http.get(checkMatchUri);

            if (checkMatchResponse.statusCode == 200) {
              final bool isMatch = json.decode(checkMatchResponse.body);
              if (isMatch) {
                print('MATCH! $senderId e $receiverId deram match!');
                // Navegar para a TelaMatch
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaMatch(
                      nome1: 'Você', // Substitua pelo nome do usuário logado
                      foto1: 'assets/usuario.jpg', // Substitua pela foto do usuário logado
                      nome2: pessoas[currentIndex].nome,
                      foto2: pessoas[currentIndex].foto,
                    ),
                  ),
                );
              } else {
                print('Não houve match com ${pessoas[currentIndex].nome}.');
              }
            } else {
              print('Erro ao verificar match: ${checkMatchResponse.statusCode} - ${checkMatchResponse.body}');
            }
          } catch (e) {
            print('Erro na requisição de verificação de match: $e');
          }

          // A pessoa que acabou de ser curtida deve ser removida da lista.
          // Em vez de _fetchPessoas completo, podemos remover localmente
          // e ajustar o currentIndex, ou chamar _fetchPessoas para garantir consistência.
          // Para esta solução, vamos remover localmente e depois avançar.
          setState(() {
            pessoas.removeAt(currentIndex); // Remove o perfil curtido
            // Não incrementamos currentIndex aqui, pois removemos o item atual,
            // e o próximo item já estará na posição 'currentIndex'.
            // Se a lista ficar vazia, a interface de "sem mais perfis" será mostrada.
          });
          // Se a lista ficou vazia após a remoção, exibe a mensagem
          if (pessoas.isEmpty) {
            _showNoMoreProfilesMessage();
          }

        } else {
          print('Erro ao enviar like: ${likeResponse.statusCode} - ${likeResponse.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro ao enviar like: ${likeResponse.statusCode}')),
          );
          // Ainda avança para o próximo perfil mesmo com erro no like,
          // mas o perfil com erro será filtrado na próxima recarga de _fetchPessoas
          setState(() {
            currentIndex++;
          });
        }
      } catch (e) {
        print('Erro na requisição de like: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro de rede ao enviar like: $e')),
        );
        setState(() {
            currentIndex++;
          });
      }
    } else {
      _showNoMoreProfilesMessage();
    }
  }

  void _dislike() {
    if (currentIndex < pessoas.length) {
      setState(() {
        pessoas.removeAt(currentIndex); // Remove o perfil descartado
      });
      if (pessoas.isEmpty) {
        _showNoMoreProfilesMessage();
      }
      // Não incrementamos currentIndex aqui
    } else {
      _showNoMoreProfilesMessage();
    }
  }

  void _showNoMoreProfilesMessage() {
    // Redefine currentIndex para 0 quando não há mais perfis
    // para que a mensagem de "nenhum parceiro encontrado" seja exibida corretamente
    setState(() {
      currentIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Não há mais perfis para mostrar.'),
        backgroundColor: const Color(0xFF8B2E2E),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _confirmarSaida() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => SimpleDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.0),
            child: Text(
              'Deseja sair da conta?',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text('Sair', style: TextStyle(color: Color(0xFF8B2E2E))),
              ),
            ],
          )
        ],
      ),
    );

    if (confirmar == true) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/login',
          (route) => false,
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    exit(0);
  }

  Widget _buildPerfil() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (pessoas.isEmpty) { // Alterado para verificar se a lista está vazia
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🥊', style: TextStyle(fontSize: 50)),
            const SizedBox(height: 16),
            const Text(
              'Nenhum parceiro encontrado\ncom esses filtros.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Tente ajustar seus filtros\npara encontrar mais parceiros!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.black45,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                _fetchPessoas();
              },
              icon: const Icon(Icons.refresh, color: Colors.white),
              label: const Text('Recarregar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B2E2E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ],
        ),
      );
    }

    // Se houver pessoas, exibe o perfil na posição atual do currentIndex
    final pessoa = pessoas[currentIndex];

    return SingleChildScrollView(
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: NetworkImage(pessoa.foto),
              ),
              const SizedBox(height: 20),
              Text(
                '${pessoa.nome}, ${pessoa.idade}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8B2E2E),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_on, size: 18, color: Colors.black54),
                  const SizedBox(width: 6),
                  Text(
                    pessoa.local,
                    style: const TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${pessoa.genero} • ${pessoa.altura} cm • ${categoriaPesoUFC(pessoa.peso)}',
                style: const TextStyle(color: Colors.black54, fontSize: 15),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  pessoa.descricao,
                  style: const TextStyle(fontSize: 15, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: pessoa.modalidades.map((modalidade) {
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B2E2E),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Text(
                      modalidade,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _dislike,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.close, color: Color(0xFF8B2E2E), size: 45),
                    ),
                  ),
                  const SizedBox(width: 60),
                  GestureDetector(
                    onTap: _like,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B2E2E),
                        shape: BoxShape.circle,
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black45,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.sports_mma, color: Colors.white, size: 40),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoVoltar() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8B2E2E)),
      onPressed: _confirmarSaida,
      splashRadius: 24,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _buildBotaoVoltar(),
                        const SizedBox(width: 12),
                        const Text(
                          'Explorar',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B2E2E),
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF8B2E2E)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const TelaHistoricoChats()),
                        );
                      },
                      splashRadius: 24,
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_outline, color: Color(0xFF8B2E2E)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const PerfilUsuarioPage()),
                        );
                      },
                      splashRadius: 24,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _buildPerfil(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}