import 'package:flutter/material.dart';

class UserFilterBar extends StatelessWidget {

  const UserFilterBar({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    required this.searchController,
    required this.onSearch,
  });
  final String selectedType;
  final Function(String) onTypeChanged;
  final TextEditingController searchController;
  final Function(String) onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: onSearch,
                ),
              ),
              const SizedBox(width: 16),
              _buildFilterChip(label: 'All', value: 'all'),
              const SizedBox(width: 8),
              _buildFilterChip(label: 'Children', value: 'child'),
              const SizedBox(width: 8),
              _buildFilterChip(label: 'Parents', value: 'parent'),
              const SizedBox(width: 8),
              _buildFilterChip(label: 'Teachers', value: 'teacher'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({required String label, required String value}) {
    return FilterChip(
      label: Text(label),
      selected: selectedType == value,
      onSelected: (bool selected) {
        if (selected) {
          onTypeChanged(value);
        }
      },
      selectedColor: Colors.blue.withOpacity(0.2),
      showCheckmark: false,
    );
  }
}
