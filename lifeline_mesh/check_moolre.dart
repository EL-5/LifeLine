import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('Loading .env file...');
  final envFile = File('c:/Users/theop/Downloads/Life Line/lifeline_mesh/.env');
  if (!envFile.existsSync()) {
    print('Error: .env file not found!');
    return;
  }

  final lines = envFile.readAsLinesSync();
  final env = <String, String>{};
  for (var line in lines) {
    if (line.contains('=')) {
      final parts = line.split('=');
      env[parts[0]] = parts.sublist(1).join('=');
    }
  }

  // Notice: The user pasted a key starting with eyJ... containing "vasid". We will test if it works for SMS.
  // We'll also check if the API User is present.
  final apiKey = env['MOOLRE_API_KEY'] ?? '';
  final vasKey = env['MOOLRE_VAS_KEY'] ?? '';
  final apiUser = env['MOOLRE_API_USER'] ?? '';
  final senderId = env['MOOLRE_SENDER_ID'] ?? '';

  print('--- Moolre Credential Check ---');
  print('API USER provided: ${apiUser != 'your_username' && apiUser.isNotEmpty}');
  print('API KEY provided: ${apiKey != 'your_private_key' && apiKey.isNotEmpty}');
  print('VAS KEY provided: ${vasKey != 'your_sms_vas_key' && vasKey.isNotEmpty}');
  print('-------------------------------\n');

  // Let's test the SMS Connection using the key they pasted (we will try it as VASKEY since it has vasid)
  String actualVasKey = vasKey;
  if (apiKey.contains('eyJ2YXNpZCI')) {
    print('⚠️ Notice: It looks like you accidentally pasted the SMS VAS Key into the MOOLRE_API_KEY field!');
    actualVasKey = apiKey; // Try using it as the vas key
  }

  if (actualVasKey != 'your_sms_vas_key' && actualVasKey.isNotEmpty) {
    print('Testing SMS API Connection...');
    final url = Uri.parse('https://api.moolre.com/open/sms/query');
    final headers = {
      'Content-Type': 'application/json',
      'X-API-VASKEY': actualVasKey,
    };
    final body = jsonEncode({
      'type': 2, // Check SMS Account Status (Balance)
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('HTTP Status: ${response.statusCode}');
      print('Response: ${response.body}');
      if (response.statusCode == 200 && jsonDecode(response.body)['status'] == 1) {
        print('✅ SMS API Connection SUCCESSFUL!');
      } else {
        print('❌ SMS API Connection FAILED.');
      }
    } catch (e) {
      print('Exception: $e');
    }
  } else {
    print('Skipping SMS check (No VAS Key found)');
  }

  print('\nTesting Main Transact API Connection...');
  if (apiUser.isNotEmpty && apiKey.isNotEmpty) {
    final url = Uri.parse('https://api.moolre.com/open/account/status');
    final headers = {
      'Content-Type': 'application/json',
      'X-API-USER': apiUser,
      'X-API-KEY': apiKey,
    };
    final body = jsonEncode({
      'type': 1,
      'accountnumber': env['MOOLRE_ACCOUNT_NUMBER'],
    });

    try {
      final response = await http.post(url, headers: headers, body: body);
      print('HTTP Status: ${response.statusCode}');
      print('Response: ${response.body}');
      if (response.statusCode == 200 && jsonDecode(response.body)['status'] == 1) {
        print('✅ Main API Connection SUCCESSFUL!');
      } else {
        print('❌ Main API Connection FAILED.');
      }
    } catch (e) {
      print('Exception: $e');
    }
  } else {
    print('Skipping Main API check (Credentials missing)');
  }
}
