import 'package:flutter/material.dart';

import 'screens/home/tela_inicial.dart';
import 'screens/auth/login.dart';
import 'screens/auth/cadastro.dart';
import 'screens/onboarding/quase_la.dart';
import 'screens/onboarding/dados_pessoais.dart';
import 'screens/onboarding/localizacao.dart';
import 'screens/onboarding/caracteristicas.dart';
import 'screens/onboarding/preferencias.dart';
import 'screens/onboarding/artes_marciais.dart';
import 'screens/onboarding/fotoperfil.dart';
import 'screens/onboarding/boasvindas.dart';

import 'screens/matching/explorar.dart';
import 'screens/matching/match.dart';
import 'screens/matching/chat.dart';

void main() {
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
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF8B2E2E),
          secondary: const Color(0xFF8B2E2E),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const TelaInicial(),
        '/login': (context) => const TelaLogin(),
        '/cadastro': (context) => const TelaCadastro(),
        '/quase_la': (context) => const TelaQuaseLa(),
        '/dados_pessoais': (context) => const TelaDadosPessoais(),
        '/localizacao': (context) => const TelaLocalizacao(),
        '/caracteristicas': (context) => const TelaCaracteristicas(),
        '/preferencias': (context) => const PreferenciasParceiroPage(),
        '/artes_marciais': (context) => const TelaArtesMarciais(),
        '/fotoperfil': (context) => const TelaFotoDescricao(),
        '/boasvindas': (context) => const TelaBoasVindas(),

        '/explorar': (context) => const TelaExplorar(),
        '/match': (context) => const TelaMatch(
          nome1: 'Você',
          foto1: 'assets/seufoto.jpg',
          nome2: 'Ana',
          foto2: 'assets/ana.jpg',
        ),
        '/chat': (context) => const TelaChat(),
      },
    );
  }
}
