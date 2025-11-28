import '../../core/utils/logger.dart';

/// Repository for managing word-to-sign animation mappings
class SignDictionaryRepository {
  static final SignDictionaryRepository _instance = SignDictionaryRepository._internal();
  factory SignDictionaryRepository() => _instance;
  SignDictionaryRepository._internal();
  
  // Dictionary mapping words to animation file paths
  final Map<String, String> _wordToAnimation = {};
  
  // Common words with sign animations (200-500 words)
  // In production, this would be loaded from a JSON file or database
  final Map<String, String> _commonWords = {
    // Greetings & Basic
    'hello': 'assets/signs/hello.json',
    'hi': 'assets/signs/hello.json',
    'goodbye': 'assets/signs/goodbye.json',
    'bye': 'assets/signs/goodbye.json',
    'please': 'assets/signs/please.json',
    'thank': 'assets/signs/thank.json',
    'thanks': 'assets/signs/thank.json',
    'sorry': 'assets/signs/sorry.json',
    'yes': 'assets/signs/yes.json',
    'no': 'assets/signs/no.json',
    
    // Pronouns
    'i': 'assets/signs/i.json',
    'you': 'assets/signs/you.json',
    'he': 'assets/signs/he.json',
    'she': 'assets/signs/she.json',
    'we': 'assets/signs/we.json',
    'they': 'assets/signs/they.json',
    'me': 'assets/signs/me.json',
    'my': 'assets/signs/my.json',
    'your': 'assets/signs/your.json',
    
    // Common verbs
    'go': 'assets/signs/go.json',
    'come': 'assets/signs/come.json',
    'want': 'assets/signs/want.json',
    'need': 'assets/signs/need.json',
    'have': 'assets/signs/have.json',
    'know': 'assets/signs/know.json',
    'think': 'assets/signs/think.json',
    'see': 'assets/signs/see.json',
    'hear': 'assets/signs/hear.json',
    'say': 'assets/signs/say.json',
    'tell': 'assets/signs/tell.json',
    'ask': 'assets/signs/ask.json',
    'help': 'assets/signs/help.json',
    'like': 'assets/signs/like.json',
    'love': 'assets/signs/love.json',
    'eat': 'assets/signs/eat.json',
    'drink': 'assets/signs/drink.json',
    'sleep': 'assets/signs/sleep.json',
    'work': 'assets/signs/work.json',
    'play': 'assets/signs/play.json',
    'learn': 'assets/signs/learn.json',
    'teach': 'assets/signs/teach.json',
    'read': 'assets/signs/read.json',
    'write': 'assets/signs/write.json',
    'understand': 'assets/signs/understand.json',
    
    // Common nouns
    'home': 'assets/signs/home.json',
    'school': 'assets/signs/school.json',
    'office': 'assets/signs/office.json',
    'family': 'assets/signs/family.json',
    'friend': 'assets/signs/friend.json',
    'mother': 'assets/signs/mother.json',
    'mom': 'assets/signs/mother.json',
    'father': 'assets/signs/father.json',
    'dad': 'assets/signs/father.json',
    'brother': 'assets/signs/brother.json',
    'sister': 'assets/signs/sister.json',
    'child': 'assets/signs/child.json',
    'baby': 'assets/signs/baby.json',
    'man': 'assets/signs/man.json',
    'woman': 'assets/signs/woman.json',
    'boy': 'assets/signs/boy.json',
    'girl': 'assets/signs/girl.json',
    'person': 'assets/signs/person.json',
    'people': 'assets/signs/people.json',
    'food': 'assets/signs/food.json',
    'water': 'assets/signs/water.json',
    'time': 'assets/signs/time.json',
    'day': 'assets/signs/day.json',
    'night': 'assets/signs/night.json',
    'morning': 'assets/signs/morning.json',
    'afternoon': 'assets/signs/afternoon.json',
    'evening': 'assets/signs/evening.json',
    'today': 'assets/signs/today.json',
    'tomorrow': 'assets/signs/tomorrow.json',
    'yesterday': 'assets/signs/yesterday.json',
    'week': 'assets/signs/week.json',
    'month': 'assets/signs/month.json',
    'year': 'assets/signs/year.json',
    
    // Adjectives
    'good': 'assets/signs/good.json',
    'bad': 'assets/signs/bad.json',
    'big': 'assets/signs/big.json',
    'small': 'assets/signs/small.json',
    'hot': 'assets/signs/hot.json',
    'cold': 'assets/signs/cold.json',
    'happy': 'assets/signs/happy.json',
    'sad': 'assets/signs/sad.json',
    'angry': 'assets/signs/angry.json',
    'tired': 'assets/signs/tired.json',
    'hungry': 'assets/signs/hungry.json',
    'thirsty': 'assets/signs/thirsty.json',
    'sick': 'assets/signs/sick.json',
    'healthy': 'assets/signs/healthy.json',
    'beautiful': 'assets/signs/beautiful.json',
    'ugly': 'assets/signs/ugly.json',
    'new': 'assets/signs/new.json',
    'old': 'assets/signs/old.json',
    'young': 'assets/signs/young.json',
    'fast': 'assets/signs/fast.json',
    'slow': 'assets/signs/slow.json',
    
    // Question words
    'what': 'assets/signs/what.json',
    'where': 'assets/signs/where.json',
    'when': 'assets/signs/when.json',
    'who': 'assets/signs/who.json',
    'why': 'assets/signs/why.json',
    'how': 'assets/signs/how.json',
    'which': 'assets/signs/which.json',
    
    // Numbers (0-20)
    'zero': 'assets/signs/0.json',
    'one': 'assets/signs/1.json',
    'two': 'assets/signs/2.json',
    'three': 'assets/signs/3.json',
    'four': 'assets/signs/4.json',
    'five': 'assets/signs/5.json',
    'six': 'assets/signs/6.json',
    'seven': 'assets/signs/7.json',
    'eight': 'assets/signs/8.json',
    'nine': 'assets/signs/9.json',
    'ten': 'assets/signs/10.json',
    
    // Colors
    'red': 'assets/signs/red.json',
    'blue': 'assets/signs/blue.json',
    'green': 'assets/signs/green.json',
    'yellow': 'assets/signs/yellow.json',
    'black': 'assets/signs/black.json',
    'white': 'assets/signs/white.json',
    'orange': 'assets/signs/orange.json',
    'purple': 'assets/signs/purple.json',
    'pink': 'assets/signs/pink.json',
    'brown': 'assets/signs/brown.json',
    
    // Places
    'here': 'assets/signs/here.json',
    'there': 'assets/signs/there.json',
    'hospital': 'assets/signs/hospital.json',
    'store': 'assets/signs/store.json',
    'restaurant': 'assets/signs/restaurant.json',
    'bathroom': 'assets/signs/bathroom.json',
    'bedroom': 'assets/signs/bedroom.json',
    'kitchen': 'assets/signs/kitchen.json',
    
    // Emergency & Important
    'emergency': 'assets/signs/emergency.json',
    'police': 'assets/signs/police.json',
    'danger': 'assets/signs/danger.json',
    'safe': 'assets/signs/safe.json',
    'stop': 'assets/signs/stop.json',
    'wait': 'assets/signs/wait.json',
    'careful': 'assets/signs/careful.json',
    'important': 'assets/signs/important.json',
  };
  
