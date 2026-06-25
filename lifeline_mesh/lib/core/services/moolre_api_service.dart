import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

final moolreApiServiceProvider = Provider<MoolreApiService>((ref) {
  return MoolreApiService();
});

/// A service to interact with Moolre APIs (Collections, SMS, Transact).
class MoolreApiService {
  static const String _liveUrl = 'https://api.moolre.com/v1';
  static const String _sandboxUrl = 'https://sandbox.moolre.com';

  String get _apiUser => dotenv.env['MOOLRE_API_USER'] ?? '';
  String get _apiKey => dotenv.env['MOOLRE_API_KEY'] ?? '';
  String get _vasKey => dotenv.env['MOOLRE_VAS_KEY'] ?? '';
  String get _accountNumber => dotenv.env['MOOLRE_ACCOUNT_NUMBER'] ?? '';
  String get _senderId => dotenv.env['MOOLRE_SENDER_ID'] ?? 'Lifeline';
  String get _whatsappSenderId => dotenv.env['MOOLRE_WHATSAPP_SENDER_ID'] ?? '';

  final _uuid = const Uuid();

  /// Process a payment for an emergency dispatch.
  /// Uses Moolre Transact Payment API.
  Future<bool> processEmergencyPayment({
    required double amount,
    required String phone,
    required String emergencyId,
  }) async {
    return _initiatePayment(
      amount: amount,
      phone: phone,
      reference: 'Emergency Dispatch $emergencyId',
    );
  }

  /// Fund the community emergency pool.
  Future<bool> fundCommunityPool({
    required double amount,
    required String phone,
  }) async {
    return _initiatePayment(
      amount: amount,
      phone: phone,
      reference: 'Community Pool Funding',
    );
  }

  /// Internal helper to initiate a USSD mobile money payment request.
  Future<bool> _initiatePayment({
    required double amount,
    required String phone,
    required String reference,
  }) async {
    try {
      debugPrint('Moolre API: Initiating payment of $amount GHS from $phone ($reference)');

      // Using sandbox environment to avoid real charges during demo/testing
      final url = Uri.parse('$_sandboxUrl/open/transact/payment');

      // For sandbox, API keys aren't strictly required but X-API-USER is.
      final headers = {
        'Content-Type': 'application/json',
        'X-API-USER': _apiUser,
      };

      // Ensure API keys are added if available (required for live)
      if (_apiKey.isNotEmpty) {
        headers['X-API-KEY'] = _apiKey;
      }

      final body = {
        'type': 1,
        'channel': '13', // Example: MTN Mobile Money
        'currency': 'GHS',
        'payer': phone,
        'amount': amount.toStringAsFixed(2),
        'externalref': _uuid.v4(), // Unique reference for tracking
        'reference': reference,
        'accountnumber': _accountNumber,
      };

      final response = await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 || data['status'] == '1') {
          debugPrint('Moolre API: Payment Initiated Successfully (Ref: ${data['data']})');
          return true;
        } else {
          debugPrint('Moolre API: Payment Error: ${data['message']}');
          return false;
        }
      } else {
        debugPrint('Moolre API: HTTP Error ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Moolre API Exception: $e');
      return false;
    }
  }

  /// Send an SMS alert via Moolre SMS API as a fallback when offline.
  Future<bool> sendEmergencySms({
    required String phone,
    required String message,
  }) async {
    try {
      debugPrint('Moolre API: Sending SMS to $phone -> $message');

      // SMS uses the main api domain
      final url = Uri.parse('https://api.moolre.com/open/sms/send');

      final headers = {
        'Content-Type': 'application/json',
        'X-API-USER': _apiUser,
        'X-API-VASKEY': _vasKey,
      };

      final body = {
        'type': 1,
        'senderid': _senderId,
        'messages': [
          {
            'recipient': phone,
            'message': message.length > 160 ? message.substring(0, 160) : message,
          }
        ]
      };

      final response = await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 || data['status'] == '1') {
          debugPrint('Moolre API: SMS Sent Successfully');
          return true;
        } else {
          debugPrint('Moolre API: SMS Error: ${data['message']}');
          return false;
        }
      } else {
        debugPrint('Moolre API: HTTP Error ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Moolre API SMS Exception: $e');
      return false;
    }
  }

  /// Send a WhatsApp alert via Moolre WhatsApp API.
  Future<bool> sendEmergencyWhatsApp({
    required String phone,
    required String message,
  }) async {
    try {
      debugPrint('Moolre API: Sending WhatsApp to $phone -> $message');

      final url = Uri.parse('https://api.moolre.com/open/whatsapp/send');
      final headers = {
        'Content-Type': 'application/json',
        'X-API-USER': _apiUser,
        'X-API-VASKEY': _vasKey,
      };

      final body = {
        'type': 1,
        'senderid': _whatsappSenderId,
        'messages': [
          {
            'recipient': phone,
            'message': message,
          }
        ]
      };

      final response = await http.post(url, headers: headers, body: jsonEncode(body));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 || data['status'] == '1') {
          debugPrint('Moolre API: WhatsApp Sent Successfully');
          return true;
        } else {
          debugPrint('Moolre API: WhatsApp Error: ${data['message']}');
          return false;
        }
      } else {
        debugPrint('Moolre API: HTTP Error ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Moolre API WhatsApp Exception: $e');
      return false;
    }
  }

  /// Check the status of a transaction.
  Future<String> verifyTransactionStatus(String transactionRef) async {
    try {
      final url = Uri.parse('$_sandboxUrl/open/transact/status');
      final headers = {
        'Content-Type': 'application/json',
        'X-API-USER': _apiUser,
      };
      if (_apiKey.isNotEmpty) headers['X-API-KEY'] = _apiKey;

      final body = {
        'type': 1,
        'idtype': '1', // 1 = externalref
        'id': transactionRef,
        'accountnumber': _accountNumber,
      };

      final response = await http.post(url, headers: headers, body: jsonEncode(body));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 1 || data['status'] == '1') {
          return 'SUCCESS';
        }
      }
      return 'PENDING';
    } catch (e) {
      return 'ERROR';
    }
  }
}
