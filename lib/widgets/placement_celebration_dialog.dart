import 'dart:math';
import 'package:flutter/material.dart';
import '../models/placement_models.dart';
import '../services/placement_data_service.dart';

class PlacementCelebrationDialog extends StatefulWidget {
  final StudentModel student;
  final PlacementDrive drive;

  const PlacementCelebrationDialog({
    super.key,
    required this.student,
    required this.drive,
  });

  static void show(
    BuildContext context, {
    required StudentModel student,
    required PlacementDrive drive,
  }) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => PlacementCelebrationDialog(
        student: student,
        drive: drive,
      ),
    );
  }

  @override
  State<PlacementCelebrationDialog> createState() => _PlacementCelebrationDialogState();
}

class _PlacementCelebrationDialogState extends State<PlacementCelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_FireworkParticle> _particles = [];
  final List<_FireworkRocket> _rockets = [];
  final List<_BurstRing> _burstRings = [];
  final Random _rnd = Random();

  final List<Color> _palette = const [
    Color(0xFFFFD700), // Gold
    Color(0xFFFF3B30), // Electric Red
    Color(0xFF00E676), // Bright Emerald
    Color(0xFF00E5FF), // Cyan Star
    Color(0xFFFF9100), // Amber Glow
    Color(0xFFFF4081), // Pink Flare
    Color(0xFFE040FB), // Magenta Spark
    Color(0xFFFFFFFF), // Diamond White
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addListener(() {
        _updateAnimation();
        setState(() {});
      });

    _triggerGrandCelebration();
    _controller.repeat();
  }

  void _triggerGrandCelebration() {
    _particles.clear();
    _rockets.clear();
    _burstRings.clear();

    // Immediately detonate 4 big center bursts
    final initialOrigins = [
      const Offset(0.20, 0.22),
      const Offset(0.80, 0.20),
      const Offset(0.50, 0.35),
      const Offset(0.30, 0.60),
      const Offset(0.70, 0.65),
    ];

    for (final origin in initialOrigins) {
      _detonateBurst(origin.dx, origin.dy, 45 + _rnd.nextInt(25));
    }

    // Launch 4 staggered rockets from the bottom
    for (int i = 0; i < 4; i++) {
      _launchRocket(
        startX: 0.15 + _rnd.nextDouble() * 0.70,
        targetY: 0.18 + _rnd.nextDouble() * 0.35,
        delayTicks: i * 15,
      );
    }
  }

  void _launchRocket({required double startX, required double targetY, int delayTicks = 0}) {
    _rockets.add(
      _FireworkRocket(
        x: startX,
        y: 1.05,
        targetY: targetY,
        vy: -0.016 - _rnd.nextDouble() * 0.008,
        color: _palette[_rnd.nextInt(_palette.length)],
        delayTicks: delayTicks,
      ),
    );
  }

  void _detonateBurst(double cx, double cy, int count) {
    // Add glowing shockwave ring
    final burstColor = _palette[_rnd.nextInt(_palette.length)];
    _burstRings.add(_BurstRing(cx: cx, cy: cy, color: burstColor));

    // Spawn radial explosion particles
    for (int i = 0; i < count; i++) {
      final angle = (2 * pi * i) / count + (_rnd.nextDouble() * 0.25 - 0.12);
      final speed = 0.004 + _rnd.nextDouble() * 0.014;
      final isStar = _rnd.nextBool();
      _particles.add(
        _FireworkParticle(
          x: cx,
          y: cy,
          vx: cos(angle) * speed,
          vy: sin(angle) * speed,
          color: _palette[_rnd.nextInt(_palette.length)],
          radius: isStar ? (3.0 + _rnd.nextDouble() * 2.5) : (2.0 + _rnd.nextDouble() * 2.0),
          life: 1.0,
          decay: 0.012 + _rnd.nextDouble() * 0.018,
          isStar: isStar,
        ),
      );
    }
  }

  void _updateAnimation() {
    // 1. Update & detonate rockets
    for (int i = _rockets.length - 1; i >= 0; i--) {
      final r = _rockets[i];
      if (r.delayTicks > 0) {
        r.delayTicks--;
        continue;
      }

      r.y += r.vy;

      // Rocket sparks trail
      if (_rnd.nextDouble() > 0.3) {
        _particles.add(
          _FireworkParticle(
            x: r.x + (_rnd.nextDouble() - 0.5) * 0.01,
            y: r.y + 0.015,
            vx: (_rnd.nextDouble() - 0.5) * 0.002,
            vy: 0.001 + _rnd.nextDouble() * 0.003,
            color: Colors.amberAccent,
            radius: 1.8,
            life: 0.6,
            decay: 0.035,
            isStar: false,
          ),
        );
      }

      // Detonate upon reaching altitude
      if (r.y <= r.targetY) {
        _detonateBurst(r.x, r.y, 40 + _rnd.nextInt(25));
        _rockets.removeAt(i);

        // Periodically respawn new rocket from bottom for continuous celebration
        if (_rockets.length < 3) {
          _launchRocket(
            startX: 0.10 + _rnd.nextDouble() * 0.80,
            targetY: 0.15 + _rnd.nextDouble() * 0.40,
            delayTicks: 10 + _rnd.nextInt(20),
          );
        }
      }
    }

    // 2. Update shockwave rings
    for (int i = _burstRings.length - 1; i >= 0; i--) {
      final ring = _burstRings[i];
      ring.radius += 2.2;
      ring.alpha -= 0.035;
      if (ring.alpha <= 0) {
        _burstRings.removeAt(i);
      }
    }

    // 3. Update explosion particles
    for (int i = _particles.length - 1; i >= 0; i--) {
      final p = _particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.vy += 0.00035; // realistic gravitational pull
      p.vx *= 0.985;   // atmospheric drag
      p.life -= p.decay;

      if (p.life <= 0) {
        _particles.removeAt(i);
      }
    }

    // Keep active fireworks alive
    if (_rockets.isEmpty && _particles.length < 30) {
      _launchRocket(
        startX: 0.2 + _rnd.nextDouble() * 0.6,
        targetY: 0.2 + _rnd.nextDouble() * 0.35,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Resolve dynamic placed date
    final placedDate = widget.drive.placedDates[widget.student.id] ??
        PlacementDataService().getStudentPlacementDate(widget.student.id) ??
        '25 Sep 2026, 09:15 PM';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background ambient dark overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(160),
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),

          // Main Celebratory Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0B1329), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFF59E0B), width: 2.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF59E0B).withAlpha(110),
                  blurRadius: 36,
                  spreadRadius: 6,
                ),
                BoxShadow(
                  color: const Color(0xFFEF4444).withAlpha(60),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated Trophy Badge with radial shine
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFFFEF08A), Color(0xFFD97706)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withAlpha(180),
                          blurRadius: 24,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text('🏆', style: TextStyle(fontSize: 42)),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Congratulations Header
                  const Text(
                    'CONGRATULATIONS!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                      color: Color(0xFFFDE68A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '🎉 OFFICIAL CAMPUS PLACEMENT OFFER RELEASED 🎉',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Color(0xFF38BDF8),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Student & Company Placed Box
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(14),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.student.name,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${widget.student.regNo} • ${widget.student.department}',
                          style: const TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                        const Divider(color: Colors.white24, height: 20),
                        const Text(
                          'OFFICIALLY SELECTED & PLACED AT',
                          style: TextStyle(
                            fontSize: 10,
                            letterSpacing: 1.2,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.drive.companyName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4ADE80),
                          ),
                        ),
                        Text(
                          widget.drive.role,
                          style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 12),

                        // Offered Package Chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF059669), Color(0xFF10B981)],
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF10B981).withAlpha(120),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'OFFERED CTC: ${widget.drive.packageLpa}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Official Placed Date Badge (With Real Timestamp from Admin Tick)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF59E0B).withAlpha(35),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFF59E0B).withAlpha(140)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_available_rounded, size: 14, color: Color(0xFFFDE68A)),
                              const SizedBox(width: 6),
                              Text(
                                'Placed on: $placedDate',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFDE68A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Department Message
                  const Text(
                    'The Placement Cell & Faculty congratulate you on clearing all rounds successfully! Your placement confirmation is permanently registered in the GRI Portal.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 11.5, color: Colors.white70, height: 1.4),
                  ),
                  const SizedBox(height: 18),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFDE68A),
                            side: const BorderSide(color: Color(0xFFFDE68A), width: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          icon: const Icon(Icons.auto_awesome_rounded, size: 18, color: Color(0xFFFDE68A)),
                          label: const Text('Burst Again 🎆', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () {
                            _triggerGrandCelebration();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Continue', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // FOREGROUND BURSTING FIREWORKS & CRACKERS CANVAS OVERLAY (Explodes IN FRONT of card)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _VibrantFireworksPainter(
                  particles: _particles,
                  rockets: _rockets,
                  burstRings: _burstRings,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// Animation Models
// -------------------------------------------------------------

class _FireworkRocket {
  double x;
  double y;
  double targetY;
  double vy;
  Color color;
  int delayTicks;

  _FireworkRocket({
    required this.x,
    required this.y,
    required this.targetY,
    required this.vy,
    required this.color,
    this.delayTicks = 0,
  });
}

class _BurstRing {
  double cx;
  double cy;
  Color color;
  double radius = 4.0;
  double alpha = 1.0;

  _BurstRing({
    required this.cx,
    required this.cy,
    required this.color,
  });
}

class _FireworkParticle {
  double x;
  double y;
  double vx;
  double vy;
  Color color;
  double radius;
  double life;
  double decay;
  bool isStar;

  _FireworkParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.radius,
    required this.life,
    required this.decay,
    required this.isStar,
  });
}

// -------------------------------------------------------------
// Vibrant Explosive Painter
// -------------------------------------------------------------

class _VibrantFireworksPainter extends CustomPainter {
  final List<_FireworkParticle> particles;
  final List<_FireworkRocket> rockets;
  final List<_BurstRing> burstRings;

  _VibrantFireworksPainter({
    required this.particles,
    required this.rockets,
    required this.burstRings,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Draw Shockwave Rings
    for (final ring in burstRings) {
      if (ring.alpha <= 0) continue;
      final paint = Paint()
        ..color = ring.color.withAlpha((ring.alpha.clamp(0.0, 1.0) * 160).toInt())
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

      canvas.drawCircle(Offset(ring.cx * w, ring.cy * h), ring.radius, paint);
    }

    // 2. Draw Rockets (shooting up)
    for (final r in rockets) {
      if (r.delayTicks > 0) continue;
      final rx = r.x * w;
      final ry = r.y * h;

      // Rocket glowing head
      final headPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(rx, ry), 3.5, headPaint);

      // Rocket flame
      final flamePaint = Paint()
        ..color = r.color
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(Offset(rx, ry), Offset(rx, ry + 16), flamePaint);
    }

    // 3. Draw Exploding Particles & Sparkling Stars
    for (final p in particles) {
      if (p.life <= 0) continue;
      final px = p.x * w;
      final py = p.y * h;
      final alphaInt = (p.life.clamp(0.0, 1.0) * 255).toInt();

      final paint = Paint()
        ..color = p.color.withAlpha(alphaInt)
        ..style = PaintingStyle.fill;

      if (p.isStar) {
        // Draw glittering 4-point cross star
        final starSize = p.radius * p.life * 1.5;
        final starPaint = Paint()
          ..color = p.color.withAlpha(alphaInt)
          ..strokeWidth = 1.6
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(Offset(px - starSize, py), Offset(px + starSize, py), starPaint);
        canvas.drawLine(Offset(px, py - starSize), Offset(px, py + starSize), starPaint);
        canvas.drawCircle(Offset(px, py), p.radius * 0.6 * p.life, paint);
      } else {
        // Round spark with glowing streak tail
        canvas.drawCircle(Offset(px, py), p.radius * p.life, paint);

        final tailPaint = Paint()
          ..color = p.color.withAlpha((alphaInt * 0.5).toInt())
          ..strokeWidth = p.radius * 0.9
          ..strokeCap = StrokeCap.round;

        canvas.drawLine(
          Offset(px, py),
          Offset(px - p.vx * w * 2.2, py - p.vy * h * 2.2),
          tailPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VibrantFireworksPainter oldDelegate) => true;
}
