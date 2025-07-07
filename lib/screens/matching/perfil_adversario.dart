import 'package:flutter/material.dart';
import 'package:fighter_app/screens/matching/explorar.dart'; // Importe a classe Pessoa

class PerfilAdversarioPage extends StatelessWidget {
  final Pessoa adversario; // Objeto Pessoa para o adversário

  const PerfilAdversarioPage({
    super.key,
    required this.adversario, // O adversário é obrigatório
  });

  // Função para determinar a categoria de peso UFC
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

  // Função auxiliar para obter ImageProvider (reutilizada de explorador.dart)
  ImageProvider _getImageProvider(String fotoUrl) {
    if (fotoUrl.startsWith('assets/')) {
      return AssetImage(fotoUrl);
    } else if (fotoUrl.startsWith('http://') || fotoUrl.startsWith('https://')) {
      return NetworkImage(fotoUrl);
    } else {
      // Placeholder para URLs inválidas ou vazias
      return const AssetImage('assets/usuario.jpg'); // Certifique-se de ter esta imagem
    }
  }

  @override
  Widget build(BuildContext context) {
    // Usar os dados do objeto 'adversario' diretamente
    final String nome = adversario.nome;
    final int idade = adversario.idade;
    final String genero = adversario.genero;
    final int altura = adversario.altura;
    final int peso = adversario.peso;
    final String local = adversario.local;
    final String descricao = adversario.descricao;
    final List<String> modalidades = adversario.modalidades; // 'modalidades' é a lista de estilos/artes
    final String fotoUrl = adversario.foto; // URL ou caminho da foto

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // AppBar customizada
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: const BoxDecoration(
                color: Color(0xFFEFEFEF), // Fundo do appbar
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
                        Navigator.pop(context); // Volta para a tela anterior (geralmente o chat)
                      },
                      splashRadius: 24,
                    ),
                  ),
                  const Text(
                    'Perfil do Adversário', // Título mais específico
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            // Conteúdo do perfil
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Foto de perfil
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: _getImageProvider(fotoUrl), // Usa a função auxiliar
                    ),
                    const SizedBox(height: 20),

                    // Nome e idade
                    LayoutBuilder(
                      builder: (context, constraints) {
                        // Define um limite de largura para o nome + idade na mesma linha
                        double maxWidth = constraints.maxWidth * 0.7; // ajuste a porcentagem se necessário

                        TextSpan fullText = TextSpan(
                          text: '$nome, $idade',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF8B2E2E),
                          ),
                        );

                        TextPainter tp = TextPainter(
                          text: fullText,
                          maxLines: 1,
                          textDirection: Directionality.of(context),
                        );

                        tp.layout(maxWidth: maxWidth);

                        // Se ultrapassar o limite, exibe nome e idade em linhas separadas
                        if (tp.didExceedMaxLines) {
                          return Column(
                            children: [
                              Text(
                                '$nome,',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B2E2E),
                                ),
                                textAlign: TextAlign.center,
                              ),
                              Text(
                                '$idade',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF8B2E2E),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Text.rich(fullText, textAlign: TextAlign.center);
                        }
                      },
                    ),
                    const SizedBox(height: 8),

                    // Localização
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
                    const SizedBox(height: 8), // Espaçamento ajustado

                    // Gênero e altura (primeira linha)
                    Text(
                      '$genero • ${altura}cm',
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4), // Espaçamento entre as linhas de detalhes

                    // Categoria de peso (segunda linha)
                    Text(
                      categoriaPesoUFC(peso), // Usando a função para obter a categoria
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Descrição
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFEFEF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        descricao,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Modalidades/Estilos de Luta (apenas o nome da arte)
                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      alignment: WrapAlignment.center,
                      children: modalidades.map((modalidade) {
                        // Divide "Arte - Nível" para pegar apenas o nome da arte
                        final nomeArte = modalidade.split(' - ')[0];

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
                            nomeArte, // Exibe apenas o nome da arte
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    // Não há um campo 'nivelExperiencia' geral em Pessoa para exibir aqui,
                    // então a seção correspondente do PerfilUsuarioPage não será replicada.
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
