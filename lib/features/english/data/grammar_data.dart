/// Grammar reference data from British Institute of English Language book.
/// WH Words, Pronouns, Helping Verbs, Verb Forms, Tense Structures.

class GrammarData {
  GrammarData._();

  // ══════════════════════════════════════════════
  // WH QUESTION WORDS (प्रश्नवाचक शब्द)
  // ══════════════════════════════════════════════

  static const List<Map<String, dynamic>> whWords = [
    // 1. WHEN (कब)
    {
      'category': 'When',
      'hindi': 'कब',
      'icon': '⏰',
      'words': [
        {'english': 'When', 'hindi': 'कब'},
        {'english': 'Since when / From when', 'hindi': 'कब से'},
        {'english': 'Since when to when', 'hindi': 'कब से कब तक'},
        {'english': 'From when to when', 'hindi': 'कब से कब तक'},
        {'english': 'Till when / Upto when', 'hindi': 'कब तक'},
        {'english': 'When else', 'hindi': 'और कब'},
        {'english': 'When all', 'hindi': 'कब कब'},
      ],
    },
    // 2. WHERE (कहाँ)
    {
      'category': 'Where',
      'hindi': 'कहाँ',
      'icon': '📍',
      'words': [
        {'english': 'Where', 'hindi': 'कहाँ'},
        {'english': 'Where else', 'hindi': 'और कहाँ'},
        {'english': 'Where all', 'hindi': 'कहाँ - कहाँ'},
        {'english': 'Upto where', 'hindi': 'कहाँ तक'},
        {'english': 'Till where', 'hindi': 'कहाँ तक'},
        {'english': 'From where to where', 'hindi': 'कहाँ से कहाँ तक'},
        {'english': 'Where from', 'hindi': 'कहाँ से'},
        {'english': 'From where', 'hindi': 'कहाँ से'},
        {'english': 'Towards where', 'hindi': 'किस ओर / किस तरफ'},
      ],
    },
    // 3. WHO (कौन)
    {
      'category': 'Who',
      'hindi': 'कौन',
      'icon': '👤',
      'words': [
        {'english': 'Who', 'hindi': 'कौन'},
        {'english': 'Who else', 'hindi': 'और कौन'},
        {'english': 'Who all', 'hindi': 'कौन - कौन'},
      ],
    },
    // 4. WHY (क्यों)
    {
      'category': 'Why',
      'hindi': 'क्यों',
      'icon': '❓',
      'words': [
        {'english': 'Why', 'hindi': 'क्यों'},
        {'english': 'Why not', 'hindi': 'क्यों नहीं'},
        {'english': 'But why', 'hindi': 'पर क्यों'},
        {'english': 'Why so', 'hindi': 'ऐसा क्यों'},
      ],
    },
    // 5. WHOM (किसे / किसको)
    {
      'category': 'Whom',
      'hindi': 'किसे / किसको',
      'icon': '🤝',
      'words': [
        {'english': 'Whom', 'hindi': 'किसे / किसको'},
        {'english': 'To whom', 'hindi': 'किससे'},
        {'english': 'From whom', 'hindi': 'किससे'},
        {'english': 'Towards whom', 'hindi': 'किसकी ओर'},
        {'english': 'Whom else', 'hindi': 'और किसे'},
        {'english': 'Whom all', 'hindi': 'किस - किस को'},
        {'english': 'With whom', 'hindi': 'किसके साथ'},
        {'english': 'For whom', 'hindi': 'किसके लिए'},
        {'english': 'About whom', 'hindi': 'किसके बारे में'},
        {'english': 'By whom', 'hindi': 'किसके द्वारा'},
      ],
    },
    // 6. HOW (कैसे)
    {
      'category': 'How',
      'hindi': 'कैसे',
      'icon': '🔍',
      'words': [
        {'english': 'How', 'hindi': 'कैसे'},
        {'english': 'How much + noun (uncountable)', 'hindi': 'कितना'},
        {'english': 'How many + noun (countable)', 'hindi': 'कितने'},
        {'english': 'How far', 'hindi': 'कितनी दूर'},
        {'english': 'How long', 'hindi': 'कितनी देर'},
        {'english': 'How soon', 'hindi': 'कितनी जल्दी'},
        {'english': 'How often', 'hindi': 'अक्सर कब'},
        {'english': 'How many times', 'hindi': 'कितनी बार'},
        {'english': 'Since how long / For how long', 'hindi': 'कितनी देर से'},
        {'english': 'Till how long', 'hindi': 'कितनी देर तक'},
        {'english': 'Upto how long', 'hindi': 'कितनी देर तक'},
        {'english': 'Till more how long', 'hindi': 'और कितनी देर तक'},
        {'english': 'How come', 'hindi': 'क्यों / कैसे'},
      ],
    },
    // 7. WHICH (कौन सा)
    {
      'category': 'Which',
      'hindi': 'कौन सा',
      'icon': '👆',
      'words': [
        {'english': 'Which + noun (objective)', 'hindi': 'कौन सा / कौन सी'},
        {'english': 'Which kind of / Which type of', 'hindi': 'किस प्रकार का'},
        {'english': 'Which else', 'hindi': 'और कौन सा'},
        {'english': 'Which all', 'hindi': 'कौन - कौन सा'},
      ],
    },
    // 8. WHAT (क्या)
    {
      'category': 'What',
      'hindi': 'क्या',
      'icon': '💡',
      'words': [
        {'english': 'What', 'hindi': 'क्या'},
        {'english': 'What kind of / What type of', 'hindi': 'किस प्रकार का'},
        {'english': 'What else', 'hindi': 'और क्या'},
        {'english': 'What all', 'hindi': 'क्या - क्या'},
        {'english': 'For what purpose', 'hindi': 'किस उद्देश्य के लिए'},
        {'english': 'With what purpose', 'hindi': 'किस उद्देश्य के लिए'},
        {'english': 'Till what time', 'hindi': 'किस समय तक'},
        {'english': 'Upto what time', 'hindi': 'किस समय तक'},
        {'english': 'What about / About what', 'hindi': 'किस बारे में'},
        {'english': 'At what time', 'hindi': 'किस समय पर'},
        {'english': 'What for / For what', 'hindi': 'किसलिए'},
        {'english': 'Since what time / From what time', 'hindi': 'किस समय से'},
        {'english': 'From what time to what time', 'hindi': 'किस समय से किस समय तक'},
        {'english': 'Since what time to what time', 'hindi': 'किस समय से किस समय तक'},
        {'english': 'By what time', 'hindi': 'किस समय तक'},
        {'english': 'Upto what extent', 'hindi': 'किस हद तक'},
      ],
    },
    // 9. WHOSE (किसका)
    {
      'category': 'Whose',
      'hindi': 'किसका',
      'icon': '🏷️',
      'words': [
        {'english': 'Whose + noun (objective)', 'hindi': 'किसका'},
      ],
    },
  ];

