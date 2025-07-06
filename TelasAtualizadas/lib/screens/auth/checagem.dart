import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthCheckScreen extends StatefulWidget {
  @override
  _AuthCheckScreenState createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  String? _userUid;

  @override
  void initState() {
    super.initState();
    _getUid();
  }

  void _getUid() {
    final user = FirebaseAuth.instance.currentUser; // Obtém o usuário logado

    if (user != null) {
      setState(() {
        _userUid = user.uid; // Pega o UID
      });
      print('UID do usuário logado: ${user.uid}');
    } else {
      setState(() {
        _userUid = null;
      });
      print('Nenhum usuário logado.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UID do Usuário'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_userUid != null)
              Text(
                'Seu UID: $_userUid',
                style: TextStyle(fontSize: 20),
              )
            else
              Text(
                'Por favor, faça login para ver seu UID.',
                style: TextStyle(fontSize: 18, color: Colors.red),
              ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Exemplo de como você faria login (apenas para demonstração)
                try {
                  await FirebaseAuth.instance.signInAnonymously(); // Login anônimo para teste
                  _getUid(); // Atualiza o UID após o login
                } catch (e) {
                  print('Erro no login: $e');
                }
              },
              child: Text('Fazer Login (Anônimo)'),
            ),
            ElevatedButton(
              onPressed: () async {
                await FirebaseAuth.instance.signOut(); // Fazer logout
                _getUid(); // Atualiza o UID após o logout
              },
              child: Text('Fazer Logout'),
            ),
          ],
        ),
      ),
    );
  }
}