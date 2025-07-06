import 'package:flutter/material.dart';
import 'editar.dart';

class PerfilUsuarioPage extends StatefulWidget {
  const PerfilUsuarioPage({super.key});

  @override
  State<PerfilUsuarioPage> createState() => _PerfilUsuarioPageState();
}

class _PerfilUsuarioPageState extends State<PerfilUsuarioPage> {
  String nome = 'Jonas';
  String genero = 'Masculino';
  int altura = 180;
  int peso = 70;
  String local = 'Fortaleza, Ceará';
  String descricao = 'Pronto pra evoluir a cada treino!';
  List<String> estilos = ['Capoeira - Avançado', 'Jiu-Jitsu - Intermediário', 'Muay Thai - Avançado'];

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
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Colors.white,
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
                          icon: const Icon(Icons.settings, color: Color(0xFF8B2E2E)),
                          onPressed: () {
                            _confirmarSaida();
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF8B2E2E)),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const EditarPerfil()),
                            );

                            if (result == true) {
                              setState(() {
                                nome = 'Jonas Atualizado';
                                descricao = 'Descrição atualizada após edição.';
                              });
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
                      nome,
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
                    Text(
                      '$genero • ${altura}cm • ${categoriaPesoUFC(peso)}',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
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
                      children: estilos.map((estilo) {
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
                            estilo,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
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