  // ══════════════════════════════════════════════
  // PRONOUNS (सर्वनाम)
  // ══════════════════════════════════════════════

  static const List<Map<String, String>> pronouns = [
    {
      'subject': 'I',
      'subject_hindi': 'मैं, मुझे',
      'object': 'Me',
      'object_hindi': 'मुझे',
      'possession': 'My',
      'possession_hindi': 'मेरा',
      'reflexive': 'Myself',
      'reflexive_hindi': 'मैं खुद',
    },
    {
      'subject': 'We',
      'subject_hindi': 'हम, हमें',
      'object': 'Us',
      'object_hindi': 'हमें',
      'possession': 'Our',
      'possession_hindi': 'हमारा',
      'reflexive': 'Ourselves',
      'reflexive_hindi': 'हम खुद',
    },
    {
      'subject': 'You',
      'subject_hindi': 'तुम, तुम्हें',
      'object': 'You',
      'object_hindi': 'तुम्हें',
      'possession': 'Your',
      'possession_hindi': 'तुम्हारा',
      'reflexive': 'Yourself',
      'reflexive_hindi': 'तुम खुद',
    },
    {
      'subject': 'They',
      'subject_hindi': 'वे, उन्हें',
      'object': 'Them',
      'object_hindi': 'उन्हें',
      'possession': 'Their',
      'possession_hindi': 'उनका',
      'reflexive': 'Themselves',
      'reflexive_hindi': 'वे खुद',
    },
    {
      'subject': 'He',
      'subject_hindi': 'वह, उसे',
      'object': 'Him',
      'object_hindi': 'उसे',
      'possession': 'His',
      'possession_hindi': 'उसका',
      'reflexive': 'Himself',
      'reflexive_hindi': 'वह खुद',
    },
    {
      'subject': 'She',
      'subject_hindi': 'वह, उसे',
      'object': 'Her',
      'object_hindi': 'उसे',
      'possession': 'Her',
      'possession_hindi': 'उसकी',
      'reflexive': 'Herself',
      'reflexive_hindi': 'वह खुद',
    },
    {
      'subject': 'It',
      'subject_hindi': 'यह, उसे',
      'object': 'Its',
      'object_hindi': 'इसे',
      'possession': 'Its',
      'possession_hindi': 'इसका / इसकी',
      'reflexive': 'Itself',
      'reflexive_hindi': 'यह / ये खुद',
    },
  ];

  // ══════════════════════════════════════════════
  // HELPING VERBS (सहायक क्रिया)
  // ══════════════════════════════════════════════

