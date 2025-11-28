# SignBridge - System Diagrams

This document contains visual representations of SignBridge's architecture, data flows, and component interactions.

---

## System Architecture Overview

```mermaid
graph TB
    subgraph "UI Layer"
        A[HomeScreen]
        B[SignToSpeechScreen]
        C[SpeechToSignScreen]
        D[SettingsScreen]
    end
    
    subgraph "Business Logic Layer"
        E[SignRecognitionService]
        F[SpeechRecognitionService]
        G[SignAnimationService]
        H[TTSService]
        I[GestureClassifier]
        J[LetterBuffer]
    end
    
    subgraph "Data Layer"
        K[CactusModelService]
        L[CameraService]
        M[PermissionService]
        N[SignDictionaryRepository]
    end
    
    subgraph "Cactus SDK"
        O[LFM2-VL-450M]
        P[Qwen3-0.6B]
        Q[Whisper-Tiny]
    end
    
    A --> B
    A --> C
    A --> D
    
    B --> E
    B --> L
    C --> F
    C --> G
    
    E --> I
    E --> J
    E --> H
    F --> G
    G --> N
    
    E --> K
    F --> K
    L --> M
    
    K --> O
    K --> P
    K --> Q
    
    style A fill:#e1f5ff
    style B fill:#e1f5ff
    style C fill:#e1f5ff
    style D fill:#e1f5ff
    style E fill:#fff4e1
    style F fill:#fff4e1
    style G fill:#fff4e1
    style H fill:#fff4e1
    style I fill:#fff4e1
    style J fill:#fff4e1
    style K fill:#e8f5e9
    style L fill:#e8f5e9
    style M fill:#e8f5e9
    style N fill:#e8f5e9
    style O fill:#f3e5f5
    style P fill:#f3e5f5
    style Q fill:#f3e5f5
```

---

## Sign-to-Speech Data Flow

```mermaid
sequenceDiagram
    participant User
    participant Camera
    participant SignRecognitionService
    participant CactusModelService
    participant GestureClassifier
    participant LetterBuffer
    participant TTSService
    
    User->>Camera: Show hand gesture
    Camera->>SignRecognitionService: Camera frame (30 FPS)
    
    Note over SignRecognitionService: Throttle to 10 FPS
    
    SignRecognitionService->>SignRecognitionService: Preprocess image
    SignRecognitionService->>CactusModelService: Request landmark detection
    CactusModelService->>CactusModelService: LFM2-VL inference
    CactusModelService-->>SignRecognitionService: 21 hand landmarks
    
    SignRecognitionService->>GestureClassifier: Classify gesture (63D vector)
    GestureClassifier->>GestureClassifier: Cosine similarity matching
    GestureClassifier-->>SignRecognitionService: Recognition result + confidence
    
    SignRecognitionService->>LetterBuffer: Add result to buffer
    LetterBuffer->>LetterBuffer: Majority vote (5 frames)
    LetterBuffer-->>SignRecognitionService: Stable letter
    
    SignRecognitionService->>SignRecognitionService: Assemble word
    SignRecognitionService->>TTSService: Speak text
    TTSService->>User: Audio output
    
    Note over User,TTSService: Total latency: <500ms
```

---

## Speech-to-Sign Data Flow

```mermaid
sequenceDiagram
    participant User
    participant Microphone
    participant SpeechRecognitionService
    participant CactusModelService
    participant SignAnimationService
    participant SignDictionary
    participant UI
    
    User->>Microphone: Speak words
    Microphone->>SpeechRecognitionService: Audio data (16kHz)
    
    SpeechRecognitionService->>SpeechRecognitionService: Preprocess audio
    SpeechRecognitionService->>CactusModelService: Request transcription
    CactusModelService->>CactusModelService: Whisper inference
    CactusModelService-->>SpeechRecognitionService: Transcribed text
    
    SpeechRecognitionService->>SpeechRecognitionService: Tokenize into words
    
    loop For each word
        SpeechRecognitionService->>SignAnimationService: Display word
        SignAnimationService->>SignDictionary: Lookup animation
        
        alt Word found in dictionary
            SignDictionary-->>SignAnimationService: Animation path
            SignAnimationService->>UI: Play animation
        else Word not found
            SignAnimationService->>SignAnimationService: Fingerspell letter-by-letter
            SignAnimationService->>UI: Display fingerspelling
        end
        
        UI->>User: Show sign animation
        Note over SignAnimationService,UI: 500ms pause between words
    end
```

---

## Component Interaction Diagram

