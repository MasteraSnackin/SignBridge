import 'package:flutter/material.dart';
import '../../core/services/cactus_model_service.dart';
import '../../data/repositories/sign_dictionary_repository.dart';
import '../../core/utils/logger.dart';
import '../../features/hybrid_routing/widgets/privacy_dashboard.dart';
import '../../features/hybrid_routing/services/hybrid_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final CactusModelService _cactusService = CactusModelService();
  final SignDictionaryRepository _dictionary = SignDictionaryRepository();
  final HybridRouter _hybridRouter = HybridRouter();
  
  bool _isLoading = true;
  Map<String, dynamic> _modelStats = {};
  Map<String, dynamic> _dictionaryStats = {};
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    
    try {
      // Initialize services if needed
      if (!_cactusService.isInitialized) {
        await _cactusService.initialize();
      }
      await _dictionary.initialize();
      
      // Get statistics
      _modelStats = _cactusService.getStatistics();
      _dictionaryStats = _dictionary.getStatistics();
      
      setState(() => _isLoading = false);
    } catch (e) {
      Logger.error('Failed to load statistics', error: e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadStatistics,
          ),
        ],
        bottom: TabBar(
          controller: TabController(length: 2, vsync: Navigator.of(context)),
          onTap: (index) => setState(() => _selectedTab = index),
          tabs: const [
            Tab(icon: Icon(Icons.settings), text: 'General'),
            Tab(icon: Icon(Icons.security), text: 'Privacy'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _selectedTab == 0
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildModelStatusSection(),
                      const SizedBox(height: 16),
                      _buildDictionarySection(),
                      const SizedBox(height: 16),
                      _buildPerformanceSection(),
                      const SizedBox(height: 16),
                      _buildAboutSection(),
                    ],
                  ),
                )
              : const PrivacyDashboard(),
    );
  }

  Widget _buildModelStatusSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.memory, size: 20),
                SizedBox(width: 8),
                Text(
                  'AI Models Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildStatusRow(
              'Vision Model (LFM2-VL-450M)',
              _modelStats['visionModelLoaded'] ?? false,
            ),
            _buildStatusRow(
              'Text Model (Qwen3-0.6B)',
              _modelStats['textModelLoaded'] ?? false,
            ),
            _buildStatusRow(
              'Speech Model (Whisper-Tiny)',
              _modelStats['speechModelLoaded'] ?? false,
            ),
            
            const Divider(height: 24),
            
            _buildInfoRow('Initialization Time', '${_modelStats['initTimeMs'] ?? 0}ms'),
            _buildInfoRow('Total Inferences', '${_modelStats['totalInferences'] ?? 0}'),
            _buildInfoRow('Average Latency', '${_modelStats['averageLatencyMs'] ?? 0}ms'),
            
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              onPressed: _cactusService.isInitialized ? null : () async {
                await _cactusService.initialize();
                _loadStatistics();
              },
              icon: const Icon(Icons.download),
              label: Text(_cactusService.isInitialized 
                  ? 'Models Loaded' 
                  : 'Initialize Models'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDictionarySection() {
    final categories = _dictionaryStats['categories'] as Map<String, dynamic>? ?? {};
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.book, size: 20),
                SizedBox(width: 8),
                Text(
                  'Sign Dictionary',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Total Words', '${_dictionaryStats['totalWords'] ?? 0}'),
            
            const SizedBox(height: 12),
            const Text(
              'Categories:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            ...categories.entries.map((entry) => 
              _buildInfoRow('  ${_capitalize(entry.key)}', '${entry.value}')
            ),
            
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              onPressed: () => _showDictionaryDialog(),
              icon: const Icon(Icons.list),
              label: const Text('View All Words'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.speed, size: 20),
                SizedBox(width: 8),
                Text(
                  'Performance Targets',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildPerformanceRow('Target Latency', '<500ms', Colors.green),
            _buildPerformanceRow('Frame Rate', '10 FPS', Colors.green),
            _buildPerformanceRow('Accuracy Target', '>90%', Colors.green),
            _buildPerformanceRow('Processing', 'On-Device', Colors.blue),
            _buildPerformanceRow('Network Required', 'No', Colors.blue),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green),
              ),
              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'All processing happens on your device. No data is sent to the cloud.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info, size: 20),
                SizedBox(width: 8),
                Text(
                  'About SignBridge',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildInfoRow('Version', '1.0.0'),
            _buildInfoRow('Platform', 'Flutter Android'),
            _buildInfoRow('AI Framework', 'Cactus SDK'),
            _buildInfoRow('Sign Language', 'ASL (American)'),
            
            const SizedBox(height: 16),
            
            const Text(
              'SignBridge provides real-time, fully offline, bidirectional sign language translation using on-device AI.',
              style: TextStyle(fontSize: 14, height: 1.5),
            ),
            
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFeatureChip('Offline', Icons.cloud_off),
                _buildFeatureChip('Real-time', Icons.speed),
                _buildFeatureChip('Private', Icons.lock),
                _buildFeatureChip('Bidirectional', Icons.swap_horiz),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.circle_outlined,
            size: 16,
            color: isActive ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            isActive ? 'Loaded' : 'Not Loaded',
            style: TextStyle(
              color: isActive ? Colors.green : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  void _showDictionaryDialog() {
    final words = _dictionary.getAllWords();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Dictionary (${words.length} words)'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return ListTile(
                dense: true,
                leading: const Icon(Icons.check, size: 16, color: Colors.green),
                title: Text(word),
                trailing: Text(
                  _dictionary.getAnimationPath(word)?.split('/').last ?? '',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[600],
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}