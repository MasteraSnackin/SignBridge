import 'package:flutter/material.dart';
import '../services/sign_animation_service.dart';

/// Widget to display sign language animations
class SignAvatarWidget extends StatelessWidget {
  final SignAnimationService animationService;
  final double size;
  
  const SignAvatarWidget({
    Key? key,
    required this.animationService,
    this.size = 300,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final currentStep = animationService.getCurrentStep();
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: animationService.isPlaying 
              ? Theme.of(context).colorScheme.primary
              : Colors.grey[700]!,
          width: 3,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(17),
        child: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.grey[850]!,
                    Colors.grey[900]!,
                  ],
                ),
              ),
            ),
            
            // Animation display
            Center(
              child: _buildAnimationContent(context, currentStep),
            ),
            
            // Progress indicator
            if (animationService.isPlaying)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: animationService.progress,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            
            // Status overlay
            if (!animationService.isPlaying && currentStep == null)
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.sign_language,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ready to display signs',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
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
  
  Widget _buildAnimationContent(BuildContext context, AnimationStep? step) {
    if (step == null) {
      return const SizedBox.shrink();
    }
    
    // TODO: Replace with actual Lottie animation or image display
    // For now, show text representation
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animation type indicator
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: step.type == 'word' 
                ? Colors.blue[700]
                : Colors.orange[700],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            step.type == 'word' ? 'WORD' : 'LETTER',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Content display
        if (step.type != 'pause')
          Text(
            step.content.toUpperCase(),
            style: TextStyle(
              color: Colors.white,
              fontSize: step.type == 'word' ? 48 : 72,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        
        const SizedBox(height: 16),
        
        // Animation placeholder
        if (step.type != 'pause')
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.animation,
                    size: 60,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Animation',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    step.animationPath?.split('/').last ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        
        // Step counter
        const SizedBox(height: 16),
        Text(
          'Step ${animationService.currentStepIndex + 1} / ${animationService.animationQueue.length}',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

/// Widget to display animation queue
class AnimationQueueWidget extends StatelessWidget {
  final SignAnimationService animationService;
  
  const AnimationQueueWidget({
    Key? key,
    required this.animationService,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final queue = animationService.animationQueue;
    
    if (queue.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.queue_music,
                color: Colors.grey[400],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Animation Queue',
                style: TextStyle(
                  color: Colors.grey[300],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${queue.length} steps',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: queue.length,
              itemBuilder: (context, index) {
                final step = queue[index];
                final isCurrent = index == animationService.currentStepIndex;
                final isPast = index < animationService.currentStepIndex;
                
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Theme.of(context).colorScheme.primary
                        : isPast
                            ? Colors.grey[700]
                            : Colors.grey[800],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        step.type == 'pause' ? '⏸' : step.content.toUpperCase(),
                        style: TextStyle(
                          color: isCurrent ? Colors.white : Colors.grey[400],
                          fontSize: 16,
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step.type,
                        style: TextStyle(
                          color: isCurrent ? Colors.white70 : Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}