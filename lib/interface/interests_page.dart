import 'package:flutter/material.dart';

class InterestsPage extends StatefulWidget {
  const InterestsPage({super.key});

  @override
  State<InterestsPage> createState() => _InterestsPageState();
}

class _InterestsPageState extends State<InterestsPage> {
  final Map<String, List<Map<String, dynamic>>> _categories = {
    'Lifestyle': [
      {'label': 'Fashion', 'icon': '👗'},
      {'label': 'Beauty', 'icon': '💄'},
      {'label': 'Fitness', 'icon': '🏋️'},
      {'label': 'Wellness', 'icon': '🧘'},
      {'label': 'Travel', 'icon': '✈️'},
      {'label': 'Food', 'icon': '🍜'},
    ],
    'Creative': [
      {'label': 'Photography', 'icon': '📸'},
      {'label': 'Art', 'icon': '🎨'},
      {'label': 'Music', 'icon': '🎵'},
      {'label': 'Writing', 'icon': '✍️'},
      {'label': 'DIY', 'icon': '🔨'},
      {'label': 'Dance', 'icon': '💃'},
    ],
    'Knowledge': [
      {'label': 'Tech', 'icon': '💻'},
      {'label': 'Science', 'icon': '🔬'},
      {'label': 'Business', 'icon': '📊'},
      {'label': 'Finance', 'icon': '💰'},
      {'label': 'History', 'icon': '📜'},
      {'label': 'Books', 'icon': '📚'},
    ],
    'Entertainment': [
      {'label': 'Movies', 'icon': '🎬'},
      {'label': 'Gaming', 'icon': '🎮'},
      {'label': 'Sports', 'icon': '⚽'},
      {'label': 'Anime', 'icon': '🌸'},
      {'label': 'Podcasts', 'icon': '🎙️'},
      {'label': 'Comedy', 'icon': '😂'},
    ],
  };

  final Set<String> _selected = {'Fashion', 'Beauty', 'Travel', 'Photography', 'Music'};

  final LinearGradient _gradient = const LinearGradient(
    colors: [Color(0xFFF48FB1), Color(0xFFF06292)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCE4EC),
      body: Column(
        children: [
          // Header
          Container(
            decoration: BoxDecoration(gradient: _gradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.chevron_left, color: Colors.white, size: 22),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'My Interests',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(width: 38),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subtitle
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.pink.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF06292).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.auto_awesome, color: Color(0xFFF06292), size: 20),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Select topics you love! We\'ll personalize your feed based on your interests.',
                            style: TextStyle(color: Color(0xFF757575), fontSize: 13, height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${_selected.length} selected',
                      style: const TextStyle(color: Color(0xFFF06292), fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Categories
                  ..._categories.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key.toUpperCase(),
                          style: const TextStyle(
                              color: Color(0xFFB0BEC5), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.5),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: entry.value.map((item) {
                            final isSelected = _selected.contains(item['label']);
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selected.remove(item['label']);
                                  } else {
                                    _selected.add(item['label']);
                                  }
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  gradient: isSelected ? _gradient : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : const Color(0xFFE0E0E0),
                                  ),
                                  boxShadow: isSelected
                                      ? [BoxShadow(color: const Color(0xFFF06292).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                                      : [BoxShadow(color: Colors.pink.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2))],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(item['icon'], style: const TextStyle(fontSize: 16)),
                                    const SizedBox(width: 6),
                                    Text(
                                      item['label'],
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : const Color(0xFF424242),
                                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                      ],
                    );
                  }),

                  const SizedBox(height: 8),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: _gradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: const Color(0xFFF06292).withOpacity(0.4), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${_selected.length} interests saved!'),
                              backgroundColor: const Color(0xFFF06292),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                        child: const Text('Save Interests',
                            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}