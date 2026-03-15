import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:edusarthi_app/features/english/controller/english_controller.dart';
import 'package:edusarthi_app/features/english/screens/chat_screen.dart';
import 'package:edusarthi_app/features/english/screens/grammar_fix_screen.dart';
import 'package:edusarthi_app/features/english/screens/grammar_topics_screen.dart';
import 'package:edusarthi_app/features/english/screens/voice_practice_screen.dart';
import 'package:edusarthi_app/features/english/screens/lesson_screen.dart';

/// English Module Home – Level selection, Day-wise lessons, Quick Tools.
class EnglishHomeScreen extends StatefulWidget {
  const EnglishHomeScreen({super.key});

  @override
  State<EnglishHomeScreen> createState() => _EnglishHomeScreenState();
}

class _EnglishHomeScreenState extends State<EnglishHomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  final selectedLevel = 'beginner'.obs;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<EnglishController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('📚 ', style: TextStyle(fontSize: 24)),
            const Text('English Learning',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_rounded, color: Color(0xFF4A90D9)),
            onPressed: () => Get.to(() => const ChatScreen()),
            tooltip: 'AI Chat',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Welcome Banner ─────────────
            FadeTransition(
              opacity: _animController,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.3),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _animController,
                  curve: Curves.easeOut,
                )),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4A90D9), Color(0xFF6C63FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4A90D9).withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('🌟 Learn English Step by Step!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 6),
                      Text('Read a new lesson every day and\nbecome an English expert! 🚀\nहर दिन एक नया पाठ पढ़ें! 📖',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 14, height: 1.4)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Level Selection ─────────────
            const Text('🎯 Choose Your Level (अपना स्तर चुनें)',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 4),
            Text('Select your level to start learning',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
            const SizedBox(height: 12),
            Obx(
              () => Row(
                children: [
                  _LevelChip('Beginner', '🌱', 'beginner', 21,
                      selectedLevel.value, (v) => selectedLevel.value = v),
                  const SizedBox(width: 8),
                  _LevelChip('Intermediate', '📚', 'intermediate', 22,
                      selectedLevel.value, (v) => selectedLevel.value = v),
                  const SizedBox(width: 8),
                  _LevelChip('Advanced', '🎓', 'advanced', 20,
                      selectedLevel.value, (v) => selectedLevel.value = v),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Quick Tools ─────────────────
            const Text('⚡ Quick Tools',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 10),
            Row(
              children: [
                _ToolCard(
                  'AI Chat',
                  '💬',
                  Icons.chat_bubble_rounded,
                  const Color(0xFF4A90D9),
                  () => Get.to(() => const ChatScreen()),
                ),
                const SizedBox(width: 10),
                _ToolCard(
                  'Grammar',
                  '✏️',
                  Icons.spellcheck_rounded,
                  const Color(0xFF8B5CF6),
                  () => Get.to(() => const GrammarFixScreen()),
                ),
                const SizedBox(width: 10),
                _ToolCard(
                  'Vocab',
                  '📖',
                  Icons.abc_rounded,
                  const Color(0xFF10B981),
                  () => _showVocabularyDialog(context, controller),
                ),
                const SizedBox(width: 10),
                _ToolCard(
                  'Translate',
                  '🌐',
                  Icons.translate_rounded,
                  const Color(0xFFFF6B35),
                  () => _showTranslateDialog(context, controller),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _ToolCard(
                  'Grammar\nTopics',
                  '📋',
                  Icons.menu_book_rounded,
                  const Color(0xFF9333EA),
                  () => Get.to(() => const GrammarTopicsScreen()),
                ),
                const SizedBox(width: 10),
                _ToolCard(
                  'Voice\nPractice',
                  '🎙️',
                  Icons.mic_rounded,
                  const Color(0xFFEF4444),
                  () => Get.to(() => const VoicePracticeScreen()),
                ),
                const SizedBox(width: 10),
                const Expanded(child: SizedBox()),
                const SizedBox(width: 10),
                const Expanded(child: SizedBox()),
              ],
            ),
            const SizedBox(height: 24),

            // ── Day-wise Lessons ─────────────
            Obx(() {
              final level = selectedLevel.value;
              final topics = _getTopicsForLevel(level);
              final levelEmoji = level == 'beginner'
                  ? '🌱'
                  : level == 'intermediate'
                      ? '📚'
                      : '🎓';
              final levelName = level[0].toUpperCase() + level.substring(1);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('$levelEmoji $levelName Lessons',
                          style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A2E))),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text('${topics.length} Lessons',
                            style: const TextStyle(
                                color: Color(0xFF4A90D9),
                                fontSize: 12,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    level == 'beginner'
                        ? 'Start from basics – Self Introduction to Tenses\nमूल बातों से शुरू करें'
                        : level == 'intermediate'
                            ? 'Advanced grammar and vocabulary building\nउन्नत व्याकरण और शब्दावली'
                            : 'Professional English and practice worksheets\nपेशेवर अंग्रेजी और अभ्यास',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  ...List.generate(
                    topics.length,
                    (i) {
                      final topic = topics[i];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (i * 50)),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: _DayCard(
                          day: i + 1,
                          level: level,
                          title: topic['title'] as String,
                          subtitle: topic['subtitle'] as String,
                          emoji: topic['emoji'] as String,
                        ),
                      );
                    },
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  List<Map<String, String>> _getTopicsForLevel(String level) {
    if (level == 'beginner') return _beginnerTopics;
    if (level == 'intermediate') return _intermediateTopics;
    return _advancedTopics;
  }

  // ── Beginner Topics (Book Ch 1-21) ─────
  static const List<Map<String, String>> _beginnerTopics = [
    {'title': 'Self Introduction', 'emoji': '👋', 'subtitle': 'Apna parichay dena sikho'},
    {'title': 'Basic of English', 'emoji': '📖', 'subtitle': 'English ki buniyaad'},
    {'title': 'Greetings', 'emoji': '🤝', 'subtitle': 'Namaste se Hello tak'},
    {'title': 'Be Verb (is, am, are)', 'emoji': '✨', 'subtitle': 'I am, You are, He is'},
    {'title': 'Imperative Sentences', 'emoji': '📢', 'subtitle': 'Aadesh ya vinati ke vakya'},
    {'title': 'Use of Has/Have, Had and Will', 'emoji': '🔑', 'subtitle': 'Paas hona – mere paas hai'},
    {'title': 'Demonstrative Pronoun', 'emoji': '👉', 'subtitle': 'This, That, These, Those'},
    {'title': 'Use of Want', 'emoji': '🎯', 'subtitle': 'Chahna – I want, He wants'},
    {'title': 'Use of Wanted', 'emoji': '⏪', 'subtitle': 'Chahta tha – Past mein chahna'},
    {'title': 'Use of Going to', 'emoji': '🚶', 'subtitle': 'Jane wala hai – Future plans'},
    {'title': 'Use of There', 'emoji': '📍', 'subtitle': 'Wahan hai – There is/are'},
    {'title': 'Use of Let', 'emoji': '🤲', 'subtitle': 'Karne do – Let me, Let him'},
    {'title': "Use of Let's", 'emoji': '🤝', 'subtitle': "Chalo karte hain – Let's go"},
    {'title': 'Use of Would like to', 'emoji': '💭', 'subtitle': 'Pasand karunga – Polite requests'},
    {'title': 'Use of Need to', 'emoji': '⚡', 'subtitle': 'Zaroorat hai – I need to study'},
    {'title': 'Use of Needed to', 'emoji': '📋', 'subtitle': 'Zaroorat thi – Past needs'},
    {'title': 'Use of Fond of', 'emoji': '❤️', 'subtitle': 'Shaukeen hona – I am fond of'},
    {'title': 'Use of About to', 'emoji': '⏰', 'subtitle': 'Hone wala hai – About to happen'},
    {'title': 'Use of Make/Gate', 'emoji': '🔨', 'subtitle': 'Banana/Karwana'},
    {'title': 'Use of All Modals', 'emoji': '🎛️', 'subtitle': 'Can, Could, May, Might, Should'},
    {'title': 'Use of All Tense', 'emoji': '⏳', 'subtitle': 'Past, Present, Future – Sabhi kaal'},
  ];

  // ── Intermediate Topics (Book Ch 22-43) ─────
  static const List<Map<String, String>> _intermediateTopics = [
    {'title': 'Use of Has to/Have to, Had to', 'emoji': '💪', 'subtitle': 'Karna padta hai – Obligations'},
    {'title': 'Use of Able to', 'emoji': '🏋️', 'subtitle': 'Kar sakna – Ability expressions'},
    {'title': 'Use of Want to', 'emoji': '🎯', 'subtitle': 'Karna chahna – I want to learn'},
    {'title': 'Use of Wanted to', 'emoji': '⏪', 'subtitle': 'Karna chahta tha – Past desires'},
    {'title': 'Use of All Prepositions', 'emoji': '📐', 'subtitle': 'In, On, At, From, To'},
    {'title': 'Use of All W.H. Words', 'emoji': '❓', 'subtitle': 'What, When, Where, Why, How'},
    {'title': 'Use of All Passive Voice', 'emoji': '🔄', 'subtitle': 'Karmvachya – Work was done'},
    {'title': 'Verb List', 'emoji': '📝', 'subtitle': 'Sabhi important verbs ki list'},
    {'title': 'W.H. Words Vocabulary', 'emoji': '📚', 'subtitle': 'Question words practice'},
    {'title': 'Basic Spoken Words', 'emoji': '🗣️', 'subtitle': 'Roz bolne wale English words'},
    {'title': 'Daily Use Vocabulary', 'emoji': '📅', 'subtitle': 'Har din ke useful words'},
    {'title': 'Industry Vocabulary', 'emoji': '🏭', 'subtitle': 'Office aur business ke words'},
    {'title': 'Body & Diseases Vocabulary', 'emoji': '🏥', 'subtitle': 'Sharir aur bimaari ke words'},
    {'title': 'Vocabulary of Flowers & Fruits', 'emoji': '🌺', 'subtitle': 'Phool aur phal ke naam'},
    {'title': "Bird's and Astrology Vocabulary", 'emoji': '🐦', 'subtitle': 'Pakshi aur jyotish shabdavali'},
    {'title': 'Maths Vocabulary', 'emoji': '🔢', 'subtitle': 'Ganit ke English words'},
    {'title': 'Foods Vocabulary', 'emoji': '🍕', 'subtitle': 'Khane peene ke English naam'},
    {'title': 'Relation Worms & Insects', 'emoji': '🐛', 'subtitle': 'Rishte, keede makode ke naam'},
    {'title': 'Stationery Vocabulary', 'emoji': '✏️', 'subtitle': 'Stationery items English mein'},
    {'title': 'Factory and Sports Vocabulary', 'emoji': '⚽', 'subtitle': 'Factory aur khel ke words'},
    {'title': 'Sound, Music & Weather', 'emoji': '🎵', 'subtitle': 'Aawaz, sangeet aur mausam'},
    {'title': 'Colours and Judiciary Vocabulary', 'emoji': '🎨', 'subtitle': 'Rang aur kanoon ke words'},
  ];

  // ── Advanced Topics (Book Ch 44-49 + Worksheets) ─────
  static const List<Map<String, String>> _advancedTopics = [
    {'title': 'Professions & Occupations', 'emoji': '👔', 'subtitle': 'Peshon ke English naam'},
    {'title': 'Buildings and Months Vocabulary', 'emoji': '🏢', 'subtitle': 'Imaaraton aur mahinon ke naam'},
    {'title': 'Important Vocabulary', 'emoji': '⭐', 'subtitle': 'Zaroori English shabdavali'},
    {'title': 'Miscellaneous Words', 'emoji': '📦', 'subtitle': 'Aur bohot saare useful words'},
    {'title': 'Everyday Daily Vocabulary', 'emoji': '🌅', 'subtitle': 'Roz ke English expressions'},
    {'title': 'Conversation Sheets', 'emoji': '💬', 'subtitle': 'English mein baat-cheet practice'},
    {'title': 'Worksheet 1 - Basics Review', 'emoji': '📝', 'subtitle': 'Basic English revision'},
    {'title': 'Worksheet 2 - Tense Review', 'emoji': '📝', 'subtitle': 'Tenses ka complete revision'},
    {'title': 'Worksheet 3 - Verbs Review', 'emoji': '📝', 'subtitle': 'Verbs ka mashq'},
    {'title': 'Worksheet 4 - Sentences', 'emoji': '📝', 'subtitle': 'Vakyataon ka abhyas'},
    {'title': 'Worksheet 5 - Translation', 'emoji': '📝', 'subtitle': 'Hindi se English translation'},
    {'title': 'Worksheet 6 - Grammar', 'emoji': '📝', 'subtitle': 'Grammar ka complete revision'},
    {'title': 'Worksheet 7 - Vocabulary', 'emoji': '📝', 'subtitle': 'Shabdavali ka test'},
    {'title': 'Worksheet 8 - Modals', 'emoji': '📝', 'subtitle': 'Can, Could, May practice'},
    {'title': 'Worksheet 9 - Prepositions', 'emoji': '📝', 'subtitle': 'Prepositions ka mashq'},
    {'title': 'Worksheet 10 - Passive Voice', 'emoji': '📝', 'subtitle': 'Passive voice practice'},
    {'title': 'Worksheet 11-14 Mixed', 'emoji': '📝', 'subtitle': 'Mixed practice worksheets'},
    {'title': 'Worksheet 15-17 Advanced', 'emoji': '📝', 'subtitle': 'Advanced mixed practice'},
    {'title': 'Worksheet 18-19 Practice', 'emoji': '📝', 'subtitle': 'Final practice worksheets'},
    {'title': 'Final Comprehensive Test', 'emoji': '🏆', 'subtitle': 'Final comprehensive test'},
  ];

  void _showVocabularyDialog(BuildContext context, EnglishController controller) {
    final vocabResult = Rxn<List<dynamic>>();
    final isGenerating = false.obs;

    Get.dialog(
      Obx(() => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Text('📖 '),
            Text(vocabResult.value != null ? 'Vocabulary Words' : 'Generate Vocabulary'),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: vocabResult.value != null
              ? SizedBox(
                  height: 400,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: vocabResult.value!.length,
                    itemBuilder: (context, index) {
                      final word = vocabResult.value![index];
                      if (word is! Map) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('📗 ', style: TextStyle(fontSize: 16)),
                                Text(word['word']?.toString() ?? '',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF1A1A2E))),
                              ],
                            ),
                            if (word['pronunciation'] != null) ...[],
                            const SizedBox(height: 4),
                            if (word['meaning'] != null)
                              Text('English: ${word['meaning']}',
                                  style: TextStyle(
                                      color: Colors.grey.shade700, fontSize: 13)),
                            if (word['hindi_meaning'] != null)
                              Text('🇮🇳 Hindi: ${word['hindi_meaning']}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600, fontSize: 13)),
                            if (word['example'] != null) ...[                              const SizedBox(height: 4),
                              Text('💡 ${word['example']}',
                                  style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic)),
                            ],
                            if (word['synonyms'] is List && (word['synonyms'] as List).isNotEmpty) ...[                              const SizedBox(height: 4),
                              Text('Synonyms: ${(word['synonyms'] as List).join(', ')}',
                                  style: TextStyle(
                                      color: Colors.grey.shade500, fontSize: 11)),
                            ],
                          ],
                        ),
                      );
                    },
                  ),
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Generate 5 new vocabulary words for your level?\n5 नई शब्दावली उत्पन्न करें?'),
                    if (isGenerating.value) ...[                      const SizedBox(height: 16),
                      const CircularProgressIndicator(),
                      const SizedBox(height: 8),
                      const Text('Generating...', style: TextStyle(color: Colors.grey)),
                    ],
                  ],
                ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text(vocabResult.value != null ? 'Close' : 'Cancel')),
          if (vocabResult.value == null && !isGenerating.value)
            ElevatedButton(
              onPressed: () async {
                isGenerating.value = true;
                final result = await controller.getVocabulary();
                isGenerating.value = false;
                if (result != null) {
                  if (result is List) {
                    vocabResult.value = result;
                  } else if (result is Map && result.containsKey('words')) {
                    vocabResult.value = result['words'] as List;
                  } else if (result is Map) {
                    vocabResult.value = [result];
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Generate ✨'),
            ),
        ],
      )),
    );
  }

  void _showTranslateDialog(BuildContext context, EnglishController controller) {
    final textC = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🌐 Translate'),
        content: TextField(
          controller: textC,
          decoration: InputDecoration(
            hintText: 'Write in Hindi, it will be translated to English...\nहिंदी में लिखें, अंग्रेजी में अनुवाद होगा...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (textC.text.trim().isEmpty) return;
              Get.back();
              final result = await controller.translate(textC.text.trim());
              if (result != null) {
                Get.snackbar('Translation ✅', result,
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 5));
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Translate 🌐'),
          ),
        ],
      ),
    );
  }
}

