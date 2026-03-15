import 'package:flutter/material.dart';
import 'package:edusarthi_app/features/english/data/grammar_data.dart';

/// Tense Practice Screen – browse all 12 tenses with structures and examples.
class TensePracticeScreen extends StatelessWidget {
  const TensePracticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Tenses (काल)',
              style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            indicatorColor: Color(0xFF4A90D9),
            labelColor: Color(0xFF4A90D9),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: '⏺️ Present'),
              Tab(text: '⏪ Past'),
              Tab(text: '⏩ Future'),
            ],
          ),
        ),
        body: TabBarView(
          children: GrammarData.tenseStructures.map<Widget>((tenseData) {
            return _TenseTabView(tenseData);
          }).toList(),
        ),
      ),
    );
  }
}

class _TenseTabView extends StatelessWidget {
  final Map<String, dynamic> tenseData;
  const _TenseTabView(this.tenseData);

  @override
  Widget build(BuildContext context) {
    final types = tenseData['types'] as List;
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: types.length,
      itemBuilder: (context, index) {
        return _TenseTypeCard(types[index]);
      },
    );
  }
}

class _TenseTypeCard extends StatelessWidget {
  final Map<String, dynamic> typeData;
  const _TenseTypeCard(this.typeData);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ExpansionTile(
        initiallyExpanded: false,
        shape: const Border(),
        title: Text(
          typeData['type'],
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF1A1A2E)),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF4A90D9).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                typeData['structure'],
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A90D9)),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Hindi ending: ${typeData['hindi_ending']}',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(),

                // ✅ Positive Examples
                _sectionHeader('✅ Positive (सकारात्मक)', const Color(0xFF10B981)),
                ..._buildExamples(typeData['examples']),

                const SizedBox(height: 12),

                // ❌ Negative Examples
                _sectionHeader('❌ Negative (नकारात्मक)', const Color(0xFFEF4444)),
                _structureChip(typeData['negative']),
                ..._buildSentenceExamples(typeData['negative_examples']),

                const SizedBox(height: 12),

                // ❓ Interrogative Examples
                _sectionHeader('❓ Interrogative (प्रश्नवाचक)', const Color(0xFF4A90D9)),
                _structureChip(typeData['interrogative']),
                ..._buildSentenceExamples(typeData['interrogative_examples']),

                const SizedBox(height: 12),

                // ❓❌ Interrogative Negative
                _sectionHeader('❓❌ Interrogative Negative', const Color(0xFFFF6B35)),
                _structureChip(typeData['interrogative_negative']),
                ..._buildSentenceExamples(typeData['interrogative_negative_examples']),

                const SizedBox(height: 12),

                // 🔤 WH Word Examples
                _sectionHeader('🔤 WH-Word Questions (प्रश्नवाचक)', const Color(0xFF8B5CF6)),
                ..._buildSentenceExamples(typeData['wh_examples']),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(title,
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 13)),
    );
  }

  Widget _structureChip(String structure) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(structure,
          style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500)),
    );
  }

  List<Widget> _buildExamples(List examples) {
    return examples.map<Widget>((ex) {
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF10B981).withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
              color: const Color(0xFF10B981).withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🇬🇧 ${ex['positive']}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 2),
            Text('🇮🇳 ${ex['hindi']}',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildSentenceExamples(List examples) {
    return examples.map<Widget>((ex) {
      final eng = ex['sentence'] ?? ex['positive'] ?? '';
      final hnd = ex['hindi'] ?? '';
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🇬🇧 $eng',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E))),
            const SizedBox(height: 2),
            Text('🇮🇳 $hnd',
                style: TextStyle(
                    fontSize: 12, color: Colors.grey.shade600)),
          ],
        ),
      );
    }).toList();
  }
}
