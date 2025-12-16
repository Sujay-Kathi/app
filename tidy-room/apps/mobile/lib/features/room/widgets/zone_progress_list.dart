import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ZoneProgressList extends StatelessWidget {
  const ZoneProgressList({super.key});

  @override
  Widget build(BuildContext context) {
    // Demo values
    final zones = [
      {'name': 'Bed Zone', 'icon': '🛏️', 'score': 85, 'color': AppTheme.zoneBed, 'tasks': 1},
      {'name': 'Floor Zone', 'icon': '🧹', 'score': 60, 'color': AppTheme.zoneFloor, 'tasks': 2},
      {'name': 'Desk Zone', 'icon': '📚', 'score': 75, 'color': AppTheme.zoneDesk, 'tasks': 1},
      {'name': 'Closet Zone', 'icon': '👕', 'score': 70, 'color': AppTheme.zoneCloset, 'tasks': 0},
      {'name': 'General', 'icon': '✨', 'score': 80, 'color': AppTheme.zoneGeneral, 'tasks': 1},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: zones.length,
        itemBuilder: (context, index) {
          final zone = zones[index];
          return _buildZoneCard(
            name: zone['name'] as String,
            icon: zone['icon'] as String,
            score: zone['score'] as int,
            color: zone['color'] as Color,
            pendingTasks: zone['tasks'] as int,
          );
        },
      ),
    );
  }

  Widget _buildZoneCard({
    required String name,
    required String icon,
    required int score,
    required Color color,
    required int pendingTasks,
  }) {
    return Container(
      width: 130,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              if (pendingTasks > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$pendingTasks',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: score / 100,
                    child: Container(
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$score%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
