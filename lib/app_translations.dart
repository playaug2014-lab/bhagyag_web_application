// Language Translations for Hindi and English
class AppTranslations {
  static Map<String, Map<String, String>> translations = {
    // AI Chat Screen
    'ai_chat_title': {
      'hi': '✨ AI ज्योतिष चैट',
      'en': '✨ AI Astrology Chat',
    },
    'ai_chat_welcome': {
      'hi': 'नमस्ते {name}! मैं आपका AI ज्योतिष मार्गदर्शक हूं। मैं आपकी कुंडली देख सकता हूं:\n\n'
          '🌟 सूर्य राशि: {sunSign}\n'
          '🌙 चंद्र राशि: {moonSign}\n'
          '📅 जन्म तिथि: {dob}\n'
          '🕐 जन्म समय: {tob}\n'
          '📍 जन्म स्थान: {pob}\n\n'
          'मुझसे अपनी कुंडली, वर्तमान ग्रह स्थिति या ज्योतिष के बारे में कुछ भी पूछें!',
      'en': 'Hello {name}! I\'m your AI astrology guide. I can see your birth chart:\n\n'
          '🌟 Sun Sign: {sunSign}\n'
          '🌙 Moon Sign: {moonSign}\n'
          '📅 Birth Date: {dob}\n'
          '🕐 Birth Time: {tob}\n'
          '📍 Birth Place: {pob}\n\n'
          'Ask me anything about your chart, current transits, or astrology!',
    },
    'ai_thinking': {
      'hi': 'AI सोच रहा है...',
      'en': 'AI is thinking...',
    },
    'type_message': {
      'hi': 'अपनी कुंडली के बारे में पूछें...',
      'en': 'Ask about your chart...',
    },
    'your_birth_chart': {
      'hi': '🌟 आपकी कुंडली',
      'en': '🌟 Your Birth Chart',
    },

    // Journal Screen
    'journal_title': {
      'hi': '📖 ज्योतिष डायरी',
      'en': '📖 Astro Journal',
    },
    'current_cosmic_energy': {
      'hi': 'वर्तमान ब्रह्मांडीय ऊर्जा',
      'en': 'Current Cosmic Energy',
    },
    'active_transits': {
      'hi': 'सक्रिय ग्रह गोचर:',
      'en': 'Active Transits:',
    },
    'how_feeling_today': {
      'hi': 'आज आप कैसा महसूस कर रहे हैं?',
      'en': 'How are you feeling today?',
    },
    'write_placeholder': {
      'hi': 'अपने दिन, विचारों या भावनाओं के बारे में लिखें...',
      'en': 'Write about your day, thoughts, or feelings...',
    },
    'save_entry': {
      'hi': '✨ प्रविष्टि सहेजें',
      'en': '✨ Save Entry',
    },
    'past_entries': {
      'hi': 'पिछली प्रविष्टियां',
      'en': 'Past Entries',
    },
    'entries_count': {
      'hi': '{count} प्रविष्टियां',
      'en': '{count} entries',
    },
    'no_entries': {
      'hi': 'अभी तक कोई डायरी प्रविष्टि नहीं',
      'en': 'No journal entries yet',
    },
    'start_writing': {
      'hi': 'अपनी ब्रह्मांडीय यात्रा को ट्रैक करने के लिए लिखना शुरू करें',
      'en': 'Start writing to track your cosmic journey',
    },
    'cosmic_energy_label': {
      'hi': 'ब्रह्मांडीय ऊर्जा:',
      'en': 'Cosmic energy:',
    },
    'entry_saved': {
      'hi': '✨ प्रविष्टि सफलतापूर्वक सहेजी गई!',
      'en': '✨ Entry saved successfully!',
    },
    'delete_entry': {
      'hi': 'प्रविष्टि हटाएं?',
      'en': 'Delete Entry?',
    },
    'cannot_undo': {
      'hi': 'इस क्रिया को पूर्ववत नहीं किया जा सकता।',
      'en': 'This action cannot be undone.',
    },
    'cancel': {
      'hi': 'रद्द करें',
      'en': 'Cancel',
    },
    'delete': {
      'hi': 'हटाएं',
      'en': 'Delete',
    },

    // Moods
    'mood_neutral': {
      'hi': '😊 सामान्य',
      'en': '😊 Neutral',
    },
    'mood_happy': {
      'hi': '😄 खुश',
      'en': '😄 Happy',
    },
    'mood_sad': {
      'hi': '😔 उदास',
      'en': '😔 Sad',
    },
    'mood_anxious': {
      'hi': '😰 चिंतित',
      'en': '😰 Anxious',
    },
    'mood_peaceful': {
      'hi': '😌 शांत',
      'en': '😌 Peaceful',
    },
    'mood_energetic': {
      'hi': '🔥 ऊर्जावान',
      'en': '🔥 Energetic',
    },
    'mood_tired': {
      'hi': '😴 थका हुआ',
      'en': '😴 Tired',
    },
    'mood_confident': {
      'hi': '💪 आत्मविश्वासी',
      'en': '💪 Confident',
    },

    // Birth Chart Setup
    'setup_title': {
      'hi': '🌟 आपकी कुंडली',
      'en': '🌟 Your Birth Chart',
    },
    'enter_birth_details': {
      'hi': 'अपनी जन्म विवरण दर्ज करें',
      'en': 'Enter Your Birth Details',
    },
    'setup_subtitle': {
      'hi': 'हम इसका उपयोग आपकी व्यक्तिगत ज्योतिष प्रोफ़ाइल बनाने के लिए करेंगे',
      'en': 'We\'ll use this to create your personalized astrology profile',
    },
    'personal_information': {
      'hi': 'व्यक्तिगत जानकारी',
      'en': 'Personal Information',
    },
    'full_name': {
      'hi': 'पूरा नाम',
      'en': 'Full Name',
    },
    'enter_name': {
      'hi': 'अपना पूरा नाम दर्ज करें',
      'en': 'Enter your full name',
    },
    'gender': {
      'hi': 'लिंग',
      'en': 'Gender',
    },
    'male': {
      'hi': 'पुरुष',
      'en': 'Male',
    },
    'female': {
      'hi': 'महिला',
      'en': 'Female',
    },
    'non_binary': {
      'hi': 'गैर-द्विआधारी',
      'en': 'Non-binary',
    },
    'prefer_not_say': {
      'hi': 'कहना पसंद नहीं',
      'en': 'Prefer not to say',
    },
    'birth_details': {
      'hi': 'जन्म विवरण',
      'en': 'Birth Details',
    },
    'date_of_birth': {
      'hi': 'जन्म तिथि *',
      'en': 'Date of Birth *',
    },
    'select_dob': {
      'hi': 'अपनी जन्म तिथि चुनें',
      'en': 'Select your date of birth',
    },
    'time_of_birth': {
      'hi': 'जन्म समय *',
      'en': 'Time of Birth *',
    },
    'select_tob': {
      'hi': 'अपना जन्म समय चुनें',
      'en': 'Select your time of birth',
    },
    'place_of_birth': {
      'hi': 'जन्म स्थान *',
      'en': 'Place of Birth *',
    },
    'city_country': {
      'hi': 'शहर, देश',
      'en': 'City, Country',
    },
    'time_important': {
      'hi': 'सटीक चंद्र राशि और लग्न की गणना के लिए जन्म समय महत्वपूर्ण है',
      'en': 'Time of birth is important for accurate moon sign and rising sign calculations',
    },
    'save_birth_chart': {
      'hi': 'कुंडली सहेजें',
      'en': 'Save Birth Chart',
    },
    'privacy_note': {
      'hi': '🔒 आपकी कुंडली डेटा केवल आपके डिवाइस पर संग्रहीत है और कभी किसी के साथ साझा नहीं किया जाता है।',
      'en': '🔒 Your birth chart data is stored only on your device and never shared with anyone.',
    },
    'birth_chart_saved': {
      'hi': '✨ कुंडली सफलतापूर्वक सहेजी गई!',
      'en': '✨ Birth chart saved successfully!',
    },

    // Validation Messages
    'enter_valid_name': {
      'hi': 'कृपया अपना नाम दर्ज करें',
      'en': 'Please enter your name',
    },
    'select_date': {
      'hi': 'कृपया अपनी जन्म तिथि चुनें',
      'en': 'Please select your date of birth',
    },
    'select_time': {
      'hi': 'कृपया अपना जन्म समय चुनें',
      'en': 'Please select your time of birth',
    },
    'enter_place': {
      'hi': 'कृपया अपना जन्म स्थान दर्ज करें',
      'en': 'Please enter your place of birth',
    },

    // Profile Screen
    'profile_title': {
      'hi': 'प्रोफ़ाइल',
      'en': 'Profile',
    },
    'name_label': {
      'hi': 'नाम',
      'en': 'Name',
    },
    'sun_sign_label': {
      'hi': 'सूर्य राशि',
      'en': 'Sun Sign',
    },
    'moon_sign_label': {
      'hi': 'चंद्र राशि',
      'en': 'Moon Sign',
    },
    'birth_date_label': {
      'hi': 'जन्म तिथि',
      'en': 'Birth Date',
    },
    'birth_time_label': {
      'hi': 'जन्म समय',
      'en': 'Birth Time',
    },
    'birth_place_label': {
      'hi': 'जन्म स्थान',
      'en': 'Birth Place',
    },
    'settings_notifications': {
      'hi': 'सूचनाएं',
      'en': 'Notifications',
    },
    'settings_notifications_subtitle': {
      'hi': 'दैनिक राशिफल अनुस्मारक',
      'en': 'Daily horoscope reminders',
    },
    'settings_language': {
      'hi': 'भाषा',
      'en': 'Language',
    },
    'settings_privacy': {
      'hi': 'गोपनीयता',
      'en': 'Privacy',
    },
    'settings_privacy_subtitle': {
      'hi': 'डेटा स्थानीय रूप से संग्रहीत है',
      'en': 'Data is stored locally',
    },
    'settings_help': {
      'hi': 'सहायता और समर्थन',
      'en': 'Help & Support',
    },
    'settings_help_subtitle': {
      'hi': 'अक्सर पूछे जाने वाले प्रश्न और संपर्क',
      'en': 'FAQs and contact',
    },
    'settings_about': {
      'hi': 'जानकारी',
      'en': 'About',
    },
    'settings_about_subtitle': {
      'hi': 'संस्करण 1.0.0',
      'en': 'Version 1.0.0',
    },

    // Bottom Navigation
    'nav_chat': {
      'hi': 'AI चैट',
      'en': 'AI Chat',
    },
    'nav_journal': {
      'hi': 'डायरी',
      'en': 'Journal',
    },
    'nav_profile': {
      'hi': 'प्रोफ़ाइल',
      'en': 'Profile',
    },

    // Welcome Dialog
    'welcome': {
      'hi': '✨ स्वागत है!',
      'en': '✨ Welcome!',
    },
    'welcome_message': {
      'hi': 'व्यक्तिगत ज्योतिष अंतर्दृष्टि प्राप्त करने के लिए, कृपया पहले अपनी कुंडली बनाएं।',
      'en': 'To get personalized astrology insights, please set up your birth chart first.',
    },
    'maybe_later': {
      'hi': 'बाद में',
      'en': 'Maybe Later',
    },
    'setup_now': {
      'hi': 'अभी सेटअप करें',
      'en': 'Set Up Now',
    },
    'create_birth_chart': {
      'hi': 'कुंडली बनाएं',
      'en': 'Create Birth Chart',
    },
    'setup_birth_chart_title': {
      'hi': 'अपनी कुंडली सेटअप करें',
      'en': 'Set Up Your Birth Chart',
    },
    'setup_birth_chart_subtitle': {
      'hi': 'व्यक्तिगत AI ज्योतिष अंतर्दृष्टि और विस्तृत राशिफल रीडिंग अनलॉक करने के लिए अपनी जन्म विवरण दर्ज करें।',
      'en': 'Enter your birth details to unlock personalized AI astrology insights and detailed horoscope readings.',
    },

    // Zodiac Signs in Hindi
    'aries': {
      'hi': 'मेष ♈',
      'en': 'Aries ♈',
    },
    'taurus': {
      'hi': 'वृषभ ♉',
      'en': 'Taurus ♉',
    },
    'gemini': {
      'hi': 'मिथुन ♊',
      'en': 'Gemini ♊',
    },
    'cancer': {
      'hi': 'कर्क ♋',
      'en': 'Cancer ♋',
    },
    'leo': {
      'hi': 'सिंह ♌',
      'en': 'Leo ♌',
    },
    'virgo': {
      'hi': 'कन्या ♍',
      'en': 'Virgo ♍',
    },
    'libra': {
      'hi': 'तुला ♎',
      'en': 'Libra ♎',
    },
    'scorpio': {
      'hi': 'वृश्चिक ♏',
      'en': 'Scorpio ♏',
    },
    'sagittarius': {
      'hi': 'धनु ♐',
      'en': 'Sagittarius ♐',
    },
    'capricorn': {
      'hi': 'मकर ♑',
      'en': 'Capricorn ♑',
    },
    'aquarius': {
      'hi': 'कुम्भ ♒',
      'en': 'Aquarius ♒',
    },
    'pisces': {
      'hi': 'मीन ♓',
      'en': 'Pisces ♓',
    },

    // Planets in Hindi
    'sun_planet': {
      'hi': 'सूर्य',
      'en': 'Sun',
    },
    'moon_planet': {
      'hi': 'चंद्रमा',
      'en': 'Moon',
    },
    'mars_planet': {
      'hi': 'मंगल',
      'en': 'Mars',
    },
    'mercury_planet': {
      'hi': 'बुध',
      'en': 'Mercury',
    },
    'jupiter_planet': {
      'hi': 'गुरु',
      'en': 'Jupiter',
    },
    'venus_planet': {
      'hi': 'शुक्र',
      'en': 'Venus',
    },
    'saturn_planet': {
      'hi': 'शनि',
      'en': 'Saturn',
    },
  };

  // Helper method to get translated text
  static String get(String key, String languageCode, {Map<String, String>? params}) {
    String text = translations[key]?[languageCode] ?? translations[key]?['en'] ?? key;

    // Replace parameters
    if (params != null) {
      params.forEach((key, value) {
        text = text.replaceAll('{$key}', value);
      });
    }

    return text;
  }
}