import 'package:flutter/material.dart';

/// Panel for filtering heatmap data by occurrence type
class HeatmapFilterPanel extends StatelessWidget {
  final Map<String, int> occurrenceCounts;
  final String? selectedType;
  final Function(String?) onTypeSelected;
  final VoidCallback onClearFilters;

  const HeatmapFilterPanel({
    super.key,
    required this.occurrenceCounts,
    required this.selectedType,
    required this.onTypeSelected,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final hasFilters = selectedType != null;

    return Container(
      constraints: const BoxConstraints(maxHeight: 400),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filtrar por tipo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (hasFilters)
                  TextButton.icon(
                    onPressed: onClearFilters,
                    icon: const Icon(Icons.clear, size: 18),
                    label: const Text('Limpar'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Type filters
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _buildTypeFilters(),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTypeFilters() {
    // Define occurrence types with icons and colors (lowercase to match backend)
    final types = [
      _TypeFilter(
        type: 'assalto',
        label: 'Assalto',
        icon: Icons.dangerous,
        color: Colors.deepOrange,
      ),
      _TypeFilter(
        type: 'roubo',
        label: 'Roubo',
        icon: Icons.phone_android,
        color: Colors.red,
      ),
      _TypeFilter(
        type: 'ameaca',
        label: 'Ameaça',
        icon: Icons.warning,
        color: Colors.amber,
      ),
      _TypeFilter(
        type: 'furto',
        label: 'Furto',
        icon: Icons.shopping_bag,
        color: Colors.orange,
      ),
      _TypeFilter(
        type: 'vandalismo',
        label: 'Vandalismo',
        icon: Icons.broken_image,
        color: Colors.purple,
      ),
      _TypeFilter(
        type: 'agressao',
        label: 'Agressão',
        icon: Icons.front_hand,
        color: Colors.deepOrange,
      ),
      _TypeFilter(
        type: 'acidente_transito',
        label: 'Acidente de Trânsito',
        icon: Icons.car_crash,
        color: Colors.blue,
      ),
      _TypeFilter(
        type: 'violencia_domestica',
        label: 'Violência Doméstica',
        icon: Icons.home,
        color: Colors.red.shade800,
      ),
      _TypeFilter(
        type: 'trafico',
        label: 'Tráfico',
        icon: Icons.medication,
        color: Colors.purple.shade900,
      ),
      _TypeFilter(
        type: 'homicidio',
        label: 'Homicídio',
        icon: Icons.warning_amber,
        color: Colors.red.shade900,
      ),
      _TypeFilter(
        type: 'desaparecimento',
        label: 'Desaparecimento',
        icon: Icons.person_search,
        color: Colors.indigo,
      ),
      _TypeFilter(
        type: 'incendio',
        label: 'Incêndio',
        icon: Icons.local_fire_department,
        color: Colors.deepOrange.shade900,
      ),
      _TypeFilter(
        type: 'perturbacao',
        label: 'Perturbação',
        icon: Icons.volume_up,
        color: Colors.amber.shade700,
      ),
      _TypeFilter(
        type: 'outros',
        label: 'Outros',
        icon: Icons.report,
        color: Colors.grey,
      ),
    ];

    return types.map((typeFilter) {
      final count = occurrenceCounts[typeFilter.type] ?? 0;
      final isSelected = selectedType == typeFilter.type;

      return ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? typeFilter.color.withOpacity(0.2)
                : typeFilter.color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            typeFilter.icon,
            color: typeFilter.color,
            size: 22,
          ),
        ),
        title: Text(
          typeFilter.label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? typeFilter.color
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        selected: isSelected,
        selectedTileColor: typeFilter.color.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        onTap: () {
          // Toggle selection
          if (isSelected) {
            onTypeSelected(null);
          } else {
            onTypeSelected(typeFilter.type);
          }
        },
      );
    }).toList();
  }
}

class _TypeFilter {
  final String type;
  final String label;
  final IconData icon;
  final Color color;

  _TypeFilter({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
  });
}