  static const List<Map<String, String>> helpingVerbs = [
    {'subject': 'I', 'present': 'Am', 'past': 'Was', 'perfect': 'Have'},
    {'subject': 'We', 'present': 'Are', 'past': 'Were', 'perfect': 'Have'},
    {'subject': 'You', 'present': 'Are', 'past': 'Were', 'perfect': 'Have'},
    {'subject': 'They', 'present': 'Are', 'past': 'Were', 'perfect': 'Have'},
    {'subject': 'He', 'present': 'Is', 'past': 'Was', 'perfect': 'Has'},
    {'subject': 'She', 'present': 'Is', 'past': 'Was', 'perfect': 'Has'},
    {'subject': 'It', 'present': 'Is', 'past': 'Was', 'perfect': 'Has'},
    {'subject': 'Name (Ram)', 'present': 'Is', 'past': 'Was', 'perfect': 'Has'},
  ];

  // ══════════════════════════════════════════════
  // VERB FORMS (क्रिया रूप)
  // ══════════════════════════════════════════════

  static const List<Map<String, String>> verbForms = [
    {'v1': 'Abide', 'v2': 'Abode', 'v3': 'Abode', 'hindi': 'पालन करना'},
    {'v1': 'Abuse', 'v2': 'Abused', 'v3': 'Abused', 'hindi': 'गाली देना'},
    {'v1': 'Admire', 'v2': 'Admired', 'v3': 'Admired', 'hindi': 'प्रशंसा करना'},
    {'v1': 'Allow', 'v2': 'Allowed', 'v3': 'Allowed', 'hindi': 'अनुमति देना'},
    {'v1': 'Appear', 'v2': 'Appeared', 'v3': 'Appeared', 'hindi': 'दिखाई देना'},
    {'v1': 'Apply', 'v2': 'Applied', 'v3': 'Applied', 'hindi': 'लागू करना'},
    {'v1': 'Arise', 'v2': 'Arose', 'v3': 'Arisen', 'hindi': 'उठना'},
    {'v1': 'Arrive', 'v2': 'Arrived', 'v3': 'Arrived', 'hindi': 'पहुँचना'},
    {'v1': 'Ask', 'v2': 'Asked', 'v3': 'Asked', 'hindi': 'पूछना'},
    {'v1': 'Attack', 'v2': 'Attacked', 'v3': 'Attacked', 'hindi': 'हमला करना'},
    {'v1': 'Awake', 'v2': 'Awoke', 'v3': 'Awoken', 'hindi': 'जागना'},
    {'v1': 'Be', 'v2': 'Was/Were', 'v3': 'Been', 'hindi': 'होना'},
    {'v1': 'Bear', 'v2': 'Bore', 'v3': 'Born/Borne', 'hindi': 'सहना'},
    {'v1': 'Beat', 'v2': 'Beat', 'v3': 'Beaten', 'hindi': 'पीटना'},
    {'v1': 'Become', 'v2': 'Became', 'v3': 'Become', 'hindi': 'बनना'},
    {'v1': 'Begin', 'v2': 'Began', 'v3': 'Begun', 'hindi': 'शुरू करना'},
    {'v1': 'Bend', 'v2': 'Bent', 'v3': 'Bent', 'hindi': 'मोड़ना'},
    {'v1': 'Bet', 'v2': 'Bet', 'v3': 'Bet', 'hindi': 'शर्त लगाना'},
    {'v1': 'Bid', 'v2': 'Bid', 'v3': 'Bid', 'hindi': 'बोली लगाना'},
    {'v1': 'Bite', 'v2': 'Bit', 'v3': 'Bitten', 'hindi': 'काटना'},
    {'v1': 'Bleed', 'v2': 'Bled', 'v3': 'Bled', 'hindi': 'खून बहना'},
    {'v1': 'Bless', 'v2': 'Blessed', 'v3': 'Blessed', 'hindi': 'आशीर्वाद देना'},
    {'v1': 'Blow', 'v2': 'Blew', 'v3': 'Blown', 'hindi': 'फूँकना'},
    {'v1': 'Boil', 'v2': 'Boiled', 'v3': 'Boiled', 'hindi': 'उबलना'},
    {'v1': 'Break', 'v2': 'Broke', 'v3': 'Broken', 'hindi': 'तोड़ना'},
    {'v1': 'Bring', 'v2': 'Brought', 'v3': 'Brought', 'hindi': 'लाना'},
    {'v1': 'Build', 'v2': 'Built', 'v3': 'Built', 'hindi': 'बनाना'},
    {'v1': 'Buy', 'v2': 'Bought', 'v3': 'Bought', 'hindi': 'खरीदना'},
    {'v1': 'Catch', 'v2': 'Caught', 'v3': 'Caught', 'hindi': 'पकड़ना'},
    {'v1': 'Choose', 'v2': 'Chose', 'v3': 'Chosen', 'hindi': 'चुनना'},
    {'v1': 'Come', 'v2': 'Came', 'v3': 'Come', 'hindi': 'आना'},
    {'v1': 'Cut', 'v2': 'Cut', 'v3': 'Cut', 'hindi': 'काटना'},
    {'v1': 'Do', 'v2': 'Did', 'v3': 'Done', 'hindi': 'करना'},
    {'v1': 'Draw', 'v2': 'Drew', 'v3': 'Drawn', 'hindi': 'खींचना'},
    {'v1': 'Drink', 'v2': 'Drank', 'v3': 'Drunk', 'hindi': 'पीना'},
    {'v1': 'Drive', 'v2': 'Drove', 'v3': 'Driven', 'hindi': 'चलाना'},
    {'v1': 'Eat', 'v2': 'Ate', 'v3': 'Eaten', 'hindi': 'खाना'},
    {'v1': 'Fall', 'v2': 'Fell', 'v3': 'Fallen', 'hindi': 'गिरना'},
    {'v1': 'Feel', 'v2': 'Felt', 'v3': 'Felt', 'hindi': 'महसूस करना'},
    {'v1': 'Find', 'v2': 'Found', 'v3': 'Found', 'hindi': 'खोजना'},
    {'v1': 'Fly', 'v2': 'Flew', 'v3': 'Flown', 'hindi': 'उड़ना'},
    {'v1': 'Forget', 'v2': 'Forgot', 'v3': 'Forgotten', 'hindi': 'भूलना'},
    {'v1': 'Get', 'v2': 'Got', 'v3': 'Got/Gotten', 'hindi': 'पाना'},
    {'v1': 'Give', 'v2': 'Gave', 'v3': 'Given', 'hindi': 'देना'},
    {'v1': 'Go', 'v2': 'Went', 'v3': 'Gone', 'hindi': 'जाना'},
    {'v1': 'Grow', 'v2': 'Grew', 'v3': 'Grown', 'hindi': 'उगना'},
    {'v1': 'Have', 'v2': 'Had', 'v3': 'Had', 'hindi': 'रखना'},
    {'v1': 'Hear', 'v2': 'Heard', 'v3': 'Heard', 'hindi': 'सुनना'},
    {'v1': 'Hide', 'v2': 'Hid', 'v3': 'Hidden', 'hindi': 'छुपना'},
    {'v1': 'Hit', 'v2': 'Hit', 'v3': 'Hit', 'hindi': 'मारना'},
    {'v1': 'Hold', 'v2': 'Held', 'v3': 'Held', 'hindi': 'पकड़ना'},
    {'v1': 'Keep', 'v2': 'Kept', 'v3': 'Kept', 'hindi': 'रखना'},
    {'v1': 'Know', 'v2': 'Knew', 'v3': 'Known', 'hindi': 'जानना'},
    {'v1': 'Learn', 'v2': 'Learnt', 'v3': 'Learnt', 'hindi': 'सीखना'},
    {'v1': 'Leave', 'v2': 'Left', 'v3': 'Left', 'hindi': 'छोड़ना'},
    {'v1': 'Lose', 'v2': 'Lost', 'v3': 'Lost', 'hindi': 'खोना'},
    {'v1': 'Make', 'v2': 'Made', 'v3': 'Made', 'hindi': 'बनाना'},
    {'v1': 'Meet', 'v2': 'Met', 'v3': 'Met', 'hindi': 'मिलना'},
    {'v1': 'Pay', 'v2': 'Paid', 'v3': 'Paid', 'hindi': 'भुगतान करना'},
    {'v1': 'Put', 'v2': 'Put', 'v3': 'Put', 'hindi': 'रखना'},
    {'v1': 'Read', 'v2': 'Read', 'v3': 'Read', 'hindi': 'पढ़ना'},
    {'v1': 'Ride', 'v2': 'Rode', 'v3': 'Ridden', 'hindi': 'सवारी करना'},
    {'v1': 'Ring', 'v2': 'Rang', 'v3': 'Rung', 'hindi': 'बजना'},
    {'v1': 'Run', 'v2': 'Ran', 'v3': 'Run', 'hindi': 'दौड़ना'},
    {'v1': 'Say', 'v2': 'Said', 'v3': 'Said', 'hindi': 'कहना'},
    {'v1': 'See', 'v2': 'Saw', 'v3': 'Seen', 'hindi': 'देखना'},
    {'v1': 'Sell', 'v2': 'Sold', 'v3': 'Sold', 'hindi': 'बेचना'},
    {'v1': 'Send', 'v2': 'Sent', 'v3': 'Sent', 'hindi': 'भेजना'},
    {'v1': 'Sing', 'v2': 'Sang', 'v3': 'Sung', 'hindi': 'गाना'},
    {'v1': 'Sit', 'v2': 'Sat', 'v3': 'Sat', 'hindi': 'बैठना'},
    {'v1': 'Sleep', 'v2': 'Slept', 'v3': 'Slept', 'hindi': 'सोना'},
    {'v1': 'Speak', 'v2': 'Spoke', 'v3': 'Spoken', 'hindi': 'बोलना'},
    {'v1': 'Stand', 'v2': 'Stood', 'v3': 'Stood', 'hindi': 'खड़ा होना'},
    {'v1': 'Swim', 'v2': 'Swam', 'v3': 'Swum', 'hindi': 'तैरना'},
    {'v1': 'Take', 'v2': 'Took', 'v3': 'Taken', 'hindi': 'लेना'},
    {'v1': 'Teach', 'v2': 'Taught', 'v3': 'Taught', 'hindi': 'पढ़ाना'},
    {'v1': 'Tell', 'v2': 'Told', 'v3': 'Told', 'hindi': 'बताना'},
    {'v1': 'Think', 'v2': 'Thought', 'v3': 'Thought', 'hindi': 'सोचना'},
    {'v1': 'Throw', 'v2': 'Threw', 'v3': 'Thrown', 'hindi': 'फेंकना'},
    {'v1': 'Understand', 'v2': 'Understood', 'v3': 'Understood', 'hindi': 'समझना'},
    {'v1': 'Wake', 'v2': 'Woke', 'v3': 'Woken', 'hindi': 'जागना'},
    {'v1': 'Wear', 'v2': 'Wore', 'v3': 'Worn', 'hindi': 'पहनना'},
    {'v1': 'Win', 'v2': 'Won', 'v3': 'Won', 'hindi': 'जीतना'},
    {'v1': 'Write', 'v2': 'Wrote', 'v3': 'Written', 'hindi': 'लिखना'},
  ];

