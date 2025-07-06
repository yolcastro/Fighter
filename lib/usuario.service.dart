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
}
