import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fighter_app/usuario.service.dart';
import 'editar.dart';

class EditarArtes extends StatefulWidget {
  const EditarArtes({super.key});

  @override
  State<EditarArtes> createState() => _EditarArtesState();
}

class _EditarArtesState extends State<EditarArtes> {
  final List<String> artes = [
    'Boxe',
    'Capoeira',
    'Jiu-Jitsu',
    'Judô',
    'Karatê',
    'Krav Maga',
    'MMA',
    'Muay Thai',
    'Taekwondo',
  ];

  final List<String> niveis = ['Iniciante', 'Intermediário', 'Avançado'];
  String? nivelSelecionado;
  List<String> selecionadas = [];

  bool get podeSalvar => selecionadas.isNotEmpty && nivelSelecionado != null;

  @override
  void initState() {
    super.initState();
    carregarArtesUsuario();
  }

  Future<void> carregarArtesUsuario() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final dados = await UsuarioService.buscarUsuarioPorId(user.uid);
    if (dados != null) {
      setState(() {
        nivelSelecionado = dados['nivelExperiencia'];
        selecionadas = List<String>.from(dados['arteMarcial'] ?? []);
      });
    }
  }

  Future<void> salvarArtes() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await UsuarioService.atualizarUsuario(user.uid, {
      'nivelExperiencia': nivelSelecionado,
      'arteMarcial': selecionadas,
    });

    // Após salvar, volta para EditarPerfil e força recarregamento dos dados atualizados
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const EditarPerfil()),
    );
  }

  void selecionarArte(String arte) {
    setState(() {
      if (selecionadas.contains(arte)) {
        selecionadas.remove(arte);
      } else {
        if (selecionadas.length >= 2) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Selecione no máximo 2 artes marciais.'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          selecionadas.add(arte);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAppBar(),
                  const SizedBox(height: 16),
                  _buildNivelExperiencia(),
                  const SizedBox(height: 16),
                  Expanded(child: _buildListaArtes()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
          tooltip: 'Voltar',
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const EditarPerfil()),
          ),
          splashRadius: 24,
        ),
        IconButton(
          icon: const Icon(Icons.save, color: Color(0xFF8D0000)),
          tooltip: 'Salvar',
          onPressed: podeSalvar ? salvarArtes : null,
          splashRadius: 24,
        ),
      ],
    );
  }

  Widget _buildNivelExperiencia() {
    return Wrap(
      spacing: 12,
      children: niveis.map((n) {
        final ativo = nivelSelecionado == n;
        return ChoiceChip(
          label: Text(n),
          selected: ativo,
          onSelected: (_) => setState(() => nivelSelecionado = n),
          selectedColor: const Color(0xFF8D0000),
          backgroundColor: const Color(0xFFF5F5F5),
          labelStyle: TextStyle(
            color: ativo ? Colors.white : const Color(0xFF000000),
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        );
      }).toList(),
    );
  }

  Widget _buildListaArtes() {
    return ListView.builder(
      itemCount: artes.length,
      itemBuilder: (context, index) {
        final arte = artes[index];
        final estaSelecionada = selecionadas.contains(arte);
        return GestureDetector(
          onTap: () => selecionarArte(arte),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: estaSelecionada ? const Color(0xFF8D0000).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: estaSelecionada ? const Color(0xFF8D0000) : const Color(0xFFE0E0E0),
                width: 1.6,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  arte,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: estaSelecionada ? const Color(0xFF8D0000) : const Color(0xFF000000),
                  ),
                ),
                if (estaSelecionada)
                  const Icon(Icons.check, size: 20, color: Color(0xFF8D0000)),
              ],
            ),
          ),
        );
      },
    );
  }
}
