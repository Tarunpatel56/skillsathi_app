import 'package:flutter/material.dart';
import 'package:edusarthi_app/features/english/data/grammar_data.dart';
import 'package:edusarthi_app/features/english/screens/tense_practice_screen.dart';

/// Grammar Topics Screen – browse WH Words, Pronouns, Helping Verbs, Verb Forms, Tenses.
class GrammarTopicsScreen extends StatelessWidget {
  const GrammarTopicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Grammar Topics (व्याकरण)',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: GrammarData.grammarTopics.length,
        itemBuilder: (context, index) {
          final topic = GrammarData.grammarTopics[index];
          return _TopicCard(
            id: topic['id']!,
            title: topic['title']!,
            hindi: topic['hindi']!,
            emoji: topic['emoji']!,
            description: topic['description']!,
          );
        },
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String id, title, hindi, emoji, description;
  const _TopicCard({
    required this.id,
    required this.title,
    required this.hindi,
    required this.emoji,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => _navigateToDetail(context),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 26)),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('$title ($hindi)',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF1A1A2E))),
                      const SizedBox(height: 4),
                      Text(description,
                          style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: Color(0xFF4A90D9)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(BuildContext context) {
    Widget screen;
    switch (id) {
      case 'wh_words':
        screen = const _WHWordsScreen();
        break;
      case 'pronouns':
        screen = const _PronounsScreen();
        break;
      case 'helping_verbs':
        screen = const _HelpingVerbsScreen();
        break;
      case 'verb_forms':
        screen = const _VerbFormsScreen();
        break;
      case 'tenses':
        screen = const TensePracticeScreen();
        break;
      default:
        return;
    }
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

// ══════════════════════════════════════════════
// WH WORDS SCREEN
// ══════════════════════════════════════════════

class _WHWordsScreen extends StatelessWidget {
  const _WHWordsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('WH Question Words (प्रश्नवाचक शब्द)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: GrammarData.whWords.length,
        itemBuilder: (context, index) {
          final category = GrammarData.whWords[index];
          return _WHCategoryCard(category);
        },
      ),
    );
  }
}

class _WHCategoryCard extends StatelessWidget {
  final Map<String, dynamic> category;
  const _WHCategoryCard(this.category);

  @override
  Widget build(BuildContext context) {
    final words = category['words'] as List;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        leading: Text(category['icon'] ?? '📖',
            style: const TextStyle(fontSize: 24)),
        title: Text(
          '${category['category']} (${category['hindi']})',
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
              fontSize: 16),
        ),
        subtitle: Text('${words.length} variants',
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        shape: const Border(),
        children: words.map<Widget>((w) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.arrow_right, size: 18, color: Color(0xFF4A90D9)),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(children: [
                      TextSpan(
                        text: '${w['english']}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1A1A2E),
                            fontSize: 13),
                      ),
                      TextSpan(
                        text: '  →  ${w['hindi']}',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13),
                      ),
                    ]),
                  ),
                ),
              ],
            ),
          );
        }).toList()
          ..add(const SizedBox(height: 10)),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// PRONOUNS SCREEN
// ══════════════════════════════════════════════

class _PronounsScreen extends StatelessWidget {
  const _PronounsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pronouns (सर्वनाम)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90D9), Color(0xFF357ABD)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Text('👤 Pronouns / सर्वनाम',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Subject, Object, Possession & Reflexive',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90D9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                      child: Text('Subject',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                  Expanded(
                      child: Text('Object',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                  Expanded(
                      child: Text('Possession',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                  Expanded(
                      child: Text('Reflexive',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12))),
                ],
              ),
            ),

            // Table Rows
            ...GrammarData.pronouns.asMap().entries.map((entry) {
              final p = entry.value;
              final isEven = entry.key % 2 == 0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: isEven ? Colors.white : Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['subject']!,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1A1A2E))),
                          Text(p['subject_hindi']!,
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['object']!,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF1A1A2E))),
                          Text(p['object_hindi']!,
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['possession']!,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF1A1A2E))),
                          Text(p['possession_hindi']!,
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p['reflexive']!,
                              style: const TextStyle(
                                  fontSize: 13, color: Color(0xFF1A1A2E))),
                          Text(p['reflexive_hindi']!,
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// HELPING VERBS SCREEN
// ══════════════════════════════════════════════

class _HelpingVerbsScreen extends StatelessWidget {
  const _HelpingVerbsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Helping Verbs (सहायक क्रिया)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Column(
                children: [
                  Text('🔧 Helping Verbs / सहायक क्रिया',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Is/Am/Are, Was/Were, Has/Have',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFF10B981),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                      flex: 2,
                      child: Text('Subject',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13))),
                  Expanded(
                      child: Text('Present\n(Is/Am/Are)',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11))),
                  Expanded(
                      child: Text('Past\n(Was/Were)',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11))),
                  Expanded(
                      child: Text('Perfect\n(Has/Have)',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 11))),
                ],
              ),
            ),

            ...GrammarData.helpingVerbs.asMap().entries.map((entry) {
              final h = entry.value;
              final isEven = entry.key % 2 == 0;
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: isEven ? Colors.white : Colors.grey.shade50,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(h['subject']!,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF1A1A2E))),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(h['present']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF4A90D9))),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF6B35).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(h['past']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFFFF6B35))),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(h['perfect']!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Color(0xFF10B981))),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 Remember (याद रखें):',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF6B35))),
                  SizedBox(height: 6),
                  Text('• I → Am (मैं)\n• He/She/It/Name → Is, Was, Has\n• We/You/They → Are, Were, Have',
                      style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1A1A2E),
                          height: 1.6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════
// VERB FORMS SCREEN
// ══════════════════════════════════════════════

class _VerbFormsScreen extends StatelessWidget {
  const _VerbFormsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Verb Forms (क्रिया रूप)',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ),
      body: Column(
        children: [
          // Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFE55D2B)],
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Column(
              children: [
                Text('📝 Verb Forms / क्रिया रूप',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                SizedBox(height: 6),
                Text('V1 (Base) → V2 (Past) → V3 (Past Participle)',
                    style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),

          // Table Header
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFFF6B35),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                    child: Text('V1 (Base)',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
                Expanded(
                    child: Text('V2 (Past)',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
                Expanded(
                    child: Text('V3 (P.P.)',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
                Expanded(
                    child: Text('Hindi',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12))),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: GrammarData.verbForms.length,
              itemBuilder: (context, index) {
                final v = GrammarData.verbForms[index];
                final isEven = index % 2 == 0;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isEven ? Colors.white : Colors.grey.shade50,
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(v['v1']!,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                                color: Color(0xFF1A1A2E))),
                      ),
                      Expanded(
                        child: Text(v['v2']!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF4A90D9))),
                      ),
                      Expanded(
                        child: Text(v['v3']!,
                            style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF10B981))),
                      ),
                      Expanded(
                        child: Text(v['hindi']!,
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600)),
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
