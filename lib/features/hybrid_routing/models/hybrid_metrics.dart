/// Hybrid Routing Metrics
/// 
/// Tracks usage statistics for local vs cloud inference
class HybridMetrics {
  int totalRequests = 0;
  int localRequests = 0;
  int cloudRequests = 0;
  int localSuccesses = 0;
  int cloudSuccesses = 0;
  int localFailures = 0;
  int cloudFailures = 0;
  
  final List<int> localLatencies = [];
  final List<int> cloudLatencies = [];
  
  DateTime? firstRequestTime;
  DateTime? lastRequestTime;
  
  /// Record a local inference request
  void recordLocalRequest({
    required int latencyMs,
    required bool success,
  }) {
    totalRequests++;
    localRequests++;
    
    if (success) {
      localSuccesses++;
      localLatencies.add(latencyMs);
      
      // Keep only last 100 measurements
      if (localLatencies.length > 100) {
        localLatencies.removeAt(0);
      }
    } else {
      localFailures++;
    }
    
    _updateTimestamps();
  }
  
  /// Record a cloud inference request
  void recordCloudRequest({
    required int latencyMs,
    required bool success,
  }) {
    totalRequests++;
    cloudRequests++;
    
    if (success) {
      cloudSuccesses++;
      cloudLatencies.add(latencyMs);
      
      // Keep only last 100 measurements
      if (cloudLatencies.length > 100) {
        cloudLatencies.removeAt(0);
      }
    } else {
      cloudFailures++;
    }
    
    _updateTimestamps();
  }
  
  void _updateTimestamps() {
    final now = DateTime.now();
    firstRequestTime ??= now;
    lastRequestTime = now;
  }
  
  /// Get average local latency in milliseconds
  int get averageLocalLatency {
    if (localLatencies.isEmpty) return 0;
    return localLatencies.reduce((a, b) => a + b) ~/ localLatencies.length;
  }
  
  /// Get average cloud latency in milliseconds
  int get averageCloudLatency {
    if (cloudLatencies.isEmpty) return 0;
    return cloudLatencies.reduce((a, b) => a + b) ~/ cloudLatencies.length;
  }
  
  /// Get percentage of requests handled locally (privacy score)
  double get privacyScore {
    if (totalRequests == 0) return 100.0;
    return (localRequests / totalRequests) * 100.0;
  }
  
  /// Get local success rate
  double get localSuccessRate {
    if (localRequests == 0) return 0.0;
    return (localSuccesses / localRequests) * 100.0;
  }
  
  /// Get cloud success rate
  double get cloudSuccessRate {
    if (cloudRequests == 0) return 0.0;
    return (cloudSuccesses / cloudRequests) * 100.0;
  }
  
  /// Get latency improvement (how much faster local is)
  double get latencyImprovement {
    if (averageCloudLatency == 0) return 0.0;
    return ((averageCloudLatency - averageLocalLatency) / averageCloudLatency) * 100.0;
  }
  
  /// Reset all metrics
  void reset() {
    totalRequests = 0;
    localRequests = 0;
    cloudRequests = 0;
    localSuccesses = 0;
    cloudSuccesses = 0;
    localFailures = 0;
    cloudFailures = 0;
    localLatencies.clear();
    cloudLatencies.clear();
    firstRequestTime = null;
    lastRequestTime = null;
  }
  
  /// Convert to map for serialization
  Map<String, dynamic> toJson() {
    return {
      'totalRequests': totalRequests,
      'localRequests': localRequests,
      'cloudRequests': cloudRequests,
      'localSuccesses': localSuccesses,
      'cloudSuccesses': cloudSuccesses,
      'localFailures': localFailures,
      'cloudFailures': cloudFailures,
      'averageLocalLatency': averageLocalLatency,
      'averageCloudLatency': averageCloudLatency,
      'privacyScore': privacyScore,
      'localSuccessRate': localSuccessRate,
      'cloudSuccessRate': cloudSuccessRate,
      'latencyImprovement': latencyImprovement,
      'firstRequestTime': firstRequestTime?.toIso8601String(),
      'lastRequestTime': lastRequestTime?.toIso8601String(),
    };
  }
}