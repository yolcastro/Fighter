import 'package:flutter/material.dart';
import '../onboarding/quase_la.dart';

class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();

  bool validarEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}\$');
    return regex.hasMatch(email);
  }

  void tentarCadastrar() {
    final email = emailController.text.trim();
    final senha = senhaController.text;
    final confirmarSenha = confirmarSenhaController.text;

    if (!validarEmail(email)) {
      mostrarMensagem('Insira um e-mail válido.');
      return;
    }

    if (senha.isEmpty || confirmarSenha.isEmpty) {
      mostrarMensagem('Preencha todos os campos de senha.');
      return;
    }

    if (senha != confirmarSenha) {
      mostrarMensagem('As senhas não coincidem.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TelaQuaseLa()),
    );
  }

  void mostrarMensagem(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensagem)),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacementNamed(context, '/');
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLogo(),
                const SizedBox(height: 24),
                _buildTitulo(),
                const SizedBox(height: 32),
                _buildEmailField(),
                const SizedBox(height: 16),
                _buildSenhaField(),
                const SizedBox(height: 16),
                _buildConfirmarSenhaField(),
                const SizedBox(height: 32),
                _buildBotaoCadastro(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/boxing.png', height: 60),
        const SizedBox(width: 10),
        const Text(
          'FIGHTER',
          style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'Crie a sua conta',
      style: TextStyle(fontSize: 18),
    );
  }

  Widget _buildEmailField() {
    return TextField(
      controller: emailController,
      decoration: InputDecoration(
        hintText: 'E-mail',
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _buildSenhaField() {
    return TextField(
      controller: senhaController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Senha',
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildConfirmarSenhaField() {
    return TextField(
      controller: confirmarSenhaController,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Confirme a senha',
        filled: true,
        fillColor: Colors.grey[300],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  Widget _buildBotaoCadastro() {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        onPressed: tentarCadastrar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B2E2E),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        child: const Text(
          'Cadastre-se',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
