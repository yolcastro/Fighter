// artes_marciais.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fighter_app/usuario.service.dart'; // ajuste conforme seu projeto
// Certifique-se de que o ExplorarPage está importado corretamente
// import 'package:fighter_app/explorar_page.dart'; // Ou o caminho para sua tela de explorar

class TelaArtesMarciais extends StatefulWidget {
  final String? sexo; // Preferência de sexo do parceiro
  final String? nivelExperiencia; // Preferência de nível do parceiro
  final String? pesoCategoria; // Preferência de peso do parceiro

  const TelaArtesMarciais({
    super.key,
    this.sexo,
    this.nivelExperiencia,
    this.pesoCategoria,
  });

  @override
  State<TelaArtesMarciais> createState() => _TelaArtesMarciaisState();
}

class _TelaArtesMarciaisState extends State<TelaArtesMarciais> {
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
  String? nivelSelecionado; // Nível de experiência DO USUÁRIO
  final List<String> selecionadas = []; // Artes Marciais DO USUÁRIO

  bool get podeAvancar => selecionadas.isNotEmpty && nivelSelecionado != null;

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

  Future<void> salvarEDefinirProximo() async {
    if (!podeAvancar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione ao menos 1 arte marcial e um nível de experiência.')),
      );
      return;
    }

    final User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum usuário logado. Faça login novamente.')),
      );
      return;
    }

    // Dados que serão ATUALIZADOS no backend para O USUÁRIO ATUAL
    final Map<String, dynamic> updateData = {
      'arteMarcial': selecionadas, // Artes marciais do usuário
      'nivelExperiencia': nivelSelecionado, // Nível de experiência do usuário
    };

    // Criar o mapa de FILTROS COMPLETO para passar para a TELA DE EXPLORAR
    // Isso inclui as preferências passadas de PreferenciasParceiroPage
    // e as artes marciais/nível selecionados nesta tela.
    final Map<String, dynamic> filtrosParaExplorar = {
      // Preferências de PreferenciasParceiroPage (se não forem nulas)
      if (widget.sexo != null) 'sexo': widget.sexo, // Pref. sexo do parceiro
      if (widget.nivelExperiencia != null) 'nivelExperiencia': widget.nivelExperiencia, // Pref. nível do parceiro
      if (widget.pesoCategoria != null) 'pesoCategoria': widget.pesoCategoria, // Pref. peso do parceiro

      // Preferências/características definidas nesta tela para o FILTRO
      // Note: O nome do campo na API para 'arteMarcial' e 'nivelExperiencia'
      // no contexto de filtro de PARCEIRO deve corresponder.
      // Use os nomes dos campos da sua entidade 'Usuario' para o filtro.
      if (selecionadas.isNotEmpty) 'arteMarcial': selecionadas, // Artes marciais do parceiro (a ser filtrado)
      if (nivelSelecionado != null) 'nivelExperiencia': nivelSelecionado, // Nível de experiência do parceiro (a ser filtrado)
    };

    final sucesso = await UsuarioService.atualizarUsuario(currentUser.uid, updateData);
    if (sucesso) {
      // Passa os filtros completos para a próxima tela
      // O '/fotoperfil' deve ser configurado para receber esses argumentos e passá-los adiante
      // ou ser a própria tela que iniciará a navegação para ExplorarPage com esses filtros.
      Navigator.pushNamed(context, '/fotoperfil', arguments: filtrosParaExplorar);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao salvar suas artes marciais.')),
      );
    }
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
                  _buildBotaoVoltar(),
                  const SizedBox(height: 24),
                  _buildTitulo(),
                  const SizedBox(height: 16),
                  _buildNivelExperiencia(),
                  const SizedBox(height: 24),
                  Expanded(child: _buildListaArtes()),
                  const SizedBox(height: 24),
                  _buildBotaoProximo(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoVoltar() {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF8D0000)),
      tooltip: 'Voltar',
      onPressed: () => Navigator.pop(context),
      splashRadius: 24,
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'O que você pratica?\nE qual seu nível?',
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color(0xFF000000),
      ),
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
        final selecionada = selecionadas.contains(arte);
        return GestureDetector(
          onTap: () => selecionarArte(arte),
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: selecionada ? const Color(0xFF8D0000).withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: selecionada ? const Color(0xFF8D0000) : const Color(0xFFE0E0E0),
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
                    color: selecionada ? const Color(0xFF8D0000) : const Color(0xFF000000),
                  ),
                ),
                if (selecionada)
                  const Icon(Icons.check, size: 20, color: Color(0xFF8D0000)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBotaoProximo() {
    return Center(
      child: SizedBox(
        width: 220,
        height: 56,
        child: Opacity(
          opacity: podeAvancar ? 1.0 : 0.5,
          child: ElevatedButton(
            onPressed: podeAvancar ? salvarEDefinirProximo : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8D0000),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
              elevation: 4,
              shadowColor: Colors.black12,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              'PRÓXIMO',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}