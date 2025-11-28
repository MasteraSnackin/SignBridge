import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import '../../core/utils/logger.dart';
import '../../features/sign_recognition/services/sign_recognition_service.dart';

class SignToSpeechScreen extends StatefulWidget {
  const SignToSpeechScreen({super.key});

  @override
  State<SignToSpeechScreen> createState() => _SignToSpeechScreenState();
}

class _SignToSpeechScreenState extends State<SignToSpeechScreen> {
  late SignRecognitionService _recognitionService;
  bool _isInitializing = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _recognitionService = SignRecognitionService();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      await _recognitionService.initialize();
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    } catch (e) {
      Logger.error('Failed to initialize recognition service', error: e);
      if (mounted) {
        setState(() {
          _isInitializing = false;
          _errorMessage = 'Failed to initialize camera: $e';
        });
      }
    }
  }

  Future<void> _toggleRecognition() async {
    try {
      if (_recognitionService.isProcessing) {
        await _recognitionService.stopRecognition();
      } else {
        await _recognitionService.startRecognition();
      }
      setState(() {});
    } catch (e) {
      Logger.error('Failed to toggle recognition', error: e);
      _showError('Failed to start recognition: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _recognitionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _recognitionService,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Sign to Speech'),
          actions: [
            Consumer<SignRecognitionService>(
              builder: (context, service, child) {
                return IconButton(
                  icon: Icon(service.isProcessing ? Icons.stop : Icons.play_arrow),
                  onPressed: _toggleRecognition,
                  tooltip: service.isProcessing ? 'Stop' : 'Start',
                );
              },
            ),
          ],
        ),
        body: _isInitializing
            ? const Center(child: CircularProgressIndicator())
            : _errorMessage != null
                ? _buildErrorView()
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
                  _isInitializing = true;
                });
                _initializeService();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      children: [
        // Camera preview
        Expanded(
          flex: 3,
          child: _buildCameraPreview(),
        ),
        
        // Recognition results
        Expanded(
          flex: 2,
          child: _buildResultsPanel(),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Consumer<SignRecognitionService>(
      builder: (context, service, child) {
        final controller = service.cameraController;
        
        if (controller == null || !controller.value.isInitialized) {
          return Container(
            color: Colors.black,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        
        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller),
            
            // Overlay with current letter
            if (service.currentLetter.isNotEmpty)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      service.currentLetter,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            
            // Performance metrics
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FPS: ${service.fps}',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      'Latency: ${service.latencyMs}ms',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      'Confidence: ${(service.confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultsPanel() {
    return Consumer<SignRecognitionService>(
      builder: (context, service, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Recognized Text:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      service.assembledText.isEmpty 
                          ? 'Start signing to see text here...' 
                          : service.assembledText,
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: service.assembledText.isEmpty
                          ? null
                          : () => service.clearText(),
                      icon: const Icon(Icons.clear),
                      label: const Text('Clear'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => service.addSpace(),
                      icon: const Icon(Icons.space_bar),
                      label: const Text('Space'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: service.assembledText.isEmpty
                          ? null
                          : () => service.speakText(),
                      icon: const Icon(Icons.volume_up),
                      label: const Text('Speak'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}