  /// Initialize the dictionary
  Future<void> initialize() async {
    try {
      Logger.info('Initializing SignDictionaryRepository');
      
      // Load common words
      _wordToAnimation.addAll(_commonWords);
      
      // TODO: Load additional words from JSON file or database
      // await _loadFromAssets();
      
      Logger.success('SignDictionaryRepository initialized with ${_wordToAnimation.length} words');
    } catch (e, stackTrace) {
      Logger.error('Failed to initialize SignDictionaryRepository', 
                   error: e, stackTrace: stackTrace);
      rethrow;
    }
  }
  
  /// Check if a word has a sign animation
  bool hasSign(String word) {
    final normalizedWord = word.toLowerCase().trim();
    return _wordToAnimation.containsKey(normalizedWord);
  }
  
  /// Get animation path for a word
  String? getAnimationPath(String word) {
    final normalizedWord = word.toLowerCase().trim();
    return _wordToAnimation[normalizedWord];
  }
  
  /// Get all available words
  List<String> getAllWords() {
    return _wordToAnimation.keys.toList()..sort();
  }
  
  /// Get dictionary size
  int get size => _wordToAnimation.length;
  
  /// Add a custom word mapping
  void addWord(String word, String animationPath) {
    final normalizedWord = word.toLowerCase().trim();
    _wordToAnimation[normalizedWord] = animationPath;
    Logger.debug('Added word: $normalizedWord -> $animationPath');
  }
  
  /// Remove a word mapping
  void removeWord(String word) {
    final normalizedWord = word.toLowerCase().trim();
    _wordToAnimation.remove(normalizedWord);
    Logger.debug('Removed word: $normalizedWord');
  }
  
  /// Search for words by prefix
  List<String> searchByPrefix(String prefix) {
    final normalizedPrefix = prefix.toLowerCase().trim();
    return _wordToAnimation.keys
        .where((word) => word.startsWith(normalizedPrefix))
        .toList()
      ..sort();
  }
  
  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalWords': _wordToAnimation.length,
      'categories': {
        'greetings': _countCategory(['hello', 'goodbye', 'please', 'thank']),
        'pronouns': _countCategory(['i', 'you', 'he', 'she', 'we', 'they']),
        'verbs': _countCategory(['go', 'come', 'want', 'need', 'have']),
        'nouns': _countCategory(['home', 'school', 'family', 'friend']),
        'adjectives': _countCategory(['good', 'bad', 'big', 'small', 'happy']),
        'questions': _countCategory(['what', 'where', 'when', 'who', 'why']),
        'numbers': _countCategory(['zero', 'one', 'two', 'three', 'four']),
        'colors': _countCategory(['red', 'blue', 'green', 'yellow']),
      },
    };
  }
  
  int _countCategory(List<String> sampleWords) {
    return sampleWords.where((word) => hasSign(word)).length;
  }
  
  /// Load additional words from JSON file
  Future<void> _loadFromAssets() async {
    // TODO: Implement loading from assets/data/sign_dictionary.json
    // This would allow for easy expansion of the dictionary
  }
}