import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../auth/login_screen.dart';

class IntroVideoScreen extends StatefulWidget {
  const IntroVideoScreen({super.key});

  @override
  State<IntroVideoScreen> createState() => _IntroVideoScreenState();
}

class _IntroVideoScreenState extends State<IntroVideoScreen> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _hasNavigated = false;
  bool _hasError = false;
  bool _isMuted = kIsWeb; // Start muted on web for browser autoplay policy compliance

  @override
  void initState() {
    super.initState();
    // Full immersive mode on mobile - hides status bar & nav bar
    if (!kIsWeb) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      _controller = VideoPlayerController.asset('assets/videos/intro.mp4');
      await _controller.initialize();

      if (!mounted) return;

      if (kIsWeb) {
        await _controller.setVolume(0.0);
      } else {
        await _controller.setVolume(1.0);
      }

      setState(() {
        _isInitialized = true;
      });

      await _controller.play();

      // Navigate to login when video ends
      _controller.addListener(() {
        if (!mounted || _hasNavigated) return;
        final pos = _controller.value.position;
        final dur = _controller.value.duration;
        if (dur > Duration.zero && pos >= dur) {
          _navigateToLogin();
        }
      });
    } catch (e) {
      debugPrint('Intro video error: $e');
      if (mounted) {
        setState(() => _hasError = true);
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) _navigateToLogin();
      }
    }
  }

  void _toggleMute() {
    if (!_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  void _navigateToLogin() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    // Restore system UI before navigating
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );

    try {
      _controller.pause();
    } catch (_) {}

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full uncropped PlaceTrack video with ambient blurred background
          if (_isInitialized) ...[
            // 1. Ambient blurred background layer that fills the screen edge-to-edge
            Positioned.fill(
              child: ImageFiltered(
                imageFilter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: Opacity(
                      opacity: 0.45,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                ),
              ),
            ),
            // Vignette dark gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [
                      Colors.transparent,
                      Colors.black.withAlpha(160),
                    ],
                  ),
                ),
              ),
            ),
            // 2. Full uncropped video in center: guarantees 100% of PlaceTrack text & animation is visible
            Center(
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ] else if (!_hasError)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF06B6D4),
                strokeWidth: 2.5,
              ),
            ),

          // Action controls (Sound toggle + Skip)
          Positioned(
            top: MediaQuery.of(context).padding.top + 20,
            right: 20,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sound Toggle Button
                if (_isInitialized)
                  GestureDetector(
                    onTap: _toggleMute,
                    child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(140),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withAlpha(60), width: 1),
                      ),
                      child: Icon(
                        _isMuted
                            ? Icons.volume_off_rounded
                            : Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                // Skip Button
                GestureDetector(
                  onTap: _navigateToLogin,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 9),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                          color: Colors.white.withAlpha(60), width: 1),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Skip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.6,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white, size: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Thin cyan progress bar at bottom
          if (_isInitialized)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoProgressIndicator(
                _controller,
                allowScrubbing: false,
                colors: const VideoProgressColors(
                  playedColor: Color(0xFF06B6D4),
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
