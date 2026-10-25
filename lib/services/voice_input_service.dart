import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../app/theme.dart';

class VoiceInputService {
  static final stt.SpeechToText _speech = stt.SpeechToText();
  static bool _hasSpeech = false;

  static Future<bool> init() async {
    try {
      if (!_hasSpeech) {
        _hasSpeech = await _speech.initialize();
      }
      return _hasSpeech;
    } catch (_) {
      return false;
    }
  }

  static bool get isListening => _speech.isListening;

  /// Shows an interactive, animated Voice Dictation modal for any text field.
  /// Streams recognized words directly into the TextEditingController and allows
  /// manual corrections or acceptance.
  static Future<void> showVoiceDictationDialog({
    required BuildContext context,
    required String fieldLabel,
    required TextEditingController controller,
    bool isAppend = true,
  }) async {
    bool hasInitialized = false;
    bool listening = false;
    String liveText = '';

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (modalCtx, setModalState) {
          void startListening() async {
            try {
              if (!hasInitialized) {
                hasInitialized = await _speech.initialize(
                  onError: (e) {
                    if (modalCtx.mounted) setModalState(() => listening = false);
                  },
                  onStatus: (s) {
                    if (s == 'done' || s == 'notListening') {
                      if (modalCtx.mounted) setModalState(() => listening = false);
                    }
                  },
                );
              }

              if (hasInitialized) {
                setModalState(() {
                  listening = true;
                  liveText = '';
                });
                await _speech.listen(
                  onResult: (result) {
                    if (modalCtx.mounted) {
                      setModalState(() {
                        liveText = result.recognizedWords;
                      });
                    }
                  },
                  listenOptions: stt.SpeechListenOptions(
                    listenMode: stt.ListenMode.dictation,
                    partialResults: true,
                  ),
                );
              }
            } catch (_) {
              if (modalCtx.mounted) setModalState(() => listening = false);
            }
          }

          void stopListening() async {
            await _speech.stop();
            if (modalCtx.mounted) {
              setModalState(() => listening = false);
            }
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(modalCtx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: PlaceTrackTheme.primary.withAlpha(20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mic_rounded, color: PlaceTrackTheme.primary, size: 22),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Voice Typing & Dictation',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            fieldLabel,
                            style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    if (listening)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF2F2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFCA5A5)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.fiber_manual_record_rounded, color: Colors.red, size: 10),
                            SizedBox(width: 4),
                            Text('Listening...', style: TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Pulsing Microphone Button
                GestureDetector(
                  onTap: () {
                    if (listening) {
                      stopListening();
                    } else {
                      startListening();
                    }
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: listening ? 80 : 70,
                    height: listening ? 80 : 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: listening ? const Color(0xFFDC2626) : PlaceTrackTheme.primary,
                      boxShadow: [
                        BoxShadow(
                          color: (listening ? Colors.red : PlaceTrackTheme.primary).withAlpha(100),
                          blurRadius: listening ? 20 : 8,
                          spreadRadius: listening ? 6 : 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      listening ? Icons.mic_rounded : Icons.mic_none_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  listening ? 'Speak clearly now... Tap to stop' : 'Tap microphone to speak and dictate',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: listening ? FontWeight.bold : FontWeight.normal,
                    color: listening ? Colors.red : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 16),

                // Live recognized text preview container
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 70, maxHeight: 120),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      liveText.isNotEmpty
                          ? liveText
                          : (controller.text.isNotEmpty
                              ? controller.text
                              : 'Your spoken words will appear here in real time...'),
                      style: TextStyle(
                        fontSize: 13,
                        color: liveText.isNotEmpty || controller.text.isNotEmpty ? Colors.black87 : Colors.grey,
                        fontStyle: liveText.isEmpty && controller.text.isEmpty ? FontStyle.italic : FontStyle.normal,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          stopListening();
                          Navigator.pop(ctx);
                        },
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: PlaceTrackTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.check_rounded, size: 18),
                        label: const Text('Insert into Field'),
                        onPressed: () {
                          stopListening();
                          if (liveText.trim().isNotEmpty) {
                            if (isAppend && controller.text.isNotEmpty) {
                              controller.text = '${controller.text} ${liveText.trim()}';
                            } else {
                              controller.text = liveText.trim();
                            }
                          }
                          Navigator.pop(ctx);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class VoiceMicButton extends StatelessWidget {
  final String fieldLabel;
  final TextEditingController controller;
  final bool isAppend;

  const VoiceMicButton({
    super.key,
    required this.fieldLabel,
    required this.controller,
    this.isAppend = true,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.mic_rounded, color: PlaceTrackTheme.primary, size: 20),
      tooltip: 'Voice Typing / Speak for $fieldLabel',
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      onPressed: () {
        VoiceInputService.showVoiceDictationDialog(
          context: context,
          fieldLabel: fieldLabel,
          controller: controller,
          isAppend: isAppend,
        );
      },
    );
  }
}