  // ══════════════════════════════════════════════
  // TENSE STRUCTURES (काल संरचना)
  // ══════════════════════════════════════════════

  static const List<Map<String, dynamic>> tenseStructures = [
    // PRESENT TENSE (वर्तमान काल)
    {
      'tense': 'Present',
      'hindi': 'वर्तमान काल',
      'icon': '⏺️',
      'types': [
        {
          'type': 'Simple (साधारण)',
          'structure': 'Subject + V1/V1+s/es + Object',
          'helping_verb': 'Do / Does',
          'hindi_ending': 'ता है / ती है / ते हैं',
          'examples': [
            {'positive': 'I go to school.', 'hindi': 'मैं स्कूल जाता हूँ।'},
            {'positive': 'He plays cricket.', 'hindi': 'वह क्रिकेट खेलता है।'},
          ],
          'negative': 'Subject + do/does + not + V1 + Object',
          'negative_examples': [
            {'sentence': 'I do not go to school.', 'hindi': 'मैं स्कूल नहीं जाता हूँ।'},
            {'sentence': 'He does not play cricket.', 'hindi': 'वह क्रिकेट नहीं खेलता है।'},
          ],
          'interrogative': 'Do/Does + Subject + V1 + Object?',
          'interrogative_examples': [
            {'sentence': 'Do you go to school?', 'hindi': 'क्या तुम स्कूल जाते हो?'},
            {'sentence': 'Does he play cricket?', 'hindi': 'क्या वह क्रिकेट खेलता है?'},
          ],
          'interrogative_negative': 'Do/Does + Subject + not + V1 + Object?',
          'interrogative_negative_examples': [
            {'sentence': 'Do you not go to school?', 'hindi': 'क्या तुम स्कूल नहीं जाते हो?'},
          ],
          'wh_examples': [
            {'sentence': 'Where do you go?', 'hindi': 'तुम कहाँ जाते हो?'},
            {'sentence': 'Why does he play?', 'hindi': 'वह क्यों खेलता है?'},
          ],
        },
        {
          'type': 'Continuous (अपूर्ण)',
          'structure': 'Subject + is/am/are + V1+ing + Object',
          'helping_verb': 'Is / Am / Are',
          'hindi_ending': 'रहा है / रही है / रहे हैं',
          'examples': [
            {'positive': 'I am reading a book.', 'hindi': 'मैं एक किताब पढ़ रहा हूँ।'},
            {'positive': 'She is cooking food.', 'hindi': 'वह खाना बना रही है।'},
          ],
          'negative': 'Subject + is/am/are + not + V1+ing + Object',
          'negative_examples': [
            {'sentence': 'I am not reading a book.', 'hindi': 'मैं किताब नहीं पढ़ रहा हूँ।'},
          ],
          'interrogative': 'Is/Am/Are + Subject + V1+ing + Object?',
          'interrogative_examples': [
            {'sentence': 'Are you reading a book?', 'hindi': 'क्या तुम किताब पढ़ रहे हो?'},
          ],
          'interrogative_negative': 'Is/Am/Are + Subject + not + V1+ing + Object?',
          'interrogative_negative_examples': [
            {'sentence': 'Is she not cooking food?', 'hindi': 'क्या वह खाना नहीं बना रही है?'},
          ],
          'wh_examples': [
            {'sentence': 'What are you reading?', 'hindi': 'तुम क्या पढ़ रहे हो?'},
          ],
        },
        {
          'type': 'Perfect (पूर्ण)',
          'structure': 'Subject + has/have + V3 + Object',
          'helping_verb': 'Has / Have',
          'hindi_ending': 'चुका है / चुकी है / चुके हैं',
          'examples': [
            {'positive': 'I have eaten food.', 'hindi': 'मैं खाना खा चुका हूँ।'},
            {'positive': 'She has finished her work.', 'hindi': 'वह अपना काम पूरा कर चुकी है।'},
          ],
          'negative': 'Subject + has/have + not + V3 + Object',
          'negative_examples': [
            {'sentence': 'I have not eaten food.', 'hindi': 'मैंने खाना नहीं खाया है।'},
          ],
          'interrogative': 'Has/Have + Subject + V3 + Object?',
          'interrogative_examples': [
            {'sentence': 'Have you eaten food?', 'hindi': 'क्या तुमने खाना खा लिया है?'},
          ],
          'interrogative_negative': 'Has/Have + Subject + not + V3 + Object?',
          'interrogative_negative_examples': [
            {'sentence': 'Has she not finished?', 'hindi': 'क्या वह पूरा नहीं कर चुकी है?'},
          ],
          'wh_examples': [
            {'sentence': 'What have you done?', 'hindi': 'तुमने क्या किया है?'},
          ],
        },
        {
          'type': 'Perfect Continuous (पूर्ण अपूर्ण)',
          'structure': 'Subject + has/have + been + V1+ing + since/for',
          'helping_verb': 'Has been / Have been',
          'hindi_ending': 'रहा है / रही है (कुछ समय से)',
          'examples': [
            {'positive': 'I have been studying since morning.', 'hindi': 'मैं सुबह से पढ़ रहा हूँ।'},
          ],
          'negative': 'Subject + has/have + not + been + V1+ing',
          'negative_examples': [
            {'sentence': 'I have not been studying.', 'hindi': 'मैं नहीं पढ़ रहा हूँ।'},
          ],
          'interrogative': 'Has/Have + Subject + been + V1+ing?',
          'interrogative_examples': [
            {'sentence': 'Have you been studying?', 'hindi': 'क्या तुम पढ़ रहे हो?'},
          ],
          'interrogative_negative': 'Has/Have + Subject + not + been + V1+ing?',
          'interrogative_negative_examples': [
            {'sentence': 'Have you not been studying?', 'hindi': 'क्या तुम नहीं पढ़ रहे हो?'},
          ],
          'wh_examples': [
            {'sentence': 'How long have you been studying?', 'hindi': 'तुम कितने समय से पढ़ रहे हो?'},
          ],
        },
      ],
    },
    // PAST TENSE (भूतकाल)
    {
      'tense': 'Past',
      'hindi': 'भूतकाल',
      'icon': '⏪',
      'types': [
        {
          'type': 'Simple (साधारण)',
          'structure': 'Subject + V2 + Object',
          'helping_verb': 'Did',
          'hindi_ending': 'ता था / ती थी / ते थे',
          'examples': [
            {'positive': 'I went to school.', 'hindi': 'मैं स्कूल गया।'},
            {'positive': 'She cooked food.', 'hindi': 'उसने खाना बनाया।'},
          ],
          'negative': 'Subject + did + not + V1 + Object',
          'negative_examples': [
            {'sentence': 'I did not go to school.', 'hindi': 'मैं स्कूल नहीं गया।'},
          ],
          'interrogative': 'Did + Subject + V1 + Object?',
          'interrogative_examples': [
            {'sentence': 'Did you go to school?', 'hindi': 'क्या तुम स्कूल गए?'},
          ],
          'interrogative_negative': 'Did + Subject + not + V1 + Object?',
          'interrogative_negative_examples': [
            {'sentence': 'Did you not go to school?', 'hindi': 'क्या तुम स्कूल नहीं गए?'},
          ],
          'wh_examples': [
            {'sentence': 'Where did you go?', 'hindi': 'तुम कहाँ गए?'},
          ],
        },
        {
          'type': 'Continuous (अपूर्ण)',
          'structure': 'Subject + was/were + V1+ing + Object',
          'helping_verb': 'Was / Were',
          'hindi_ending': 'रहा था / रही थी / रहे थे',
          'examples': [
            {'positive': 'I was reading a book.', 'hindi': 'मैं किताब पढ़ रहा था।'},
          ],
          'negative': 'Subject + was/were + not + V1+ing + Object',
          'negative_examples': [
            {'sentence': 'I was not reading.', 'hindi': 'मैं नहीं पढ़ रहा था।'},
          ],
          'interrogative': 'Was/Were + Subject + V1+ing?',
          'interrogative_examples': [
            {'sentence': 'Were you reading?', 'hindi': 'क्या तुम पढ़ रहे थे?'},
          ],
          'interrogative_negative': 'Was/Were + Subject + not + V1+ing?',
          'interrogative_negative_examples': [
            {'sentence': 'Was he not reading?', 'hindi': 'क्या वह नहीं पढ़ रहा था?'},
          ],
          'wh_examples': [
            {'sentence': 'What were you reading?', 'hindi': 'तुम क्या पढ़ रहे थे?'},
          ],
        },
        {
          'type': 'Perfect (पूर्ण)',
          'structure': 'Subject + had + V3 + Object',
          'helping_verb': 'Had',
          'hindi_ending': 'चुका था / चुकी थी / चुके थे',
          'examples': [
            {'positive': 'I had eaten food.', 'hindi': 'मैं खाना खा चुका था।'},
          ],
          'negative': 'Subject + had + not + V3',
          'negative_examples': [
            {'sentence': 'I had not eaten food.', 'hindi': 'मैंने खाना नहीं खाया था।'},
          ],
          'interrogative': 'Had + Subject + V3?',
          'interrogative_examples': [
            {'sentence': 'Had you eaten food?', 'hindi': 'क्या तुमने खाना खाया था?'},
          ],
          'interrogative_negative': 'Had + Subject + not + V3?',
          'interrogative_negative_examples': [
            {'sentence': 'Had you not eaten?', 'hindi': 'क्या तुमने नहीं खाया था?'},
          ],
          'wh_examples': [
            {'sentence': 'What had you eaten?', 'hindi': 'तुमने क्या खाया था?'},
          ],
        },
        {
          'type': 'Perfect Continuous (पूर्ण अपूर्ण)',
          'structure': 'Subject + had + been + V1+ing + since/for',
          'helping_verb': 'Had been',
          'hindi_ending': 'रहा था (कुछ समय से)',
          'examples': [
            {'positive': 'I had been studying for 2 hours.', 'hindi': 'मैं 2 घंटे से पढ़ रहा था।'},
          ],
          'negative': 'Subject + had + not + been + V1+ing',
          'negative_examples': [
            {'sentence': 'I had not been studying.', 'hindi': 'मैं नहीं पढ़ रहा था।'},
          ],
          'interrogative': 'Had + Subject + been + V1+ing?',
          'interrogative_examples': [
            {'sentence': 'Had you been studying?', 'hindi': 'क्या तुम पढ़ रहे थे?'},
          ],
          'interrogative_negative': 'Had + Subject + not + been + V1+ing?',
          'interrogative_negative_examples': [
            {'sentence': 'Had you not been studying?', 'hindi': 'क्या तुम नहीं पढ़ रहे थे?'},
          ],
          'wh_examples': [
            {'sentence': 'How long had you been studying?', 'hindi': 'तुम कितने समय से पढ़ रहे थे?'},
          ],
        },
      ],
    },
    // FUTURE TENSE (भविष्यकाल)
    {
      'tense': 'Future',
      'hindi': 'भविष्यकाल',
      'icon': '⏩',
      'types': [
        {
          'type': 'Simple (साधारण)',
          'structure': 'Subject + will/shall + V1 + Object',
          'helping_verb': 'Will / Shall',
          'hindi_ending': 'गा / गी / गे',
          'examples': [
            {'positive': 'I will go to school.', 'hindi': 'मैं स्कूल जाऊँगा।'},
            {'positive': 'She will cook food.', 'hindi': 'वह खाना बनाएगी।'},
          ],
          'negative': 'Subject + will/shall + not + V1',
          'negative_examples': [
            {'sentence': 'I will not go to school.', 'hindi': 'मैं स्कूल नहीं जाऊँगा।'},
          ],
          'interrogative': 'Will/Shall + Subject + V1?',
          'interrogative_examples': [
            {'sentence': 'Will you go to school?', 'hindi': 'क्या तुम स्कूल जाओगे?'},
          ],
          'interrogative_negative': 'Will/Shall + Subject + not + V1?',
          'interrogative_negative_examples': [
            {'sentence': 'Will you not go?', 'hindi': 'क्या तुम नहीं जाओगे?'},
          ],
          'wh_examples': [
            {'sentence': 'Where will you go?', 'hindi': 'तुम कहाँ जाओगे?'},
          ],
        },
        {
          'type': 'Continuous (अपूर्ण)',
          'structure': 'Subject + will be + V1+ing + Object',
          'helping_verb': 'Will be',
          'hindi_ending': 'रहा होगा / रही होगी / रहे होंगे',
          'examples': [
            {'positive': 'I will be playing cricket.', 'hindi': 'मैं क्रिकेट खेल रहा होऊँगा।'},
          ],
          'negative': 'Subject + will + not + be + V1+ing',
          'negative_examples': [
            {'sentence': 'I will not be playing.', 'hindi': 'मैं नहीं खेल रहा होऊँगा।'},
          ],
          'interrogative': 'Will + Subject + be + V1+ing?',
          'interrogative_examples': [
            {'sentence': 'Will you be playing?', 'hindi': 'क्या तुम खेल रहे होगे?'},
          ],
          'interrogative_negative': 'Will + Subject + not + be + V1+ing?',
          'interrogative_negative_examples': [
            {'sentence': 'Will you not be playing?', 'hindi': 'क्या तुम नहीं खेल रहे होगे?'},
          ],
          'wh_examples': [
            {'sentence': 'What will you be doing?', 'hindi': 'तुम क्या कर रहे होगे?'},
          ],
        },
        {
          'type': 'Perfect (पूर्ण)',
          'structure': 'Subject + will have + V3 + Object',
          'helping_verb': 'Will have',
          'hindi_ending': 'चुका होगा / चुकी होगी / चुके होंगे',
          'examples': [
            {'positive': 'I will have finished my work.', 'hindi': 'मैं अपना काम पूरा कर चुका होऊँगा।'},
          ],
          'negative': 'Subject + will + not + have + V3',
          'negative_examples': [
            {'sentence': 'I will not have finished.', 'hindi': 'मैं पूरा नहीं कर चुका होऊँगा।'},
          ],
          'interrogative': 'Will + Subject + have + V3?',
          'interrogative_examples': [
            {'sentence': 'Will you have finished?', 'hindi': 'क्या तुम पूरा कर चुके होगे?'},
          ],
          'interrogative_negative': 'Will + Subject + not + have + V3?',
          'interrogative_negative_examples': [
            {'sentence': 'Will you not have finished?', 'hindi': 'क्या तुम पूरा नहीं कर चुके होगे?'},
          ],
          'wh_examples': [
            {'sentence': 'What will you have done?', 'hindi': 'तुम क्या कर चुके होगे?'},
          ],
        },
        {
          'type': 'Perfect Continuous (पूर्ण अपूर्ण)',
          'structure': 'Subject + will have been + V1+ing + since/for',
          'helping_verb': 'Will have been',
          'hindi_ending': 'रहा होगा (कुछ समय से)',
          'examples': [
            {'positive': 'I will have been studying for 3 hours.', 'hindi': 'मैं 3 घंटे से पढ़ रहा होऊँगा।'},
          ],
          'negative': 'Subject + will + not + have been + V1+ing',
          'negative_examples': [
            {'sentence': 'I will not have been studying.', 'hindi': 'मैं नहीं पढ़ रहा होऊँगा।'},
          ],
          'interrogative': 'Will + Subject + have been + V1+ing?',
          'interrogative_examples': [
            {'sentence': 'Will you have been studying?', 'hindi': 'क्या तुम पढ़ रहे होगे?'},
          ],
          'interrogative_negative': 'Will + Subject + not + have been + V1+ing?',
          'interrogative_negative_examples': [
            {'sentence': 'Will you not have been studying?', 'hindi': 'क्या तुम नहीं पढ़ रहे होगे?'},
          ],
          'wh_examples': [
            {'sentence': 'How long will you have been studying?', 'hindi': 'तुम कितने समय से पढ़ रहे होगे?'},
          ],
        },
      ],
    },
  ];

  // ══════════════════════════════════════════════
  // GRAMMAR TOPICS LIST
  // ══════════════════════════════════════════════

  static const List<Map<String, String>> grammarTopics = [
    {'id': 'wh_words', 'title': 'WH Question Words', 'hindi': 'प्रश्नवाचक शब्द', 'emoji': '❓', 'description': 'When, Where, Who, Why, How, What, Which, Whom, Whose'},
    {'id': 'pronouns', 'title': 'Pronouns', 'hindi': 'सर्वनाम', 'emoji': '👤', 'description': 'Subject, Object, Possession, Reflexive Pronouns'},
    {'id': 'helping_verbs', 'title': 'Helping Verbs', 'hindi': 'सहायक क्रिया', 'emoji': '🔧', 'description': 'Is/Am/Are, Was/Were, Has/Have with each Subject'},
    {'id': 'verb_forms', 'title': 'Verb Forms', 'hindi': 'क्रिया रूप', 'emoji': '📝', 'description': 'V1, V2, V3 forms of common verbs'},
    {'id': 'tenses', 'title': 'Tenses', 'hindi': 'काल', 'emoji': '⏰', 'description': 'Past, Present, Future - All 12 tense types'},
  ];
}
