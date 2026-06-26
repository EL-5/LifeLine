import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/medical_profile_provider.dart';

final aiServiceProvider = Provider<AiService>((ref) {
  return AiService();
});

class AiService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  String get _apiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
  
  GenerativeModel? get _triageModel {
    if (_apiKey.isEmpty || _apiKey == 'your_gemini_api_key') return null;
    return GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system('You are an expert, highly trained emergency medical dispatcher for Lifeline Mesh. Keep responses extremely concise (under 3 sentences). Provide immediate, life-saving first-aid instructions. If the user asks you to call an ambulance, trigger an SOS, or if the situation is imminently life-threatening, include the exact string [TRIGGER_SOS] at the very end of your response.'),
    );
  }

  GenerativeModel? get _healthSpecialistModel {
    if (_apiKey.isEmpty || _apiKey == 'your_gemini_api_key') return null;
    return GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system("You are an expert preventative health specialist and physician for Lifeline Mesh. Analyze the user's health profile (blood type, genotype, allergies, conditions) and provide a structured, personalized wellness plan including dietary advice, sleep recommendations, and specific health risks to monitor. Use markdown formatting with clear headings and bullet points."),
    );
  }

  /// Get a first-aid text response from the AI assistant.
  Future<String> getFirstAidAdvice(String userQuery, {MedicalProfile? medicalProfile, String language = 'English'}) async {
    try {
      debugPrint('AI Service: Generating triage advice for "$userQuery" in $language');
      
      final model = _triageModel;
      if (model == null) {
        return "⚠️ Gemini API Key not configured. Please add it to your .env file to enable Real AI Triage.";
      }

      String prompt = userQuery;
      if (medicalProfile != null) {
        prompt = '''
${medicalProfile.toAiPromptFormat()}

User's Current Symptoms/Query:
"$userQuery"

Please provide triage and first-aid advice taking the above medical profile into account. If they have allergies or conditions relevant to the symptoms, highlight them.

IMPORTANT INSTRUCTION: You MUST reply entirely in $language.
''';
      } else {
        prompt = '''
User's Current Symptoms/Query:
"$userQuery"

IMPORTANT INSTRUCTION: You MUST reply entirely in $language.
''';
      }

      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      
      return response.text ?? "I'm having trouble understanding. Please use the SOS button immediately if this is an emergency.";
    } catch (e) {
      debugPrint('Gemini Exception: $e');
      return "I'm having trouble connecting to the AI network right now. If this is an emergency, please use the SOS button below to call for an ambulance.";
    }
  }

  Uint8List _createWavHeader(int dataLength, int sampleRate) {
    final header = ByteData(44);
    header.setUint32(0, 0x52494646, Endian.big); // "RIFF"
    header.setUint32(4, 36 + dataLength, Endian.little);
    header.setUint32(8, 0x57415645, Endian.big); // "WAVE"
    header.setUint32(12, 0x666D7420, Endian.big); // "fmt "
    header.setUint32(16, 16, Endian.little); // chunk size
    header.setUint16(20, 1, Endian.little); // PCM
    header.setUint16(22, 1, Endian.little); // Channels (1)
    header.setUint32(24, sampleRate, Endian.little); // Sample rate
    header.setUint32(28, sampleRate * 2, Endian.little); // Byte rate
    header.setUint16(32, 2, Endian.little); // Block align
    header.setUint16(34, 16, Endian.little); // Bits per sample
    header.setUint32(36, 0x64617461, Endian.big); // "data"
    header.setUint32(40, dataLength, Endian.little);
    return header.buffer.asUint8List();
  }



  /// Synthesize text to speech using Gemini and play it
  Future<void> speak(String text) async {
    try {
      await _audioPlayer.stop();
      if (_apiKey.isEmpty || _apiKey == 'your_gemini_api_key') return;

      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-preview-tts:generateContent?key=$_apiKey');
      
      final body = jsonEncode({
        "contents": [
          {"role": "user", "parts": [{"text": text}]}
        ],
        "generationConfig": {
          "responseModalities": ["AUDIO"]
        }
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body);
      final parts = data['candidates'][0]['content']['parts'] as List;
      
      for (var part in parts) {
        if (part.containsKey('inlineData')) {
          final inlineData = part['inlineData'];
          if (inlineData['mimeType'].startsWith('audio/L16')) {
            final base64String = inlineData['data'] as String;
            final rawPcmBytes = base64Decode(base64String);
            final wavHeader = _createWavHeader(rawPcmBytes.length, 24000);
            
            final audioData = Uint8List(wavHeader.length + rawPcmBytes.length);
            audioData.setAll(0, wavHeader);
            audioData.setAll(wavHeader.length, rawPcmBytes);
            
            await _audioPlayer.play(BytesSource(audioData));
            break;
          }
        }
      }
    } catch (e) {
      debugPrint('Gemini Speak Exception: $e');
    }
  }
  
  /// Stop playback
  Future<void> stop() async {
    await _audioPlayer.stop();
  }

  /// Get a personalized wellness plan based on user health profile.
  Future<String> getWellnessPlan({
    required String bloodGroup,
    required String genotype,
    required String allergies,
    required String conditions,
  }) async {
    try {
      debugPrint('AI Service: Generating wellness plan');
      
      final model = _healthSpecialistModel;
      if (model == null) {
        return "⚠️ Gemini API Key not configured. Please add it to your .env file to enable the AI Health Specialist.";
      }

      final query = '''
Please generate a comprehensive wellness plan for a user with the following profile:
- Blood Group: $bloodGroup
- Genotype: $genotype
- Allergies: ${allergies.isEmpty ? 'None' : allergies}
- Chronic Conditions: ${conditions.isEmpty ? 'None' : conditions}

Provide actionable advice for:
1. Optimal Diet & Nutrition
2. Exercise & Sleep Habits
3. Preventative Care & Risks to Monitor
''';

      final content = [Content.text(query)];
      final response = await model.generateContent(content);
      
      return response.text ?? "Unable to generate wellness plan at this time.";
    } catch (e) {
      debugPrint('Gemini Exception: $e');
      return "Unable to connect to the AI Health Specialist network.";
    }
  }
}
