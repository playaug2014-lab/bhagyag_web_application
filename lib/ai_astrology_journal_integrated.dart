import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:provider/provider.dart';
import 'language_provider.dart';
import 'app_translations.dart';

// AI Astrology Journal Screen - IMPROVED UI FOR ALL IPHONE SCREENS
class AIAstrologyJournalScreen extends StatefulWidget {
  final String userId;

  const AIAstrologyJournalScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<AIAstrologyJournalScreen> createState() => _AIAstrologyJournalScreenState();
}

class _AIAstrologyJournalScreenState extends State<AIAstrologyJournalScreen> {
  final TextEditingController _entryController = TextEditingController();
  final List<JournalEntry> _entries = [];
  String _selectedMood = '😊';
  String _currentMoonPhase = '';
  bool _isWriting = false;

  // Simplified mood options
  final List<Map<String, String>> _moodOptions = [
    {'emoji': '😊', 'label': 'Happy'},
    {'emoji': '😔', 'label': 'Sad'},
    {'emoji': '😰', 'label': 'Anxious'},
    {'emoji': '😌', 'label': 'Calm'},
    {'emoji': '🔥', 'label': 'Energetic'},
    {'emoji': '😴', 'label': 'Tired'},
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _loadCurrentAstroData();
  }

  String _calculateMoonPhase() {
    final now = DateTime.now();
    final daysSinceNewMoon = now.difference(DateTime(2000, 1, 6)).inDays % 29.53;

    if (daysSinceNewMoon < 3.69) return '🌑 New Moon';
    if (daysSinceNewMoon < 7.38) return '🌒 Waxing Crescent';
    if (daysSinceNewMoon < 11.07) return '🌓 First Quarter';
    if (daysSinceNewMoon < 14.77) return '🌔 Waxing Gibbous';
    if (daysSinceNewMoon < 18.46) return '🌕 Full Moon';
    if (daysSinceNewMoon < 22.15) return '🌖 Waning Gibbous';
    if (daysSinceNewMoon < 25.84) return '🌗 Last Quarter';
    return '🌘 Waning Crescent';
  }

