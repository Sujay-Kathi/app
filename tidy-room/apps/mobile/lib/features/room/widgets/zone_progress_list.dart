import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/room_provider.dart';
import '../../tasks/providers/task_provider.dart';

class ZoneProgressList extends StatelessWidget {
  const ZoneProgressList({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<RoomProvider, TaskProvider>(
      builder: (context, roomProvider, taskProvider, _) {
        // Get zone scores from room provider
        final zones = [
          {
            'name': 'Bed',
            'zone': 'bed',
            'icon': '🛏️',
            'score': roomProvider.zoneBed,
            'pending': _getZonePendingCount(taskProvider, 'bed'),
          },
          {
            'name': 'Floor',
            'zone': 'floor',
            'icon': '🧹',
            'score': roomProvider.zoneFloor,
            'pending': _getZonePendingCount(taskProvider, 'floor'),
          },
          {
            'name': 'Desk',
            'zone': 'desk',
            'icon': '📚',
            'score': roomProvider.zoneDesk,
            'pending': _getZonePendingCount(taskProvider, 'desk'),
          },
          {
            'name': 'Closet',
            'zone': 'closet',
            'icon': '👕',
            'score': roomProvider.zoneCloset,
            'pending': _getZonePendingCount(taskProvider, 'closet'),
          },
          {
            'name': 'General',
            'zone': 'general',
            'icon': '🧼',
            'score': roomProvider.zoneGeneral,
            'pending': _getZonePendingCount(taskProvider, 'general'),
          },
        ];

        return SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: zones.length,
            itemBuilder: (context, index) {
              final zone = zones[index];
              return _buildZoneCard(
                context,
                name: zone['name'] as String,
                zone: zone['zone'] as String,
                icon: zone['icon'] as String,
                score: zone['score'] as int,
                pendingTasks: zone['pending'] as int,
              );
            },
          ),
        );
      },
    );
  }

  int _getZonePendingCount(TaskProvider taskProvider, String zone) {
    return taskProvider.pendingTasks
        .where((t) => t['zone'] == zone)
        .length;
  }

  Widget _buildZoneCard(
    BuildContext context, {
    required String name,
    required String zone,
    required String icon,
    required int score,
    required int pendingTasks,
  }) {
    final zoneColor = AppTheme.getZoneColor(zone);
    
    return GestureDetector(
      onTap: () => context.go('/tasks'),
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: zoneColor.withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Icon
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: zoneColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 20)),
              ),
            ),
            
            // Zone Name
            Text(
              name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            
            // Score Progress
            Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: (score / 100).clamp(0.0, 1.0),
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.getCleanlinessColor(score),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ],
            ),
            
            // Pending Tasks
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '$score%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.getCleanlinessColor(score),
                  ),
                ),
                if (pendingTasks > 0) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '$pendingTasks',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