```mermaid
graph LR
    subgraph "Sign Recognition Pipeline"
        A1[Camera] --> A2[Frame Processor]
        A2 --> A3[Landmark Detector]
        A3 --> A4[Gesture Classifier]
        A4 --> A5[Letter Buffer]
        A5 --> A6[Word Assembler]
        A6 --> A7[TTS Engine]
    end
    
    subgraph "Speech Recognition Pipeline"
        B1[Microphone] --> B2[Audio Processor]
        B2 --> B3[Speech-to-Text]
        B3 --> B4[Word Tokenizer]
        B4 --> B5[Dictionary Lookup]
        B5 --> B6[Animation Player]
    end
    
    subgraph "Shared Services"
        C1[Cactus Models]
        C2[Permission Manager]
        C3[Performance Monitor]
    end
    
    A3 -.-> C1
    B3 -.-> C1
    A1 -.-> C2
    B1 -.-> C2
    A2 -.-> C3
    B2 -.-> C3
    
    style A1 fill:#bbdefb
    style A7 fill:#bbdefb
    style B1 fill:#c8e6c9
    style B6 fill:#c8e6c9
    style C1 fill:#fff9c4
    style C2 fill:#fff9c4
    style C3 fill:#fff9c4
```

---

## State Management Flow

```mermaid
stateDiagram-v2
    [*] --> Idle
    
    Idle --> InitializingModels: App Launch
    InitializingModels --> DownloadingModels: Models not found
    InitializingModels --> LoadingModels: Models exist
    DownloadingModels --> LoadingModels: Download complete
    LoadingModels --> Ready: Models loaded
    
    Ready --> SignToSpeech: User selects mode
    Ready --> SpeechToSign: User selects mode
    
    SignToSpeech --> ProcessingGesture: Camera active
    ProcessingGesture --> RecognizingLetter: Landmarks detected
    RecognizingLetter --> BufferingLetter: Classification complete
    BufferingLetter --> AssemblingWord: Stable letter found
    AssemblingWord --> Speaking: Word complete
    Speaking --> ProcessingGesture: Continue recognition
    
    SpeechToSign --> ListeningToSpeech: Mic active
    ListeningToSpeech --> TranscribingAudio: Audio captured
    TranscribingAudio --> TokenizingText: Transcription complete
    TokenizingText --> DisplayingAnimation: Words extracted
    DisplayingAnimation --> ListeningToSpeech: Continue listening
    
    SignToSpeech --> Ready: Stop recognition
    SpeechToSign --> Ready: Stop listening
    
    Ready --> [*]: App closed
```

---

## Performance Optimization Strategy

```mermaid
graph TD
    A[Camera Frame 30 FPS] --> B{Throttle}
    B -->|Every 3rd frame| C[Process Frame 10 FPS]
    B -->|Skip| D[Discard]
    
    C --> E[Preprocess Image]
    E --> F{Use Isolate?}
    F -->|Yes| G[Parallel Processing]
    F -->|No| H[Main Thread]
    
    G --> I[Model Inference]
    H --> I
    
    I --> J{GPU Available?}
    J -->|Yes| K[GPU Acceleration]
    J -->|No| L[CPU Inference]
    
    K --> M[Result]
    L --> M
    
    M --> N{Latency < 500ms?}
    N -->|Yes| O[Continue]
    N -->|No| P[Optimize]
    
    P --> Q[Reduce Frame Rate]
    P --> R[Simplify Preprocessing]
    P --> S[Model Quantization]
    
    Q --> B
    R --> E
    S --> I
    
    style A fill:#e3f2fd
    style M fill:#c8e6c9
    style N fill:#fff9c4
    style P fill:#ffccbc
```

---

## Error Handling Flow

```mermaid
graph TB
    A[User Action] --> B{Permission Check}
    B -->|Denied| C[Show Permission Dialog]
    B -->|Granted| D{Models Ready?}
    
    C --> E[Request Permission]
    E --> F{Granted?}
    F -->|Yes| D
    F -->|No| G[Show Error Message]
    
    D -->|No| H[Download Models]
    D -->|Yes| I[Start Processing]
    
    H --> J{Download Success?}
    J -->|Yes| I
    J -->|No| K[Show Retry Dialog]
    
    I --> L{Processing Error?}
    L -->|Camera Error| M[Restart Camera]
    L -->|Model Error| N[Reload Model]
    L -->|Low Confidence| O[Show Feedback]
    L -->|No Error| P[Continue]
    
    M --> I
    N --> I
    O --> I
    
    K --> H
    G --> Q[Return to Home]
    
    style A fill:#e3f2fd
    style P fill:#c8e6c9
    style G fill:#ffcdd2
    style K fill:#ffcdd2
```

---

## Memory Management Strategy

```mermaid
graph LR
    subgraph "App Lifecycle"
        A1[onCreate] --> A2[onStart]
        A2 --> A3[onResume]
        A3 --> A4[onPause]
        A4 --> A5[onStop]
        A5 --> A6[onDestroy]
    end
    
    subgraph "Resource Management"
        B1[Load Models]
        B2[Initialize Camera]
        B3[Start Processing]
        B4[Pause Processing]
        B5[Release Camera]
        B6[Unload Models]
    end
    
    A1 --> B1
    A2 --> B2
    A3 --> B3
    A4 --> B4
    A5 --> B5
    A6 --> B6
    
    B3 --> C1[Monitor Memory]
    C1 --> C2{Memory > 1.5GB?}
    C2 -->|Yes| C3[Clear Buffers]
    C2 -->|No| B3
    C3 --> B3
    
    style A3 fill:#c8e6c9
    style A4 fill:#fff9c4
    style C2 fill:#ffccbc
```