  void _loadCurrentAstroData() {
    setState(() {
      _currentMoonPhase = _calculateMoonPhase();
    });
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = prefs.getStringList('journal_entries_${widget.userId}') ?? [];

    setState(() {
      _entries.clear();
      for (var jsonStr in entriesJson) {
        _entries.add(JournalEntry.fromJson(jsonDecode(jsonStr)));
      }
      _entries.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final entriesJson = _entries.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('journal_entries_${widget.userId}', entriesJson);
  }

  Future<void> _addEntry() async {
    if (_entryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write something first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final newEntry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.now(),
      entry: _entryController.text.trim(),
      moonPhase: _currentMoonPhase,
      mood: _selectedMood,
    );

    setState(() {
      _entries.insert(0, newEntry);
      _entryController.clear();
      _isWriting = false;
    });

    await _saveEntries();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✨ Entry saved!'),
          backgroundColor: Color(0xFFFF7213),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteEntry(String id) async {
    setState(() {
      _entries.removeWhere((entry) => entry.id == id);
    });
    await _saveEntries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5E6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF7213),
        elevation: 0,
        title: const Text(
          'Astro Journal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (!_isWriting && _entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                setState(() {
                  _isWriting = true;
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: _isWriting || _entries.isEmpty
            ? _buildWritingView()
            : _buildEntriesListView(),
      ),
    );
  }

  Widget _buildWritingView() {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenHeight < 700;
    final isVerySmallScreen = screenHeight < 650;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Moon Phase Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF7213), Color(0xFFFF8C42)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _currentMoonPhase,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 18 : 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Text(
                  _formatDate(DateTime.now()),
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: isSmallScreen ? 13 : 14,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: isSmallScreen ? 16 : 24),

          // Mood Selection
          Text(
            'How are you feeling?',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // FIXED: Mood Grid with Wrap for better overflow handling
          Wrap(
            spacing: isSmallScreen ? 8 : 10,
            runSpacing: isSmallScreen ? 8 : 10,
            children: _moodOptions.map((mood) {
              final isSelected = mood['emoji'] == _selectedMood;
              // Calculate button width based on screen size
              final buttonWidth = (screenWidth - (isSmallScreen ? 32 : 40) - (isSmallScreen ? 16 : 20)) / 3;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedMood = mood['emoji']!;
                  });
                },
                child: Container(
                  width: buttonWidth,
                  height: isSmallScreen ? 60 : 70,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFFF7213)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFFF7213)
                          : Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        mood['emoji']!,
                        style: TextStyle(fontSize: isSmallScreen ? 22 : 26),
                      ),
                      SizedBox(height: isSmallScreen ? 3 : 4),
                      Text(
                        mood['label']!,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 11,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          SizedBox(height: isSmallScreen ? 16 : 24),

          // Entry Text Area
          Text(
            'Write your thoughts',
            style: TextStyle(
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _entryController,
              minLines: isVerySmallScreen ? 3 : (isSmallScreen ? 4 : 6),
              maxLines: null,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
              decoration: const InputDecoration(
                hintText: 'How was your day? What\'s on your mind?',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),

          SizedBox(height: isSmallScreen ? 16 : 24),

          // Action Buttons
          Row(
            children: [
              if (_entries.isNotEmpty)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _isWriting = false;
                        _entryController.clear();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 14 : 16,
                      ),
                      side: const BorderSide(color: Color(0xFFFF7213)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 16,
                        color: const Color(0xFFFF7213),
                      ),
                    ),
                  ),
                ),
              if (_entries.isNotEmpty) const SizedBox(width: 12),
              Expanded(
                flex: _entries.isNotEmpty ? 1 : 2,
                child: ElevatedButton(
                  onPressed: _addEntry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7213),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 14 : 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Save Entry',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 15 : 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isSmallScreen ? 16 : 20),
        ],
      ),
    );
  }

  Widget _buildEntriesListView() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Column(
      children: [
        // Header Stats
        Container(
          margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7213), Color(0xFFFF8C42)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    _currentMoonPhase.split(' ')[0],
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 32,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    'Moon Phase',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 11 : 12,
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: isSmallScreen ? 35 : 40,
                color: Colors.white30,
              ),
              Column(
                children: [
                  Text(
                    '${_entries.length}',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 28 : 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    'Entries',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: isSmallScreen ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Entries List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            itemCount: _entries.length,
            itemBuilder: (context, index) {
              final entry = _entries[index];
              return _buildEntryCard(entry);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    return Container(
      margin: EdgeInsets.only(bottom: isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            _showEntryDetail(entry);
          },
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 14 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.mood,
                      style: TextStyle(fontSize: isSmallScreen ? 28 : 32),
                    ),
                    SizedBox(width: isSmallScreen ? 10 : 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(entry.date),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 15 : 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            entry.moonPhase,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.grey),
                      onPressed: () => _showDeleteDialog(entry.id),
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                SizedBox(height: isSmallScreen ? 10 : 12),
                Text(
                  entry.entry,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 14 : 15,
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEntryDetail(JournalEntry entry) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry.mood,
                            style: TextStyle(fontSize: isSmallScreen ? 36 : 40),
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _formatDate(entry.date),
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 17 : 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: isSmallScreen ? 2 : 4),
                                Text(
                                  entry.moonPhase,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 13 : 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: isSmallScreen ? 20 : 24),
                      Text(
                        entry.entry,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 15 : 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Entry?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteEntry(id);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Entry deleted'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }
}

class JournalEntry {
  final String id;
  final DateTime date;
  final String entry;
  final String moonPhase;
  final String mood;

  JournalEntry({
    required this.id,
    required this.date,
    required this.entry,
    required this.moonPhase,
    required this.mood,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'entry': entry,
    'moonPhase': moonPhase,
    'mood': mood,
  };

  factory JournalEntry.fromJson(Map<String, dynamic> json) => JournalEntry(
    id: json['id'],
    date: DateTime.parse(json['date']),
    entry: json['entry'],
    moonPhase: json['moonPhase'],
    mood: json['mood'],
  );
}