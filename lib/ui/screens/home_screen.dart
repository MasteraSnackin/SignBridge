import 'package:flutter/material.dart';
import '../../core/models/enums.dart';
import '../../core/services/permission_service.dart';
import '../../core/utils/logger.dart';
import 'sign_to_speech_screen.dart';
import 'speech_to_sign_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PermissionService _permissionService = PermissionService();
  bool _isCheckingPermissions = false;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    setState(() => _isCheckingPermissions = true);
    
    final hasPermissions = await _permissionService.hasAllPermissions();
    
    if (!hasPermissions && mounted) {
      _showPermissionDialog();
    }
    
    setState(() => _isCheckingPermissions = false);
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Required'),
        content: const Text(
          'SignBridge needs camera and microphone permissions to function properly. '
          'Please grant these permissions to continue.',
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final results = await _permissionService.requestAllPermissions();
              
              if (!results['camera']! || !results['microphone']!) {
                _showPermissionDeniedDialog();
              }
            },
            child: const Text('Grant Permissions'),
          ),
        ],
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permissions Denied'),
        content: const Text(
          'Some permissions were denied. You can grant them in app settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _permissionService.openSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _navigateToMode(TranslationMode mode) async {
    Logger.info('Navigating to ${mode.displayName}');
    
    // Check permissions before navigating
    final hasPermissions = await _permissionService.hasAllPermissions();
    
    if (!hasPermissions && mounted) {
      _showPermissionDialog();
      return;
    }
    
    if (!mounted) return;
    
    final screen = mode == TranslationMode.signToSpeech
        ? const SignToSpeechScreen()
        : const SpeechToSignScreen();
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SignBridge'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Logger.info('Navigating to Settings');
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _isCheckingPermissions
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 24),
                    const Icon(
                      Icons.sign_language,
                      size: 100,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Choose Translation Mode',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 48),
                    _ModeCard(
                      mode: TranslationMode.signToSpeech,
                      icon: Icons.videocam,
                      onTap: () => _navigateToMode(TranslationMode.signToSpeech),
                    ),
                    const SizedBox(height: 24),
                    _ModeCard(
                      mode: TranslationMode.speechToSign,
                      icon: Icons.mic,
                      onTap: () => _navigateToMode(TranslationMode.speechToSign),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  final TranslationMode mode;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeCard({
    required this.mode,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Icon(
                icon,
                size: 64,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                mode.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                mode.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}