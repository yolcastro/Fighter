import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fighter_app/usuario.service.dart';
import 'editar.dart';

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
                onPressed: () => Navigator.pop(context, true),
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
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
        pesoCategoria = dados['pesoCategoria'] ?? pesoCategoria;
        local = dados['localizacao'] ?? local;
        descricao = dados['descricao'] ?? descricao;
        estilos = List<String>.from(dados['arteMarcial'] ?? estilos);
        nivelExperiencia = dados['nivelExperiencia'] ?? nivelExperiencia;
        dataNascimento = dados['dataNascimento'] ?? dataNascimento;

        idade = calcularIdade(dataNascimento);
        print('Data nascimento: $dataNascimento -> idade: $idade');
      });
    } else {
      print('Não foi possível carregar os dados do usuário');
    }
  }

  int calcularIdade(String data) {
    try {
      final partes = data.split(' de ');
      if (partes.length == 3) {
        final dia = int.tryParse(partes[0]) ?? 1;
        final mesStr = partes[1].toLowerCase();
        final ano = int.tryParse(partes[2]) ?? 2000;

        final meses = {
          'janeiro': 1,
          'fevereiro': 2,
          'março': 3,
          'abril': 4,
          'maio': 5,
          'junho': 6,
          'julho': 7,
          'agosto': 8,
          'setembro': 9,
          'outubro': 10,
          'novembro': 11,
          'dezembro': 12,
        };

        final mes = meses[mesStr] ?? 1;
        final nascimento = DateTime(ano, mes, dia);
        final hoje = DateTime.now();

        int idade = hoje.year - nascimento.year;
        if (hoje.month < nascimento.month ||
            (hoje.month == nascimento.month && hoje.day < nascimento.day)) {
          idade--;
        }
        return idade;
      }
    } catch (e) {
      print('Erro ao calcular idade: $e');
    }
    return 0;
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
                    const CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage('assets/usuario.jpg'),
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
