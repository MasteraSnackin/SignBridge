# Contributing to SignBridge

Thank you for your interest in contributing to SignBridge! This document provides guidelines and instructions for contributing.

## 🎯 Ways to Contribute

### 1. Code Contributions
- Bug fixes
- New features
- Performance improvements
- Code refactoring
- Test coverage improvements

### 2. Documentation
- README improvements
- Code comments
- API documentation
- Tutorials and guides
- Translation of documentation

### 3. Testing
- Manual testing on different devices
- Writing unit tests
- Writing integration tests
- Performance testing
- Accessibility testing

### 4. Design
- UI/UX improvements
- Icon design
- Animation design
- Accessibility improvements

### 5. Sign Language Content
- Adding new sign animations
- Expanding dictionary
- Supporting new sign languages
- Improving gesture recognition

## 🚀 Getting Started

### Prerequisites
- Flutter 3.0.0+
- Android Studio
- Git
- Basic knowledge of Dart/Flutter
- Understanding of sign language (helpful but not required)

### Setup Development Environment

1. **Fork the Repository**
   ```bash
   # Click "Fork" on GitHub
   # Clone your fork
   git clone https://github.com/YOUR_USERNAME/signbridge.git
   cd signbridge
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the App**
   ```bash
   flutter run
   ```

4. **Create a Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

## 📝 Development Guidelines

### Code Style

**Follow Flutter/Dart Style Guide:**
- Use `flutter analyze` to check code
- Format code with `dart format`
- Follow naming conventions:
  - Classes: `PascalCase`
  - Variables/functions: `camelCase`
  - Constants: `SCREAMING_SNAKE_CASE`
  - Private members: `_leadingUnderscore`

**Example:**
```dart
class SignRecognitionService extends ChangeNotifier {
  static const int MAX_BUFFER_SIZE = 5;
  
  final CameraService _cameraService;
  bool _isProcessing = false;
  
  Future<void> startRecognition() async {
    // Implementation
  }
  
  void _processFrame(CameraImage image) {
    // Implementation
  }
}
```

### Project Structure

```
lib/
├── core/           # Core functionality (models, services, utils)
├── features/       # Feature modules (sign recognition, speech, etc.)
├── ui/            # User interface (screens, widgets, theme)
└── data/          # Data layer (repositories, data sources)
```

**When adding new features:**
1. Create feature directory in `lib/features/`
2. Organize into `models/`, `services/`, `widgets/`
3. Update imports in related files
4. Add tests in `test/features/`

### Commit Messages

Use conventional commit format:

```
type(scope): subject

body (optional)

footer (optional)
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(recognition): add support for numbers 0-9
fix(camera): resolve memory leak in frame processing
docs(readme): update installation instructions
test(classifier): add unit tests for cosine similarity
```

### Testing

**Write tests for:**
- All new features
- Bug fixes
- Critical algorithms
- Public APIs

**Test Structure:**
```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GestureClassifier', () {
    late GestureClassifier classifier;
    
    setUp(() {
      classifier = GestureClassifier();
    });
    
    test('recognizes letter A correctly', () {
      // Arrange
      final landmarks = createTestLandmarks('A');
      
      // Act
      final result = classifier.classify(landmarks);
      
      // Assert
      expect(result.letter, 'A');
      expect(result.confidence, greaterThan(0.75));
    });
  });
}
```

**Run tests:**
```bash
# All tests
flutter test

# Specific test file
flutter test test/features/sign_recognition/gesture_classifier_test.dart

# With coverage
flutter test --coverage
```

### Documentation

**Code Comments:**
```dart
/// Classifies hand landmarks into ASL gestures using cosine similarity.
///
/// This classifier compares input landmarks against a database of known
/// gestures and returns the best match if confidence exceeds threshold.
///
/// Example:
/// ```dart
/// final classifier = GestureClassifier();
/// final result = classifier.classify(landmarks);
/// if (result != null) {
///   print('Recognized: ${result.letter}');
/// }
/// ```
class GestureClassifier {
  /// Minimum confidence threshold for recognition (0.0 to 1.0)
  static const double CONFIDENCE_THRESHOLD = 0.75;
  
