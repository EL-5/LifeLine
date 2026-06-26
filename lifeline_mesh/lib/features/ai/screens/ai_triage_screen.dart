import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/colors.dart';
import '../../../core/services/ai_service.dart';

class AiTriageScreen extends ConsumerStatefulWidget {
  const AiTriageScreen({super.key});

  @override
  ConsumerState<AiTriageScreen> createState() => _AiTriageScreenState();
}

class _AiTriageScreenState extends ConsumerState<AiTriageScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SpeechToText _speechToText = SpeechToText();
  
  final List<Map<String, dynamic>> _messages = [
    {
      'role': 'ai',
      'text': 'Hello. I am the Lifeline Mesh AI Dispatcher. Describe your medical emergency, and I will guide you with immediate first-aid while help arrives.',
    }
  ];
  
  bool _isLoading = false;
  bool _isSpeaking = false;
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    _initAudio();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _audioPlayer.stop();
    await _speechToText.listen(onResult: (result) {
      setState(() {
        _controller.text = result.recognizedWords;
      });
    });
    setState(() {
      _isListening = true;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
    // Auto send if words were captured
    if (_controller.text.isNotEmpty) {
      _sendMessage();
    }
  }

  Future<void> _initAudio() async {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          _isSpeaking = state == PlayerState.playing;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await _audioPlayer.stop();

    setState(() {
      _messages.add({'role': 'user', 'text': text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    final aiService = ref.read(aiServiceProvider);
    String response = await aiService.getFirstAidAdvice(text);

    bool triggerSos = false;
    if (response.contains('[TRIGGER_SOS]')) {
      triggerSos = true;
      response = response.replaceAll('[TRIGGER_SOS]', '').trim();
    }

    // Generate and start playing the audio FIRST, so they perfectly sync!
    await aiService.speak(response);

    if (mounted) {
      setState(() {
        _messages.add({'role': 'ai', 'text': response});
        _isLoading = false;
      });
      _scrollToBottom();

      if (triggerSos) {
        // Wait for the speech to start before navigating
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) context.push('/user/sos');
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0D1117), Color(0xFF090C10)],
        ),
      ),
      child: Column(
        children: [
          // Optional Header for Voice Indication
          if (_isSpeaking)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              color: AppColors.trustBlue.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.volume_up_rounded, color: AppColors.trustBlue, size: 20)
                      .animate(onPlay: (c) => c.repeat())
                      .fade(duration: 500.ms),
                  const SizedBox(width: 8),
                  Text('AI is speaking...', style: TextStyle(color: AppColors.trustBlue.withOpacity(0.8), fontSize: 12)),
                ],
              ),
            ),
            
          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isLoading ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) {
                  return _buildTypingIndicator();
                }
                
                final msg = _messages[index];
                final isUser = msg['role'] == 'user';
                
                return _buildMessageBubble(msg['text'], isUser);
              },
            ),
          ),
          
          // Input Area
          ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF161B22).withOpacity(0.7),
                  border: const Border(top: BorderSide(color: Colors.white10)),
                ),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: const TextStyle(color: Colors.white),
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Describe the emergency...',
                            hintStyle: const TextStyle(color: Colors.white30),
                            filled: true,
                            fillColor: const Color(0xFF0D1117).withOpacity(0.8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
                          onSubmitted: (_) => _sendMessage(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onLongPressStart: (_) => _startListening(),
                        onLongPressEnd: (_) => _stopListening(),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: _isListening ? AppColors.emergencyRed : AppColors.trustBlue.withOpacity(0.2),
                          child: Icon(
                            _isListening ? Icons.mic : Icons.mic_none, 
                            color: _isListening ? Colors.white : AppColors.trustBlue,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppColors.trustBlue,
                        child: IconButton(
                          icon: const Icon(Icons.send_rounded, color: Colors.white),
                          onPressed: () {
                            if (_controller.text.isNotEmpty) _sendMessage();
                          },
                        ),
                      ),
                      ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20).copyWith(
          bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(20),
          bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(20),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
            decoration: BoxDecoration(
              gradient: isUser 
                  ? LinearGradient(colors: [AppColors.trustBlue, AppColors.trustBlue.withOpacity(0.8)])
                  : LinearGradient(colors: [const Color(0xFF1E2430), const Color(0xFF161B22)]),
              border: isUser ? null : Border.all(color: Colors.white10),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : Colors.white.withOpacity(0.9),
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ),
        ),
      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF161B22).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20).copyWith(bottomLeft: const Radius.circular(4)),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dot(0),
            const SizedBox(width: 6),
            _dot(200),
            const SizedBox(width: 6),
            _dot(400),
          ],
        ),
      ),
    );
  }

  Widget _dot(int delayMs) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.trustBlue,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.trustBlue.withOpacity(0.5), blurRadius: 4, spreadRadius: 1)
        ]
      ),
    ).animate(onPlay: (c) => c.repeat()).fade(duration: 600.ms).scale(begin: const Offset(0.8, 0.8), end: const Offset(1.2, 1.2), delay: delayMs.ms);
  }
}
