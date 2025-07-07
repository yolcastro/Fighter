import 'package:flutter/material.dart';

class PerfilAdversarioPage extends StatelessWidget {
  const PerfilAdversarioPage({super.key});

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

  int calcularIdade(String data) {
    try {
      final partes = data.split(' de ');
      if (partes.length == 3) {
        final dia = int.tryParse(partes[0]) ?? 1;
        final mesStr = partes[1].toLowerCase();
        final ano = int.tryParse(partes[2]) ?? 2002;

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
  Widget build(BuildContext context) {
    final String nome = 'Marina';
    final String genero = 'Mulher';
    final int altura = 170;
    final int peso = 62;
    final String local = 'Fortaleza, Ceará';
    final String descricao = 'Capoeirista com alma leve. Treino é conexão.';
    final List<String> estilos = ['Capoeira - Intermediário'];
    final String dataNascimento = '5 de maio de 2002';

    final int idade = calcularIdade(dataNascimento);

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
                    'Perfil',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
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
                      backgroundImage: AssetImage('assets/marina.jpg'),
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
                        color: const Color(0xFFEFEFEF), // descrição fundo efefef
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
                        final partes = estilo.split(' - ');
                        final nomeArte = partes[0];
                        final nivel = partes.length > 1 ? partes[1] : 'N/A';

                        return Column(
                          children: [
                            Container(
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
                                nomeArte,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              nivel,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
