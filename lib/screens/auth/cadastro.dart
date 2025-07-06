import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart'; // Importe o Firebase Auth

import '../onboarding/quase_la.dart'; // Certifique-se de que o caminho está correto

// Uma classe simples para a tela de erro de cadastro, caso ainda não exista
class TelaErroCadastro extends StatelessWidget {
  final String mensagem;

  const TelaErroCadastro({super.key, required this.mensagem});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEFEF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFEFEFEF),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 80, color: Color(0xFF8D0000)),
              const SizedBox(height: 20),
              const Text(
                'Erro no cadastro',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                mensagem,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF343434),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8D0000),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
                child: const Text(
                  'Voltar',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class TelaCadastro extends StatefulWidget {
  const TelaCadastro({super.key});

  @override
  State<TelaCadastro> createState() => _TelaCadastroState();
}

class _TelaCadastroState extends State<TelaCadastro> {
  final emailController = TextEditingController();
  final senhaController = TextEditingController();
  final confirmarSenhaController = TextEditingController();
  final nomeController = TextEditingController();

  bool validarEmail(String email) {
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(email);
  }

  void tentarCadastrar() {
    final email = emailController.text.trim();
    final senha = senhaController.text;
    final confirmarSenha = confirmarSenhaController.text;
    final nome = nomeController.text.trim();

    if (nome.isEmpty) {
      mostrarMensagem('Insira seu nome.');
      return;
    }

    if (!validarEmail(email)) {
      mostrarMensagem('Insira um e-mail válido.');
      return;
    }

    if (senha.isEmpty || confirmarSenha.isEmpty) {
      mostrarMensagem('Preencha todos os campos de senha.');
      return;
    }

    if (senha.length < 6) {
      mostrarMensagem('A senha deve ter no mínimo 6 caracteres.');
      return;
    }

    if (senha != confirmarSenha) {
      mostrarMensagem('As senhas não coincidem.');
      return;
    }

    cadastrarUsuario(email, senha, nome);
  }

  Future<void> cadastrarUsuario(String email, String password, String displayName) async {
    final url = Uri.parse('https://e9f6-187-18-138-85.ngrok-free.app/api/auth/register');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'displayName': displayName,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Cadastro bem-sucedido na sua API
        mostrarMensagem('Cadastro realizado com sucesso na API! Tentando login no Firebase...');

        try {
          // Tenta fazer login no Firebase Authentication com as mesmas credenciais
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email,
            password: password,
          );
          // Se o login no Firebase for bem-sucedido
          print('Login automático no Firebase bem-sucedido!');
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const TelaQuaseLa()),
          );
        } on FirebaseAuthException catch (e) {
          // Erro no login do Firebase
          String firebaseErrorMessage = 'Erro desconhecido no login do Firebase.';
          if (e.code == 'user-not-found') {
            firebaseErrorMessage = 'Usuário não encontrado no Firebase (pode ser um atraso na criação).';
          } else if (e.code == 'wrong-password') {
            firebaseErrorMessage = 'Credenciais inválidas no Firebase.';
          } else if (e.code == 'network-request-failed') {
            firebaseErrorMessage = 'Problema de conexão ao tentar logar no Firebase.';
          }
          print('Erro no login automático do Firebase: ${e.code} - ${e.message}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TelaErroCadastro(mensagem: 'Erro no login automático: $firebaseErrorMessage'),
            ),
          );
        } catch (e) {
          // Outros erros inesperados no login do Firebase
          print('Exceção inesperada no login do Firebase: $e');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TelaErroCadastro(mensagem: 'Erro inesperado ao tentar logar no Firebase.'),
            ),
          );
        }
      } else {
        // Erro no cadastro da sua API
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        String mensagemErro = 'Erro ao cadastrar: ${response.statusCode}';

        if (responseBody.containsKey('message')) {
          mensagemErro = responseBody['message'].toString();
        }

        // Redireciona para tela de erro personalizada
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaErroCadastro(mensagem: mensagemErro),
          ),
        );
      }
    } catch (e) {
      // Erro de conexão com a sua API
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TelaErroCadastro(mensagem: 'Erro de conexão com a API de cadastro.'),
        ),
      );
      print('Exception: $e');
    }
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
        backgroundColor: const Color(0xFFEFEFEF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFEFEFEF),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF343434)),
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
                _buildTextField(nomeController, 'Nome', TextInputType.text),
                const SizedBox(height: 16),
                _buildTextField(emailController, 'E-mail', TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildTextField(senhaController, 'Senha', TextInputType.visiblePassword, isPassword: true),
                const SizedBox(height: 16),
                _buildTextField(confirmarSenhaController, 'Confirme a senha', TextInputType.visiblePassword, isPassword: true),
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
        Image.asset('assets/boxing.png', height: 50),
        const SizedBox(width: 10),
        const Text(
          'FIGHTER',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8D0000),
          ),
        ),
      ],
    );
  }

  Widget _buildTitulo() {
    return const Text(
      'Crie a sua conta',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Color(0xFF343434),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint,
    TextInputType inputType, {
    bool isPassword = false,
  }) {
    return SizedBox(
      width: 320,
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: inputType,
        style: const TextStyle(
          color: Color(0xFF000000),
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 16,
          ),
          filled: true,
          fillColor: const Color(0xFFDADADA),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        ),
      ),
    );
  }

  Widget _buildBotaoCadastro() {
    return SizedBox(
      width: 220,
      child: ElevatedButton(
        onPressed: tentarCadastrar,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8D0000),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          shadowColor: Colors.black12,
          elevation: 4,
        ),
        child: const Text(
          'Cadastre-se',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}