# Cactus SDK Optimization Guide for SignBridge

**Date:** 2025-11-28  
**Purpose:** Optimize SignBridge's Cactus SDK integration based on official documentation  
**Status:** 🎯 **ACTIONABLE IMPROVEMENTS IDENTIFIED**

---

## 📊 CURRENT IMPLEMENTATION ANALYSIS

### What We're Using Now ✅
```dart
// Current implementation in cactus_model_service.dart
- CactusSTT (Whisper-Tiny) ✅ Correct
- CactusLM (Qwen3-0.6B) ✅ Correct
- Google ML Kit (Pose Detection) ✅ Fallback for vision
```

### What We Can Improve 🎯

---

## 🚀 OPTIMIZATION #1: Proper STT Implementation

### Current Issue
Our `SpeechRecognitionService` has a placeholder implementation:

```dart
// CURRENT (lib/features/speech_recognition/services/speech_recognition_service.dart)
Future<void> _processAudio(List<int> audioData) async {
  // TODO: Replace with actual audio capture
  final text = await _cactusService.transcribeAudio(audioData);
}
```

### Recommended Fix
According to the docs, `CactusSTT.transcribe()` handles audio capture automatically:

```dart
// IMPROVED IMPLEMENTATION
Future<void> startListening() async {
  _isListening = true;
  notifyListeners();
  
  // Cactus STT handles recording automatically!
  final result = await _cactusService.sttModel?.transcribe();
  
  if (result != null && result.success) {
    _transcribedText = result.text;
    _words = _tokenizeText(result.text);
    _confidence = 0.90; // STT is typically high confidence
    Logger.info('Transcribed: "${result.text}"');
    notifyListeners();
  }
  
  _isListening = false;
  notifyListeners();
}
```

**Benefits:**
- ✅ Removes placeholder simulation
- ✅ Uses real microphone capture
- ✅ Automatic audio handling
- ✅ Better error handling

---

## 🚀 OPTIMIZATION #2: Add Progress Callbacks

### Current Issue
Model downloads don't show progress to users.

### Recommended Fix

```dart
// IMPROVED: lib/core/services/cactus_model_service.dart
Future<void> _downloadModels(Function(double)? onProgress) async {
  Logger.info('Downloading AI models...');
  
  try {
    // Download Speech-to-Text model with progress
    Logger.info('Downloading Whisper-Tiny...');
    final stt = CactusSTT();
    await stt.download(
      model: "whisper-tiny",
      downloadProcessCallback: (progress, status, isError) {
        if (isError) {
          Logger.error('Download error: $status');
        } else {
          Logger.info('$status ${progress != null ? '(${(progress * 100).toStringAsFixed(1)}%)' : ''}');
          onProgress?.call(progress ?? 0.0);
        }
      },
    );
    
    // Download Text model with progress
    Logger.info('Downloading Qwen3-0.6B...');
    final lm = CactusLM();
    await lm.downloadModel(
      model: "qwen3-0.6",
      downloadProcessCallback: (progress, status, isError) {
        if (isError) {
          Logger.error('Download error: $status');
        } else {
          Logger.info('$status ${progress != null ? '(${(progress * 100).toStringAsFixed(1)}%)' : ''}');
          onProgress?.call(0.5 + (progress ?? 0.0) * 0.5);
        }
      },
    );
    
    Logger.success('All models downloaded');
  } catch (e, stackTrace) {
    Logger.error('Failed to download models', error: e, stackTrace: stackTrace);
    rethrow;
  }
}
```

**Benefits:**
- ✅ Real-time download progress
- ✅ Better user experience
- ✅ Error visibility
- ✅ Status messages

---

## 🚀 OPTIMIZATION #3: Add Vision Model Support

### Current Limitation
We're using Google ML Kit as a fallback because Cactus SDK documentation didn't show vision models initially.

### Recommended Enhancement
According to the docs, Cactus SDK now supports vision with `lfm2-vl-450m`:

```dart
// NEW: Add vision model support
Future<void> _initializeVisionModel() async {
  Logger.info('Initializing LFM2-VL-450M vision model...');
  
  try {
    _visionModel = CactusLM();
    await _visionModel!.downloadModel(
      model: "lfm2-vl-450m",
      downloadProcessCallback: (progress, status, isError) {
        Logger.info('Vision model: $status ${progress != null ? '(${(progress * 100).toStringAsFixed(1)}%)' : ''}');
      },
    );
    await _visionModel!.initializeModel(
      params: CactusInitParams(model: 'lfm2-vl-450m')
    );
    _visionModelLoaded = true;
    
    Logger.success('Vision model initialized (Cactus SDK LFM2-VL-450M)');
  } catch (e, stackTrace) {
    Logger.error('Failed to initialize vision model', error: e, stackTrace: stackTrace);
    // Fall back to Google ML Kit
    await _initializeHandDetection();
  }
}

// Use vision model for hand detection
Future<HandLandmarks?> detectHandLandmarksWithVision(CameraImage imageData) async {
  if (_visionModel == null) {
    return await detectHandLandmarks(imageData); // Fallback to ML Kit
  }
  
  try {
    // Convert CameraImage to file path (save temporarily)
    final imagePath = await _saveCameraImageToFile(imageData);
    
    // Use Cactus vision model
    final result = await _visionModel!.generateCompletion(
      messages: [
        ChatMessage(
          content: 'Detect hand landmarks in this image. Return 21 3D coordinates.',
          role: "user",
          images: [imagePath]
        )
      ],
      params: CactusCompletionParams(maxTokens: 500)
    );
    
    if (result.success) {
      // Parse response to extract landmarks
      return _parseHandLandmarksFromResponse(result.response);
    }
  } catch (e) {
    Logger.error('Vision model failed, using fallback', error: e);
  }
  
  return await detectHandLandmarks(imageData); // Fallback
}
```

**Benefits:**
- ✅ Native Cactus SDK vision support
- ✅ Better accuracy potential
- ✅ Unified SDK usage
- ✅ Graceful fallback to ML Kit

---

## 🚀 OPTIMIZATION #4: Add Model Management UI

### Recommended Addition
Create a model management screen for users:

```dart
// NEW: lib/ui/screens/model_management_screen.dart
class ModelManagementScreen extends StatefulWidget {
  const ModelManagementScreen({Key? key}) : super(key: key);

  @override
  State<ModelManagementScreen> createState() => _ModelManagementScreenState();
}

class _ModelManagementScreenState extends State<ModelManagementScreen> {
  final CactusLM _lm = CactusLM();
  List<CactusModel> _models = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() => _isLoading = true);
    
    try {
      final models = await _lm.getModels();
      setState(() {
        _models = models;
        _isLoading = false;
      });
    } catch (e) {
      Logger.error('Failed to load models', error: e);
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadModels,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _models.length,
              itemBuilder: (context, index) {
                final model = _models[index];
                return ListTile(
                  leading: Icon(
                    model.isDownloaded ? Icons.check_circle : Icons.cloud_download,
                    color: model.isDownloaded ? Colors.green : Colors.grey,
                  ),
                  title: Text(model.name),
                  subtitle: Text(
                    '${model.sizeMb} MB • ${model.slug}\n'
                    'Tool Calling: ${model.supportsToolCalling ? "Yes" : "No"} • '
                    'Vision: ${model.supportsVision ? "Yes" : "No"}',
                  ),
                  trailing: model.isDownloaded
                      ? const Icon(Icons.done)
                      : ElevatedButton(
                          onPressed: () => _downloadModel(model),
                          child: const Text('Download'),
                        ),
                );
              },
            ),
    );
  }

  Future<void> _downloadModel(CactusModel model) async {
    // Show download progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Downloading ${model.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('${model.sizeMb} MB'),
          ],
        ),
      ),
    );

    try {
      await _lm.downloadModel(
        model: model.slug,
        downloadProcessCallback: (progress, status, isError) {
          Logger.info('$status ${progress != null ? '(${(progress * 100).toStringAsFixed(1)}%)' : ''}');
        },
      );
      
      Navigator.pop(context);
      _loadModels(); // Refresh list
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${model.name} downloaded successfully')),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }
}
```

**Benefits:**
- ✅ User can see available models
- ✅ Download models on demand
- ✅ Check download status
- ✅ Model capabilities visible

---

## 🚀 OPTIMIZATION #5: Add Streaming Support

### Current Limitation
We only use non-streaming completions.

### Recommended Enhancement

