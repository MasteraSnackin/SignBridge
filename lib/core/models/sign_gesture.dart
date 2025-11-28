class SignGesture {
  final String label;
  final List<double> landmarks; // 63D normalized vector
  final String description;
  final String category; // 'letter', 'number', 'word'
  
  SignGesture({
    required this.label,
    required this.landmarks,
    required this.description,
    required this.category,
  }) : assert(landmarks.length == 63, 'Landmarks must be 63-dimensional');
  
  Map<String, dynamic> toJson() => {
    'label': label,
    'landmarks': landmarks,
    'description': description,
    'category': category,
  };
  
  factory SignGesture.fromJson(Map<String, dynamic> json) {
    return SignGesture(
      label: json['label'] as String,
      landmarks: (json['landmarks'] as List).cast<double>(),
      description: json['description'] as String,
      category: json['category'] as String,
    );
  }
  
  @override
  String toString() => 'SignGesture($label, $category)';
}