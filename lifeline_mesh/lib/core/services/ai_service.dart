import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

class AiService {
  // TODO: Replace with Gemini/OpenAI API key
  static const String _apiKey = 'MOCK_AI_API_KEY';
  
  /// Get a first-aid response from the AI assistant.
  Future<String> getFirstAidAdvice(String userQuery) async {
    try {
      debugPrint('AI Service: Generating triage advice for "$userQuery"');
      await Future.delayed(const Duration(seconds: 2));
      
      final queryLower = userQuery.toLowerCase();
      
      if (queryLower.contains('burn')) {
        return "1. Move away from the heat source immediately.\n2. Cool the burn under running cool (not cold) water for at least 10 minutes.\n3. Do NOT apply ice, butter, or ointments.\n4. If the burn is larger than your palm or on the face, trigger a Code Red emergency immediately.";
      } else if (queryLower.contains('bleed') || queryLower.contains('cut')) {
        return "1. Apply direct pressure to the wound using a clean cloth.\n2. Elevate the injured area above the heart if possible.\n3. Do NOT remove the cloth if it soaks through; add another on top.\n4. If bleeding doesn't stop after 10 minutes, trigger a Code Red.";
      } else if (queryLower.contains('chok')) {
        return "1. Stand behind the person and lean them slightly forward.\n2. Give 5 sharp blows between the shoulder blades.\n3. If that fails, perform 5 abdominal thrusts (Heimlich maneuver).\n4. Trigger a Code Red immediately while continuing.";
      } else {
        return "I am an AI First-Aid Assistant. Please describe the injury or symptoms. If this is a life-threatening emergency, please use the SOS button below immediately to dispatch an ambulance.";
      }
      
    } catch (e) {
      return "I'm having trouble connecting right now. If this is an emergency, please use the SOS button below to call for an ambulance.";
    }
  }
}
