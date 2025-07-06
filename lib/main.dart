import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart'; // ✅ Importação adicionada

// Screens de autenticação e onboarding
import 'screens/home/tela_inicial.dart';
import 'screens/auth/login.dart';
import 'screens/auth/cadastro.dart';
import 'screens/onboarding/quase_la.dart';
import 'screens/onboarding/data.dart';
import 'screens/onboarding/localizacao.dart';
import 'screens/onboarding/caracteristicas.dart';
import 'screens/onboarding/preferencias.dart';
import 'screens/onboarding/artes_marciais.dart';
import 'screens/onboarding/foto_perfil.dart';
import 'screens/onboarding/boas_vindas.dart';

// Screens de matching
import 'screens/matching/explorar.dart';
import 'screens/matching/match.dart';
import 'screens/matching/chat.dart';
import 'screens/matching/historico_conversas.dart';
import 'screens/matching/perfil_adversario.dart';
import 'screens/matching/perfil_usuario.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // ✅ Usando firebase_options.dart
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fighter App',
      theme: ThemeData(
        primaryColor: const Color(0xFF8B2E2E),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF8B2E2E),
          secondary: const Color(0xFF8B2E2E),
        ),
      ),
      home: const AuthGate(),
      routes: {
        // Home & Autenticação
        '/login': (context) => const TelaLogin(),
        '/cadastro': (context) => const TelaCadastro(),

        // Onboarding
        '/quase_la': (context) => const TelaQuaseLa(),
        '/dados_pessoais': (context) => const TelaDataNascimento(),
        '/localizacao': (context) => const TelaLocalizacao(),
        '/caracteristicas': (context) => const TelaCaracteristicas(),
        '/preferencias': (context) => const PreferenciasParceiroPage(),
        '/artes_marciais': (context) => const TelaArtesMarciais(),
        '/fotoperfil': (context) => const TelaFotoDescricao(),
        '/boasvindas': (context) => const TelaBoasVindas(),

        // Matching
        '/explorar': (context) => const TelaExplorar(),
        '/chat': (context) => const TelaChat(),
        '/historico_conversas': (context) => const TelaHistoricoChats(),
        '/perfil_adversario': (context) => const PerfilAdversarioPage(),
        '/perfil_usuario': (context) => const PerfilUsuarioPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/match') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => TelaMatch(
              nome1: args['nome1'],
              foto1: args['foto1'],
              nome2: args['nome2'],
              foto2: args['foto2'],
            ),
          );
        }
        return null;
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          return const TelaExplorar();
        } else {
          return const TelaInicial();
        }
      },
    );
  }
}