---

## Deployment Architecture

```mermaid
graph TB
    subgraph "Development"
        A1[Source Code]
        A2[Assets]
        A3[Models]
    end
    
    subgraph "Build Process"
        B1[Flutter Build]
        B2[Asset Bundling]
        B3[Model Packaging]
        B4[APK Generation]
    end
    
    subgraph "Distribution"
        C1[APK File]
        C2[Play Store]
        C3[Direct Download]
    end
    
    subgraph "User Device"
        D1[Install APK]
        D2[First Launch]
        D3[Download Models]
        D4[Initialize]
        D5[Ready to Use]
    end
    
    A1 --> B1
    A2 --> B2
    A3 --> B3
    
    B1 --> B4
    B2 --> B4
    B3 --> B4
    
    B4 --> C1
    C1 --> C2
    C1 --> C3
    
    C2 --> D1
    C3 --> D1
    
    D1 --> D2
    D2 --> D3
    D3 --> D4
    D4 --> D5
    
    style D5 fill:#c8e6c9
```

---

## Testing Strategy

```mermaid
graph TD
    A[Testing Strategy] --> B[Unit Tests]
    A --> C[Integration Tests]
    A --> D[UI Tests]
    A --> E[Performance Tests]
    
    B --> B1[Model Tests]
    B --> B2[Service Tests]
    B --> B3[Utility Tests]
    
    C --> C1[Pipeline Tests]
    C --> C2[Service Integration]
    C --> C3[End-to-End Flow]
    
    D --> D1[Screen Tests]
    D --> D2[Widget Tests]
    D --> D3[Navigation Tests]
    
    E --> E1[Latency Tests]
    E --> E2[Memory Tests]
    E --> E3[Battery Tests]
    
    B1 --> F[Test Report]
    B2 --> F
    B3 --> F
    C1 --> F
    C2 --> F
    C3 --> F
    D1 --> F
    D2 --> F
    D3 --> F
    E1 --> F
    E2 --> F
    E3 --> F
    
    F --> G{All Pass?}
    G -->|Yes| H[Deploy]
    G -->|No| I[Fix Issues]
    I --> A
    
    style H fill:#c8e6c9
    style I fill:#ffccbc
```

---

## Key Metrics Dashboard

```mermaid
graph LR
    subgraph "Performance Metrics"
        A1[Latency: <500ms]
        A2[FPS: 10]
        A3[Accuracy: >90%]
    end
    
    subgraph "Resource Metrics"
        B1[Memory: <2GB]
        B2[Battery: Optimized]
        B3[APK Size: ~1.2GB]
    end
    
    subgraph "Quality Metrics"
        C1[Confidence: >75%]
        C2[Error Rate: <10%]
        C3[User Satisfaction]
    end
    
    A1 --> D[Dashboard]
    A2 --> D
    A3 --> D
    B1 --> D
    B2 --> D
    B3 --> D
    C1 --> D
    C2 --> D
    C3 --> D
    
    D --> E{Meets Targets?}
    E -->|Yes| F[Production Ready]
    E -->|No| G[Optimize]
    
    style F fill:#c8e6c9
    style G fill:#fff9c4
```

---

## Future Enhancements Roadmap

```mermaid
timeline
    title SignBridge Development Roadmap
    
    section Phase 1 - MVP
        Week 1 : Core Features
               : Sign-to-Speech
               : Speech-to-Sign
               : Basic UI
    
    section Phase 2 - Enhancement
        Week 2-3 : Expanded Vocabulary
                 : Performance Optimization
                 : User Training Mode
    
    section Phase 3 - Advanced
        Week 4-6 : Continuous Signing
                 : Multiple Languages
                 : Cloud Fallback
    
    section Phase 4 - Scale
        Week 7-8 : Video Call Integration
                 : Community Features
                 : Educational Mode
```

---

## Security & Privacy Architecture

```mermaid
graph TB
    A[User Data] --> B{Data Type}
    
    B -->|Camera Feed| C[Local Processing Only]
    B -->|Audio Input| D[Local Processing Only]
    B -->|Recognition Results| E[Temporary Storage]
    
    C --> F[Never Uploaded]
    D --> F
    E --> G[Cleared on Exit]
    
    H[Hybrid Mode] --> I{User Consent?}
    I -->|Yes| J[Cloud API Call]
    I -->|No| K[Local Only]
    
    J --> L[Encrypted Transfer]
    L --> M[No Data Retention]
    
    K --> F
    M --> F
    
    F --> N[Complete Privacy]
    G --> N
    
    style N fill:#c8e6c9
    style F fill:#c8e6c9
```

---

These diagrams provide a comprehensive visual understanding of SignBridge's architecture, data flows, and system interactions. Use them as reference during implementation and for documentation purposes.