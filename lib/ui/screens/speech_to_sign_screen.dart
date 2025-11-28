import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/speech_recognition/services/speech_recognition_service.dart';
import '../../features/sign_animation/services/sign_animation_service.dart';
import '../../features/sign_animation/widgets/sign_avatar_widget.dart';

class SpeechToSignScreen extends StatefulWidget {
  const SpeechToSignScreen({Key? key}) : super(key: key);

  @override
  State<SpeechToSignScreen> createState() => _SpeechToSignScreenState();
}

class _SpeechToSignScreenState extends State<SpeechToSignScreen> {
  late SpeechRecognitionService _speechService;
  late SignAnimationService _animationService;
  final TextEditingController _textController = TextEditingController();
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _speechService = SpeechRecognitionService();
    _animationService = SignAnimationService();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      await _speechService.initialize();
      await _animationService.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to initialize: $e';
      });
    }
  }

  @override
  void dispose() {
    _speechService.dispose();
    _animationService.dispose();
    _textController.dispose();
    super.dispose();
  }

  Future<void> _startListening() async {
    try {
      await _speechService.startListening();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start listening: $e')),
      );
    }
  }

  Future<void> _stopListening() async {
    await _speechService.stopListening();
    
    // Play animations for transcribed words
    if (_speechService.words.isNotEmpty) {
      await _animationService.playWords(_speechService.words);
    }
  }

  Future<void> _playTextInput() async {
    final text = _textController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter some text')),
      );
      return;
    }

    final words = text.toLowerCase().split(RegExp(r'\s+'));
    await _animationService.playWords(words);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _speechService),
        ChangeNotifierProvider.value(value: _animationService),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Speech to Sign'),
          actions: [
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showInfoDialog(context),
            ),
          ],
        ),
        body: _errorMessage != null
            ? _buildErrorView()
            : !_isInitialized
                ? const Center(child: CircularProgressIndicator())
                : _buildMainView(),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                });
                _initialize();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView() {
    return Consumer2<SpeechRecognitionService, SignAnimationService>(
      builder: (context, speechService, animationService, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Sign Avatar Display
              Center(
                child: SignAvatarWidget(
                  animationService: animationService,
                  size: 320,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Animation Queue
              if (animationService.animationQueue.isNotEmpty)
                AnimationQueueWidget(animationService: animationService),
              
              const SizedBox(height: 24),
              
              // Voice Input Section
              _buildVoiceInputSection(speechService, animationService),
              
              const SizedBox(height: 24),
              
              // Text Input Section
              _buildTextInputSection(animationService),
              
              const SizedBox(height: 24),
              
              // Statistics
              _buildStatistics(speechService, animationService),
            ],
          ),
        );
      },
    );
  }

  Widget _buildVoiceInputSection(
    SpeechRecognitionService speechService,
    SignAnimationService animationService,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.mic, size: 20),
                const SizedBox(width: 8),
                const Text(
                  'Voice Input',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (speechService.isListening)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.circle, size: 8, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'LISTENING',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Transcribed text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                speechService.transcribedText.isEmpty
                    ? 'Tap the microphone to start...'
                    : speechService.transcribedText,
                style: TextStyle(
                  fontSize: 16,
                  color: speechService.transcribedText.isEmpty
                      ? Colors.grey[600]
                      : Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Control buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: speechService.isListening || animationService.isPlaying
                        ? null
                        : _startListening,
                    icon: const Icon(Icons.mic),
                    label: const Text('Start Listening'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: !speechService.isListening || animationService.isPlaying
                        ? null
                        : _stopListening,
                    icon: const Icon(Icons.stop),
                    label: const Text('Stop & Play'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputSection(SignAnimationService animationService) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Row(
              children: [
                Icon(Icons.keyboard, size: 20),
                SizedBox(width: 8),
                Text(
                  'Text Input',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'Type text to convert to sign language...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              enabled: !animationService.isPlaying,
            ),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: animationService.isPlaying ? null : _playTextInput,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Play Signs'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistics(
    SpeechRecognitionService speechService,
    SignAnimationService animationService,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.analytics, size: 20),
                SizedBox(width: 8),
                Text(
                  'Statistics',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            _buildStatRow('Words Displayed', '${animationService.wordsDisplayed}'),
            _buildStatRow('Letters Fingerspelled', '${animationService.lettersFingerSpelled}'),
            _buildStatRow('Total Animations', '${animationService.totalAnimations}'),
            _buildStatRow('Dictionary Size', '${animationService.getStatistics()['dictionarySize']}'),
            
            if (speechService.latencyMs > 0)
              _buildStatRow('Speech Recognition Latency', '${speechService.latencyMs}ms'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[400]),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Speech to Sign'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How to use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Tap "Start Listening" to use voice input'),
              Text('2. Speak clearly into the microphone'),
              Text('3. Tap "Stop & Play" to see the signs'),
              SizedBox(height: 12),
              Text('OR'),
              SizedBox(height: 12),
              Text('1. Type text in the text input field'),
              Text('2. Tap "Play Signs" to see the animation'),
              SizedBox(height: 16),
              Text(
                'Features:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• 150+ common words with sign animations'),
              Text('• Automatic fingerspelling for unknown words'),
              Text('• Real-time animation playback'),
              Text('• Completely offline processing'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}