import 'package:flutter/material.dart';
import '../models/astrology_type_model.dart';

class FilterBottomSheet extends StatefulWidget {
  final List<AstrologyTypeModel> astrologyTypes;
  final Function(String) onApply;

  const FilterBottomSheet({
    Key? key,
    required this.astrologyTypes,
    required this.onApply,
  }) : super(key: key);

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  String? _selectedSkill;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Sort & Filter',
                  style: TextStyle(fontSize: 18, color: Colors.black),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Container(height: 3, color: Colors.black.withOpacity(0.2)),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sort By',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Radio<bool>(
                            value: true,
                            groupValue: true,
                            onChanged: (value) {},
                            activeColor: Colors.black,
                          ),
                          const Expanded(
                            child: Text(
                              'Skills',
                              style: TextStyle(fontSize: 16, color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(width: 1, color: Colors.black),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    itemCount: widget.astrologyTypes.length,
                    itemBuilder: (context, index) {
                      final astrologyType = widget.astrologyTypes[index];
                      if (astrologyType.astrologyTypeStatus.toLowerCase() != 'active') {
                        return const SizedBox.shrink();
                      }

                      return RadioListTile<String>(
                        title: Text(astrologyType.astrologyTypeName),
                        value: astrologyType.astrologyTypeName,
                        groupValue: _selectedSkill,
                        activeColor: Colors.black,
                        onChanged: (value) => setState(() => _selectedSkill = value),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(height: 3, color: Colors.black.withOpacity(0.2)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (_selectedSkill != null) {
                      widget.onApply(_selectedSkill!);
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFD5621),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}