/// Level selection chip with lesson count
class _LevelChip extends StatelessWidget {
  final String label;
  final String emoji;
  final String value;
  final int lessonCount;
  final String selected;
  final ValueChanged<String> onSelect;

  const _LevelChip(
      this.label, this.emoji, this.value, this.lessonCount, this.selected, this.onSelect);

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selected;
    return Expanded(
      child: InkWell(
        onTap: () => onSelect(value),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF4A90D9) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isSelected
                    ? const Color(0xFF4A90D9)
                    : Colors.grey.shade300),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF4A90D9).withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              AnimatedScale(
                scale: isSelected ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text('$lessonCount lessons',
                  style: TextStyle(
                      color: isSelected ? Colors.white70 : Colors.grey.shade500,
                      fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quick tool card with emoji
class _ToolCard extends StatelessWidget {
  final String label;
  final String emoji;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard(this.label, this.emoji, this.icon, this.color, this.onTap);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Day-wise lesson card with emoji and animation
class _DayCard extends StatelessWidget {
  final int day;
  final String level;
  final String title;
  final String subtitle;
  final String emoji;

  const _DayCard({
    required this.day,
    required this.level,
    required this.title,
    required this.subtitle,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Get.to(() => LessonScreen(day: day, level: level)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4A90D9).withValues(alpha: 0.15),
                      const Color(0xFF6C63FF).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4A90D9)
                                .withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Day $day',
                              style: const TextStyle(
                                  color: Color(0xFF4A90D9),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(title,
                        style: const TextStyle(
                            color: Color(0xFF1A1A2E),
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.grey.shade500, fontSize: 12)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A90D9).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_forward_ios_rounded,
                    color: Color(0xFF4A90D9), size: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
