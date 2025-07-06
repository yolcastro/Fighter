import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  static const String baseUrl = 'https://098b-187-18-138-85.ngrok-free.app/api/usuarios/';

  static Future<String?> criarUsuario(Map<String, dynamic> usuario) async {
    final url = Uri.parse(baseUrl);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(usuario),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final uid = data['uid'];
        print('Usuário criado com uid: $uid');
        return uid;
      } else {
        print('Erro ao criar usuário: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exceção ao criar usuário: $e');
      return null;
    }
  }

  /// NOVA FUNÇÃO: Atualiza os dados de um usuário existente.
  /// Recebe o ID do usuário e um mapa com os campos a serem atualizados.
  /// Retorna true se a atualização foi bem-sucedida, false caso contrário.
  static Future<bool> atualizarUsuario(String userId, Map<String, dynamic> updateData) async {
    // Constrói a URL para a requisição PUT, incluindo o ID do usuário no path.
    final url = Uri.parse('$baseUrl$userId');

    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          // Se sua API exige um token de autenticação (Firebase ID Token), adicione-o aqui:
          // 'Authorization': 'Bearer ${await FirebaseAuth.instance.currentUser?.getIdToken()}',
        },
        body: jsonEncode(updateData), // Envia os dados de atualização no corpo da requisição
      );

      if (response.statusCode == 200) { // HTTP 200 OK indica sucesso na atualização
        print('Usuário com ID $userId atualizado com sucesso!');
        print('Resposta da API: ${response.body}');
        return true;
      } else {
        print('Erro ao atualizar usuário $userId: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exceção ao atualizar usuário $userId: $e');
      return false;
    }
  }
}
