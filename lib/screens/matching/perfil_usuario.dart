import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fighter_app/usuario.service.dart';
import 'editar.dart';
import 'package:intl/intl.dart'; // Importe para usar DateFormat

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  String nome = '...';
  String genero = '...';
  int altura = 0;
  String pesoCategoria = '...';
  String local = '...';
  String descricao = '...';
  List<String> estilos = [];
  String nivelExperiencia = '...';
  String dataNascimento = '';
  int idade = 0;
  String fotoPerfilUrl = ''; // Adicionar campo para a URL da foto de perfil

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
                child: const Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (mounted) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text(
                  'Sair',
                  style: TextStyle(color: Color(0xFF8B2E2E)),
                ),
              ),
            ],
          )
        ],
      ),
    );

    if (confirmar == true) {
      // ✅ Desloga do Firebase antes de navegar
      await FirebaseAuth.instance.signOut();

      // ✅ Navega para login removendo todas as rotas anteriores
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  Future<void> carregarDadosUsuario() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('Nenhum usuário logado.');
      return;
    }

    final dados = await UsuarioService.buscarUsuarioPorId(currentUser.uid);
    print('DADOS USUARIO: $dados');

    if (dados != null) {
      setState(() {
        nome = dados['nome'] ?? nome;
        genero = dados['sexo'] ?? genero;
        altura = dados['alturaEmCm'] ?? altura;
        // O campo 'pesoCategoria' não existe diretamente no POJO Pessoa,
        // ele é calculado em explorador.dart. Aqui, vamos usar o peso e calcular.
        final int peso = dados['peso'] ?? 0;
        pesoCategoria = categoriaPesoUFC(peso); // Calcula a categoria de peso
        local = dados['localizacao'] ?? local;
        descricao = dados['descricao'] ?? descricao;
        estilos = List<String>.from(dados['arteMarcial'] ?? estilos);
        nivelExperiencia = dados['nivelExperiencia'] ?? nivelExperiencia;
        dataNascimento = dados['dataNascimento'] ?? dataNascimento;
        fotoPerfilUrl = dados['fotoPerfilUrl'] ?? ''; // Carrega a URL da foto

        idade = calcularIdade(dataNascimento);
        print('Data nascimento: $dataNascimento -> idade: $idade');
      });
    } else {
      print('Não foi possível carregar os dados do usuário');
    }
  }

  // Função para determinar a categoria de peso UFC (copiada de explorador.dart)
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

  // Adaptação da função calcularIdade para o formato DD/MM/YYYY
  int calcularIdade(String data) {
    try {
      if (data.isEmpty) return 0;

      // Tenta parsear no formato DD/MM/YYYY
      final DateTime birthDate = DateFormat('dd/MM/yyyy').parse(data);
      final DateTime today = DateTime.now();

      int calculatedAge = today.year - birthDate.year;
      if (today.month < birthDate.month ||
          (today.month == birthDate.month && today.day < birthDate.day)) {
        calculatedAge--;
      }
      return calculatedAge < 0 ? 0 : calculatedAge; // Garante que a idade não seja negativa
    } catch (e) {
      print('Erro ao calcular idade para a data "$data": $e');
      return 0; // Retorna 0 em caso de erro
    }
  }

  // Função auxiliar para obter ImageProvider
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
  void initState() {
    super.initState();
    carregarDadosUsuario();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // fundo geral branco
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFEF), // cabeçalho efefef
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
                        Navigator.pop(context);
                      },
                    ),
                  ),
                  const Text(
                    'Meu Perfil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.logout, color: Color(0xFF8B2E2E)),
                          onPressed: _confirmarSaida,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF8B2E2E)),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditarPerfil()),
                            );
                            if (result == true) {
                              carregarDadosUsuario(); // recarrega após edição
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _getImageProvider(fotoPerfilUrl), // Usa a URL da foto carregada
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '$nome, $idade',
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
                          local,
                          style: const TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: [
                        Text(
                          '$genero • ${altura}cm',
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          pesoCategoria,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF), // bloco descrição efefef
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        descricao,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: estilos.map((arte) {
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
                            arte,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      nivelExperiencia,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
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