```dart
// NEW: Add streaming support for better UX
Future<void> processTextWithStreaming(String input) async {
  if (!_isInitialized || _lmModel == null) {
    Logger.warning('Text model not initialized');
    return;
  }
  
  try {
    final startTime = DateTime.now();
    
    // Use streaming for real-time output
    final streamedResult = await _lmModel!.generateCompletionStream(
      messages: [ChatMessage(content: input, role: "user")],
    );
    
    // Process chunks as they arrive
    String fullResponse = '';
    await for (final chunk in streamedResult.stream) {
      fullResponse += chunk;
      // Update UI in real-time
      Logger.debug('Chunk: $chunk');
    }
    
    // Get final result with metrics
    final finalResult = await streamedResult.result;
    
    final latency = DateTime.now().difference(startTime).inMilliseconds;
    _updateStatistics(latency);
    
    Logger.info('Streaming complete: ${finalResult.tokensPerSecond} tokens/sec');
    return fullResponse;
  } catch (e, stackTrace) {
    Logger.error('Failed to process text with streaming', error: e, stackTrace: stackTrace);
    return null;
  }
}
```

**Benefits:**
- ✅ Real-time text generation
- ✅ Better perceived performance
- ✅ Responsive UI
- ✅ Token-by-token output

---

## 🚀 OPTIMIZATION #6: Add Embeddings Support

### New Capability
Cactus SDK supports embeddings for semantic search:

```dart
// NEW: Add embedding generation
Future<List<double>?> generateEmbedding(String text) async {
  if (!_isInitialized || _lmModel == null) {
    Logger.warning('Text model not initialized');
    return null;
  }
  
  try {
    final result = await _lmModel!.generateEmbedding(text: text);
    
    if (result.success) {
      Logger.info('Generated ${result.dimension}-dimensional embedding');
      return result.embeddings;
    }
  } catch (e, stackTrace) {
    Logger.error('Failed to generate embedding', error: e, stackTrace: stackTrace);
  }
  
  return null;
}

// Use case: Find similar signs
Future<List<String>> findSimilarSigns(String query) async {
  final queryEmbedding = await generateEmbedding(query);
  if (queryEmbedding == null) return [];
  
  // Compare with sign embeddings in dictionary
  // Return most similar signs
}
```

**Benefits:**
- ✅ Semantic search capability
- ✅ Find similar signs
- ✅ Better word matching
- ✅ Context understanding

---

## 🚀 OPTIMIZATION #7: Add RAG Support (Future)

### Future Enhancement
For expanding the sign dictionary dynamically:

```dart
// FUTURE: Add RAG for dynamic sign learning
class SignRAGService {
  final CactusRAG _rag = CactusRAG();
  final CactusLM _lm = CactusLM();
  
  Future<void> initialize() async {
    await _rag.initialize();
    
    // Set embedding generator
    _rag.setEmbeddingGenerator((text) async {
      final result = await _lm.generateEmbedding(text: text);
      return result.embeddings;
    });
    
    // Configure chunking for sign descriptions
    _rag.setChunking(chunkSize: 256, chunkOverlap: 32);
  }
  
  Future<void> storeSignDescription(String sign, String description) async {
    await _rag.storeDocument(
      fileName: '$sign.txt',
      filePath: '/signs/$sign.txt',
      content: description,
      fileSize: description.length,
    );
  }
  
  Future<List<String>> searchSimilarSigns(String query) async {
    final results = await _rag.search(text: query, limit: 5);
    return results.map((r) => r.chunk.document.target?.fileName ?? '').toList();
  }
}
```

**Benefits:**
- ✅ Dynamic sign learning
- ✅ Community contributions
- ✅ Semantic sign search
- ✅ Expandable dictionary

---

## 📋 IMPLEMENTATION PRIORITY

### Priority 1: Critical (Implement Now)
1. ✅ **Fix STT Implementation** - Remove placeholder, use real transcription
2. ✅ **Add Progress Callbacks** - Show download progress to users
3. ✅ **Improve Error Handling** - Better error messages and recovery

### Priority 2: High (Implement Soon)
4. ⏳ **Add Vision Model Support** - Use LFM2-VL-450M for better hand detection
5. ⏳ **Add Model Management UI** - Let users manage downloaded models
6. ⏳ **Add Streaming Support** - Real-time text generation

### Priority 3: Medium (Future Enhancement)
7. ⏳ **Add Embeddings Support** - Semantic search for signs
8. ⏳ **Add RAG Support** - Dynamic sign learning
9. ⏳ **Add Telemetry** - Monitor app performance