  /// Classifies the given [landmarks] into an ASL gesture.
  ///
  /// Returns [RecognitionResult] if a match is found with sufficient
  /// confidence, otherwise returns null.
  RecognitionResult? classify(HandLandmarks landmarks) {
    // Implementation
  }
}
```

## 🔄 Pull Request Process

### Before Submitting

1. **Update your branch**
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Run checks**
   ```bash
   flutter analyze
   flutter test
   dart format lib/ test/
   ```

3. **Test manually**
   - Build and run the app
   - Test your changes thoroughly
   - Test on multiple devices if possible

### Submitting PR

1. **Push your branch**
   ```bash
   git push origin feature/your-feature-name
   ```

2. **Create Pull Request**
   - Go to GitHub
   - Click "New Pull Request"
   - Select your branch
   - Fill in the template

3. **PR Template**
   ```markdown
   ## Description
   Brief description of changes
   
   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update
   
   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Manual testing completed
   - [ ] Tested on device
   
   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Comments added for complex code
   - [ ] Documentation updated
   - [ ] No new warnings
   - [ ] Tests pass
   
   ## Screenshots (if applicable)
   Add screenshots here
   
   ## Related Issues
   Fixes #123
   ```

### Review Process

1. **Automated Checks**
   - CI/CD runs tests
   - Code analysis
   - Build verification

2. **Code Review**
   - Maintainer reviews code
   - Feedback provided
   - Changes requested if needed

3. **Approval & Merge**
   - Once approved, PR is merged
   - Branch can be deleted

## 🐛 Reporting Bugs

### Before Reporting

1. **Search existing issues**
   - Check if bug already reported
   - Add to existing issue if found

2. **Verify it's a bug**
   - Try to reproduce
   - Check on different devices
   - Update to latest version

### Bug Report Template

```markdown
**Describe the bug**
Clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What should happen

**Screenshots**
Add screenshots if applicable

**Device Information:**
- Device: [e.g. Pixel 6]
- Android Version: [e.g. 13]
- App Version: [e.g. 1.0.0]

**Additional context**
Any other relevant information
```

## 💡 Feature Requests

### Feature Request Template

```markdown
**Is your feature request related to a problem?**
Clear description of the problem

**Describe the solution you'd like**
Clear description of desired solution

**Describe alternatives you've considered**
Alternative solutions or features

**Additional context**
Mockups, examples, or other context
```

## 🎨 Design Guidelines

### UI/UX Principles
- **Accessibility First**: Support screen readers, high contrast
- **Simplicity**: Keep UI clean and intuitive
- **Consistency**: Follow Material Design 3
- **Performance**: Smooth animations, responsive UI
- **Feedback**: Clear visual feedback for actions

### Color Palette
- Primary: Blue (#2196F3)
- Secondary: Orange (#FF9800)
- Success: Green (#4CAF50)
- Error: Red (#F44336)
- Warning: Yellow (#FFC107)

### Typography
- Headings: Bold, 24-32px
- Body: Regular, 14-16px
- Captions: Regular, 12px

## 📚 Resources

### Documentation
- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Material Design](https://material.io/design)

### SignBridge Docs
- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - System architecture
- [CACTUS_INTEGRATION_GUIDE.md](CACTUS_INTEGRATION_GUIDE.md) - SDK integration
- [DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md) - Deployment process

### Community
- GitHub Issues: Bug reports and feature requests
- GitHub Discussions: Questions and discussions
- Email: support@signbridge.app

## 🏆 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Credited in the app (for significant contributions)

## ❓ Questions?

- Open a GitHub Discussion
- Email: dev@signbridge.app
- Check existing documentation

## 📜 Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of:
- Age, body size, disability
- Ethnicity, gender identity
- Experience level
- Nationality, personal appearance
- Race, religion
- Sexual identity and orientation

### Our Standards

**Positive behavior:**
- Using welcoming and inclusive language
- Being respectful of differing viewpoints
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards others

**Unacceptable behavior:**
- Trolling, insulting/derogatory comments
- Public or private harassment
- Publishing others' private information
- Other conduct which could reasonably be considered inappropriate

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported to the project team at conduct@signbridge.app. All complaints will be reviewed and investigated promptly and fairly.

## 🙏 Thank You!

Thank you for contributing to SignBridge! Your efforts help make communication more accessible for everyone.

---

**Happy Coding!** 🚀