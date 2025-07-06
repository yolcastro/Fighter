import 'dart:convert';
import 'package:http/http.dart' as http;

class UsuarioService {
  static const String baseUrl = 'https://e9f6-187-18-138-85.ngrok-free.app/api/usuarios/';

  /// Cria um novo usuário no backend
  /// Recebe um mapa com os dados do usuário e retorna o UID gerado ou null em caso de erro
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

  /// Atualiza os dados de um usuário existente
  /// Recebe o ID do usuário e um mapa com os campos a serem atualizados
  /// Retorna true se a atualização foi bem-sucedida, false caso contrário
  static Future<bool> atualizarUsuario(String userId, Map<String, dynamic> updateData) async {
    final url = Uri.parse('$baseUrl$userId');

    try {
      final response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(updateData),
      );

      if (response.statusCode == 200) {
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

  /// Busca os dados de um usuário pelo seu ID
  /// Retorna um mapa com os dados do usuário ou null em caso de erro
  static Future<Map<String, dynamic>?> buscarUsuarioPorId(String userId) async {
    final url = Uri.parse('$baseUrl$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Usuário encontrado: $data');
        return data;
      } else {
        print('Erro ao buscar usuário: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exceção ao buscar usuário: $e');
      return null;
    }
  }

  /// Deleta um usuário pelo seu ID
  /// Retorna true se a exclusão foi bem-sucedida, false caso contrário
  static Future<bool> deletarUsuario(String userId) async {
    final url = Uri.parse('$baseUrl$userId');

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print('Usuário com ID $userId deletado com sucesso!');
        return true;
      } else {
        print('Erro ao deletar usuário $userId: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Exceção ao deletar usuário: $e');
      return false;
    }
  }
}

