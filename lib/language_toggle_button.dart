import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'language_provider.dart';

class LanguageToggleButton extends StatelessWidget {
  const LanguageToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return GestureDetector(
          onTap: () {
            languageProvider.toggleLanguage();

            // Show snackbar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  languageProvider.isHindi
                      ? '🇮🇳 हिंदी में बदल गया'
                      : '🇬🇧 Changed to English',
                ),
                backgroundColor: const Color(0xFF6C5CE7),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF6C5CE7).withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageProvider.isHindi ? '🇮🇳' : '🇬🇧',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  languageProvider.isHindi ? 'हिं' : 'EN',
                  style: const TextStyle(
                    color: Color(0xFF6C5CE7),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.language,
                  color: Color(0xFF6C5CE7),
                  size: 18,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Extended version with dropdown for more languages later
class LanguageSelector extends StatelessWidget {
  const LanguageSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return PopupMenuButton<String>(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6C5CE7).withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  languageProvider.isHindi ? '🇮🇳' : '🇬🇧',
                  style: const TextStyle(fontSize: 20),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF6C5CE7),
                  size: 20,
                ),
              ],
            ),
          ),
          color: const Color(0xFF1A1F3A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: const Color(0xFF6C5CE7).withOpacity(0.3),
            ),
          ),
          onSelected: (String languageCode) {
            languageProvider.setLanguage(languageCode);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  languageCode == 'hi'
                      ? '🇮🇳 हिंदी में बदल गया'
                      : '🇬🇧 Changed to English',
                ),
                backgroundColor: const Color(0xFF6C5CE7),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'hi',
              child: Row(
                children: [
                  const Text('🇮🇳', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  const Text(
                    'हिंदी',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (languageProvider.isHindi) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: Color(0xFF6C5CE7), size: 20),
                  ],
                ],
              ),
            ),
            PopupMenuItem<String>(
              value: 'en',
              child: Row(
                children: [
                  const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  const Text(
                    'English',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (languageProvider.isEnglish) ...[
                    const Spacer(),
                    const Icon(Icons.check, color: Color(0xFF6C5CE7), size: 20),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}