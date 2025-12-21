import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

import '../../../core/theme/app_theme.dart';
import '../providers/room_provider.dart';
import '../../profile/providers/profile_provider.dart';

class VirtualRoom extends StatefulWidget {
  const VirtualRoom({super.key});

  @override
  State<VirtualRoom> createState() => _VirtualRoomState();
}

class _VirtualRoomState extends State<VirtualRoom> with TickerProviderStateMixin {
  late AnimationController _floatController;
  late AnimationController _sparkleController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    
    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  Color _getRoomGlowColor(int score) {
    if (score >= 90) return AppTheme.success;
    if (score >= 70) return AppTheme.secondary;
    if (score >= 40) return AppTheme.accent;
    if (score >= 20) return AppTheme.warning;
    return AppTheme.error;
  }

  String _getCleanlinessEmoji(int score) {
    if (score >= 90) return '✨';
    if (score >= 70) return '🙂';
    if (score >= 40) return '😐';
    if (score >= 20) return '😬';
    return '💥';
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RoomProvider, ProfileProvider>(
      builder: (context, roomProvider, profileProvider, _) {
        final cleanlinessScore = roomProvider.cleanlinessScore;
        final zoneBed = roomProvider.zoneBed;
        final zoneFloor = roomProvider.zoneFloor;
        final zoneDesk = roomProvider.zoneDesk;
        final zoneCloset = roomProvider.zoneCloset;
        final currentStreak = profileProvider.currentStreak;
        
        final roomGlowColor = _getRoomGlowColor(cleanlinessScore);
        final cleanlinessEmoji = _getCleanlinessEmoji(cleanlinessScore);

        return Container(
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: roomGlowColor.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Room Background
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFE0E7FF),
                        Color(0xFFC7D2FE),
                      ],
                    ),
                  ),
                ),

                // Floor
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: 80,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.lerp(
                            const Color(0xFFDEB887),
                            Colors.grey,
                            (100 - zoneFloor) / 200,
                          )!,
                          Color.lerp(
                            const Color(0xFFD2691E),
                            Colors.grey,
                            (100 - zoneFloor) / 200,
                          )!,
                        ],
                      ),
                    ),
                  ),
                ),

                // Window
                Positioned(
                  top: 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF87CEEB),
                            Color(0xFF00BFFF),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.wb_sunny_rounded,
                          color: Colors.yellow,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                ),

                // Bed (left side)
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Positioned(
                      bottom: 80 + (_floatController.value * 4),
                      left: 20,
                      child: _buildBed(zoneBed),
                    );
                  },
                ),

                // Desk (right side)
                AnimatedBuilder(
                  animation: _floatController,
                  builder: (context, child) {
                    return Positioned(
                      bottom: 80 + (_floatController.value * 3),
                      right: 20,
                      child: _buildDesk(zoneDesk),
                    );
                  },
                ),

                // Closet (far right)
                Positioned(
                  bottom: 80,
                  right: 100,
                  child: _buildCloset(zoneCloset),
                ),

                // Toys/Items on floor (if messy)
                if (zoneFloor < 70) ...[
                  Positioned(
                    bottom: 90,
                    left: 100,
                    child: _buildMessyItem('🧸', 24),
                  ),
                  Positioned(
                    bottom: 85,
                    left: 140,
                    child: _buildMessyItem('📚', 20),
                  ),
                  if (zoneFloor < 50) ...[
                    Positioned(
                      bottom: 92,
                      right: 140,
                      child: _buildMessyItem('👕', 22),
                    ),
                    Positioned(
                      bottom: 88,
                      left: 180,
                      child: _buildMessyItem('🎮', 18),
                    ),
                  ],
                ],

                // Sparkles when clean
                if (cleanlinessScore >= 70) ...List.generate(5, (index) {
                  return AnimatedBuilder(
                    animation: _sparkleController,
                    builder: (context, child) {
                      final progress = (_sparkleController.value + index * 0.2) % 1.0;
                      return Positioned(
                        left: 30.0 + (index * 60),
                        top: 50.0 + math.sin(progress * math.pi * 2) * 20,
                        child: Opacity(
                          opacity: (math.sin(progress * math.pi * 2) + 1) / 2,
                          child: const Text('✨', style: TextStyle(fontSize: 16)),
                        ),
                      );
                    },
                  );
                }),

                // Cleanliness Badge
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: roomGlowColor.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: roomGlowColor.withOpacity(0.5),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(cleanlinessEmoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 4),
                        Text(
                          '$cleanlinessScore%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Streak Badge
                if (currentStreak > 0)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 4),
                          Text(
                            '$currentStreak ${currentStreak == 1 ? 'day' : 'days'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat()).shimmer(
                      duration: 2000.ms,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBed(int zoneBed) {
    final opacity = zoneBed / 100;
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(AppTheme.zoneBed, Colors.grey, 1 - opacity)!,
            Color.lerp(AppTheme.zoneBed.withOpacity(0.8), Colors.grey.shade600, 1 - opacity)!,
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pillow
          Positioned(
            top: -8,
            left: 8,
            right: 8,
            child: Container(
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(opacity),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          // Blanket lines (if unmade)
          if (zoneBed < 80)
            Positioned(
              top: 20,
              left: 10,
              right: 10,
              child: Container(
                height: 2,
                color: Colors.black.withOpacity(0.1),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesk(int zoneDesk) {
    final opacity = zoneDesk / 100;
    return Container(
      width: 80,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(AppTheme.zoneDesk, Colors.grey, 1 - opacity)!,
            Color.lerp(AppTheme.zoneDesk.withOpacity(0.7), Colors.grey.shade600, 1 - opacity)!,
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Items on desk
          if (zoneDesk >= 60)
            Positioned(
              top: -15,
              left: 10,
              child: Container(
                width: 20,
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          // Clutter if messy
          if (zoneDesk < 60) ...[
            const Positioned(top: -10, left: 5, child: Text('📝', style: TextStyle(fontSize: 12))),
            const Positioned(top: -8, right: 10, child: Text('✏️', style: TextStyle(fontSize: 10))),
          ],
        ],
      ),
    );
  }

  Widget _buildCloset(int zoneCloset) {
    final opacity = zoneCloset / 100;
    return Container(
      width: 50,
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(AppTheme.zoneCloset, Colors.grey, 1 - opacity)!,
            Color.lerp(AppTheme.zoneCloset.withOpacity(0.7), Colors.grey.shade600, 1 - opacity)!,
          ],
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Door handle
          Container(
            width: 6,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.brown.shade700,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Clothes peeking out if messy
          if (zoneCloset < 70)
            Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    width: 40,
                    height: 4,
                    color: Colors.red.withOpacity(0.5),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMessyItem(String emoji, double size) {
    return Transform.rotate(
      angle: (math.Random().nextDouble() - 0.5) * 0.5,
      child: Text(emoji, style: TextStyle(fontSize: size)),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
      begin: const Offset(1, 1),
      end: const Offset(1.1, 1.1),
      duration: 1000.ms,
    );
  }
}
