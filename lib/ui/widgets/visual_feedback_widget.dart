import 'package:flutter/material.dart';

/// Enhanced visual feedback widget for recognition results
/// Designed for deaf users who rely on visual cues
class VisualFeedbackWidget extends StatelessWidget {
  final String recognizedText;
  final double confidence;
  final bool isActive;

  const VisualFeedbackWidget({
    super.key,
    required this.recognizedText,
    required this.confidence,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getConfidenceColor(confidence),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Large, high-contrast text
          Text(
            recognizedText.isEmpty ? 'Waiting for sign...' : recognizedText,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 1.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            textAlign: TextAlign.center,
          ),
          
          if (recognizedText.isNotEmpty) ...[
            const SizedBox(height: 16),
            
            // Confidence indicator
            Column(
              children: [
                LinearProgressIndicator(
                  value: confidence,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getConfidenceLabel(confidence),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${(confidence * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green.shade600;
    if (confidence > 0.6) return Colors.orange.shade600;
    if (confidence > 0.4) return Colors.deepOrange.shade600;
    return Colors.red.shade600;
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence > 0.8) return 'Excellent';
    if (confidence > 0.6) return 'Good';
    if (confidence > 0.4) return 'Fair';
    return 'Poor';
  }
}

/// Compact confidence indicator for smaller spaces
class ConfidenceIndicator extends StatelessWidget {
  final double confidence;
  final double size;

  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getConfidenceColor(confidence),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          '${(confidence * 100).toInt()}',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence > 0.8) return Colors.green;
    if (confidence > 0.6) return Colors.orange;
    return Colors.red;
  }
}

/// Animated recognition status indicator
class RecognitionStatusIndicator extends StatefulWidget {
  final bool isRecognizing;
  final String status;

  const RecognitionStatusIndicator({
    super.key,
    required this.isRecognizing,
    required this.status,
  });

  @override
  State<RecognitionStatusIndicator> createState() => _RecognitionStatusIndicatorState();
}

class _RecognitionStatusIndicatorState extends State<RecognitionStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    if (widget.isRecognizing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RecognitionStatusIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isRecognizing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isRecognizing && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: widget.isRecognizing ? Colors.blue.shade700 : Colors.grey.shade700,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.isRecognizing)
            RotationTransition(
              turns: _controller,
              child: const Icon(
                Icons.refresh,
                color: Colors.white,
                size: 16,
              ),
            )
          else
            Icon(
              widget.status == 'Ready' ? Icons.check_circle : Icons.error,
              color: Colors.white,
              size: 16,
            ),
          const SizedBox(width: 8),
          Text(
            widget.status,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}