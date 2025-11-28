import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/hybrid_router.dart';
import '../models/hybrid_metrics.dart';

/// Privacy Dashboard Widget
/// 
/// Displays transparency information about hybrid routing:
/// - Local vs Cloud usage statistics
/// - Latency comparisons
/// - Privacy score
/// - User controls
class PrivacyDashboard extends StatelessWidget {
  const PrivacyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: HybridRouter(),
      child: Consumer<HybridRouter>(
        builder: (context, router, child) {
          final metrics = router.metrics;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 24),
                _buildPrivacyScore(context, metrics),
                const SizedBox(height: 24),
                _buildUsageChart(context, metrics),
                const SizedBox(height: 24),
                _buildLatencyComparison(context, metrics),
                const SizedBox(height: 24),
                _buildDetailedStats(context, metrics),
                const SizedBox(height: 24),
                _buildControls(context, router),
              ],
            ),
          );
        },
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.security,
              size: 32,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              'Privacy Dashboard',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Transparency report for hybrid inference routing',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildPrivacyScore(BuildContext context, HybridMetrics metrics) {
    final score = metrics.privacyScore;
    final color = _getScoreColor(score);
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Privacy Score',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${score.toStringAsFixed(1)}%',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    Text(
                      'Local Processing',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _getScoreDescription(score),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildUsageChart(BuildContext context, HybridMetrics metrics) {
    final total = metrics.totalRequests;
    final local = metrics.localRequests;
    final cloud = metrics.cloudRequests;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Inference Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            if (total > 0) ...[
              Row(
                children: [
                  Expanded(
                    flex: local,
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(8),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$local',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (cloud > 0)
                    Expanded(
                      flex: cloud,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: const BorderRadius.horizontal(
                            right: Radius.circular(8),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$cloud',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem(
                    context,
                    'Local',
                    Colors.green,
                    local,
                    (local / total * 100).toStringAsFixed(1),
                  ),
                  _buildLegendItem(
                    context,
                    'Cloud',
                    Colors.orange,
                    cloud,
                    (cloud / total * 100).toStringAsFixed(1),
                  ),
                ],
              ),
            ] else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'No data yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    int count,
    String percentage,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '$count ($percentage%)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
  
  Widget _buildLatencyComparison(BuildContext context, HybridMetrics metrics) {
    final localLatency = metrics.averageLocalLatency;
    final cloudLatency = metrics.averageCloudLatency;
    final improvement = metrics.latencyImprovement;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Latency Comparison',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            _buildLatencyBar(context, 'Local', localLatency, Colors.green),
            const SizedBox(height: 12),
            _buildLatencyBar(context, 'Cloud', cloudLatency, Colors.orange),
            if (improvement > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.speed, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Local is ${improvement.toStringAsFixed(1)}% faster',
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Widget _buildLatencyBar(
    BuildContext context,
    String label,
    int latency,
    Color color,
  ) {
    final maxLatency = 1000; // 1 second max for visualization
    final percentage = (latency / maxLatency).clamp(0.0, 1.0);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              '${latency}ms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDetailedStats(BuildContext context, HybridMetrics metrics) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detailed Statistics',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildStatRow(context, 'Total Requests', metrics.totalRequests.toString()),
            _buildStatRow(context, 'Local Success Rate', '${metrics.localSuccessRate.toStringAsFixed(1)}%'),
            _buildStatRow(context, 'Cloud Success Rate', '${metrics.cloudSuccessRate.toStringAsFixed(1)}%'),
            if (metrics.firstRequestTime != null)
              _buildStatRow(
                context,
                'First Request',
                _formatDateTime(metrics.firstRequestTime!),
              ),
            if (metrics.lastRequestTime != null)
              _buildStatRow(
                context,
                'Last Request',
                _formatDateTime(metrics.lastRequestTime!),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildControls(BuildContext context, HybridRouter router) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Controls',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Enable Hybrid Mode'),
              subtitle: const Text('Allow cloud fallback for low confidence'),
              value: router.hybridModeEnabled,
              onChanged: (value) => router.setHybridMode(value),
            ),
            const Divider(),
            ListTile(
              title: const Text('Confidence Threshold'),
              subtitle: Text('${(router.confidenceThreshold * 100).toStringAsFixed(0)}%'),
              trailing: SizedBox(
                width: 200,
                child: Slider(
                  value: router.confidenceThreshold,
                  min: 0.5,
                  max: 0.95,
                  divisions: 9,
                  label: '${(router.confidenceThreshold * 100).toStringAsFixed(0)}%',
                  onChanged: (value) => router.setConfidenceThreshold(value),
                ),
              ),
            ),
            const Divider(),
            SwitchListTile(
              title: const Text('Prefer Local'),
              subtitle: const Text('Use local even if cloud might be better'),
              value: router.preferLocal,
              onChanged: (value) => router.setPreferLocal(value),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  router.resetMetrics();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Metrics reset')),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reset Metrics'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 75) return Colors.lightGreen;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
  
  String _getScoreDescription(double score) {
    if (score >= 90) return 'Excellent privacy! Almost all processing is local.';
    if (score >= 75) return 'Good privacy. Most processing stays on your device.';
    if (score >= 50) return 'Moderate privacy. Consider enabling "Prefer Local".';
    return 'Low privacy. Most requests are sent to cloud.';
  }
  
  String _formatDateTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}