---

## 🔧 IMPLEMENTATION STEPS

### Step 1: Fix STT (30 minutes)
```bash
# Edit: lib/features/speech_recognition/services/speech_recognition_service.dart
# Replace _simulateListening() with real transcription
# Test microphone permissions
```

### Step 2: Add Progress Callbacks (20 minutes)
```bash
# Edit: lib/core/services/cactus_model_service.dart
# Add downloadProcessCallback to all downloads
# Update UI to show progress
```

### Step 3: Add Vision Model (2 hours)
```bash
# Edit: lib/core/services/cactus_model_service.dart
# Add _initializeVisionModel() method
# Implement detectHandLandmarksWithVision()
# Add fallback logic
```

### Step 4: Add Model Management (3 hours)
```bash
# Create: lib/ui/screens/model_management_screen.dart
# Add navigation from settings
# Implement download UI
# Test model switching
```

---

## 📊 EXPECTED IMPROVEMENTS

### Performance
```
Before:
- STT: Simulated (not functional)
- Downloads: No progress feedback
- Vision: Google ML Kit only

After:
- STT: Real Whisper transcription ✅
- Downloads: Real-time progress ✅
- Vision: Cactus LFM2-VL + ML Kit fallback ✅
```

### User Experience
```
Before:
- No download visibility
- Limited model options
- No streaming output

After:
- Progress bars for downloads ✅
- Model management UI ✅
- Real-time text generation ✅
```

### Capabilities
```
New Features:
+ Embeddings for semantic search
+ RAG for dynamic learning
+ Streaming completions
+ Vision model support
+ Model management
```

---

## 🎯 QUICK WINS (Implement First)

### 1. Fix STT Implementation (30 min)
**Impact:** High - Makes speech-to-sign actually work  
**Effort:** Low - Simple API call change  
**Priority:** 🔴 Critical

### 2. Add Progress Callbacks (20 min)
**Impact:** High - Much better UX  
**Effort:** Low - Add callbacks to existing code  
**Priority:** 🔴 Critical

### 3. Improve Error Messages (15 min)
**Impact:** Medium - Better debugging  
**Effort:** Low - Update error handling  
**Priority:** 🟡 High

---

## 📚 DOCUMENTATION UPDATES NEEDED

After implementing optimizations:

1. Update [`CACTUS_SDK_INTEGRATION_GUIDE.md`](CACTUS_SDK_INTEGRATION_GUIDE.md)
2. Update [`README.md`](README.md) with new features
3. Update [`USER_GUIDE.md`](USER_GUIDE.md) with model management
4. Create `VISION_MODEL_GUIDE.md` for LFM2-VL usage
5. Update [`FAQ.md`](FAQ.md) with new capabilities

---

## ✅ TESTING CHECKLIST

After implementing optimizations:

- [ ] Test real STT transcription
- [ ] Verify download progress displays
- [ ] Test vision model initialization
- [ ] Verify ML Kit fallback works
- [ ] Test model management UI
- [ ] Verify streaming completions
- [ ] Test embedding generation
- [ ] Verify error handling
- [ ] Test on physical device
- [ ] Measure performance improvements

---

## 🎉 CONCLUSION

### Current Status
✅ **Good:** Using Cactus SDK correctly for STT and LM  
⚠️ **Needs Work:** STT has placeholder implementation  
⚠️ **Missing:** Progress callbacks, vision model, streaming

### After Optimizations
✅ **Excellent:** Full Cactus SDK integration  
✅ **Complete:** All features working  
✅ **Enhanced:** Better UX and capabilities  
✅ **Future-Ready:** RAG and embeddings support

### Estimated Time
- **Quick Wins:** 1 hour (STT + Progress + Errors)
- **Full Implementation:** 8 hours (All optimizations)
- **Testing:** 2 hours
- **Total:** 11 hours for complete optimization

### ROI
- **User Experience:** 🚀 Massive improvement
- **Functionality:** 🚀 Actually works (STT)
- **Capabilities:** 🚀 New features (vision, streaming, RAG)
- **Code Quality:** 🚀 Better SDK usage

---

**Recommendation:** Implement Priority 1 items (STT + Progress) immediately for hackathon submission. Add Priority 2 items post-launch.

**Status:** 🎯 **READY TO OPTIMIZE**