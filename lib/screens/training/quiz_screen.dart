import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/placement_models.dart';
import '../../services/placement_data_service.dart';

class QuizListScreen extends StatelessWidget {
  const QuizListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = PlacementDataService();
    final quizzes = service.quizzes;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Campus Mock Tests & Quizzes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        itemBuilder: (ctx, index) {
          final q = quizzes[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QuizPlayScreen(quiz: q)),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Color(q.colorValue).withAlpha(25),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.quiz_rounded, color: Color(q.colorValue), size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            q.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Color(q.colorValue).withAlpha(20),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  q.category,
                                  style: TextStyle(
                                    color: Color(q.colorValue),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '⏱️ ${q.durationMinutes} Mins',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '• ${q.questions.length} Questions',
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class QuizPlayScreen extends StatefulWidget {
  final AptitudeQuiz quiz;

  const QuizPlayScreen({super.key, required this.quiz});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentIndex = 0;
  final Map<int, int> _selectedAnswers = {}; // questionIndex -> optionIndex
  late int _remainingSeconds;
  Timer? _timer;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.quiz.durationMinutes * 60;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        _timer?.cancel();
        _submitQuiz();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _submitQuiz() {
    _timer?.cancel();
    setState(() => _isSubmitted = true);
  }

  String _formatTimer() {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  int _calculateScore() {
    int score = 0;
    for (int i = 0; i < widget.quiz.questions.length; i++) {
      if (_selectedAnswers[i] == widget.quiz.questions[i].correctOptionIndex) {
        score++;
      }
    }
    return score;
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitted) {
      return _buildResultScreen();
    }

    final question = widget.quiz.questions[_currentIndex];
    final progress = (_currentIndex + 1) / widget.quiz.questions.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(widget.quiz.title, style: const TextStyle(fontSize: 16)),
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _remainingSeconds < 120 ? Colors.red.withAlpha(40) : Colors.white24,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: _remainingSeconds < 120 ? Colors.redAccent : Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimer(),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _remainingSeconds < 120 ? Colors.redAccent : Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Color(widget.quiz.colorValue)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Question ${_currentIndex + 1} of ${widget.quiz.questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                Text(
                  'Answered: ${_selectedAnswers.length}/${widget.quiz.questions.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: PlaceTrackTheme.primary),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      question.questionText,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(question.options.length, (optIdx) {
                    final isSelected = _selectedAnswers[_currentIndex] == optIdx;
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedAnswers[_currentIndex] = optIdx);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Color(widget.quiz.colorValue).withAlpha(15)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Color(widget.quiz.colorValue)
                                : const Color(0xFFCBD5E1),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected ? Color(widget.quiz.colorValue) : Colors.grey,
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Color(widget.quiz.colorValue),
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                question.options[optIdx],
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, -2))],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                OutlinedButton.icon(
                  onPressed: _currentIndex > 0
                      ? () => setState(() => _currentIndex--)
                      : null,
                  icon: const Icon(Icons.arrow_back_rounded, size: 16),
                  label: const Text('Previous'),
                ),
                if (_currentIndex < widget.quiz.questions.length - 1)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(widget.quiz.colorValue),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => setState(() => _currentIndex++),
                    label: const Text('Next'),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _showSubmitConfirmDialog,
                    label: const Text('Submit Test'),
                    icon: const Icon(Icons.check_circle_rounded, size: 16),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submit Mock Test?'),
        content: Text(
          'You answered ${_selectedAnswers.length} of ${widget.quiz.questions.length} questions. Do you want to submit now?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF059669), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              _submitQuiz();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final score = _calculateScore();
    final total = widget.quiz.questions.length;
    final percentage = ((score / total) * 100).toInt();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(title: const Text('Mock Test Results')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: percentage >= 60 ? const Color(0xFFDCFCE7) : const Color(0xFFFEF2F2),
                    ),
                    child: Icon(
                      percentage >= 60 ? Icons.emoji_events_rounded : Icons.replay_rounded,
                      color: percentage >= 60 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                      size: 42,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    percentage >= 60 ? 'Congratulations! Test Passed' : 'Needs Practice',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Your Score: $score / $total ($percentage%)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: percentage >= 60 ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                    ),
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text('Accuracy', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('$percentage%', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Answered', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text('${_selectedAnswers.length}/$total', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      Column(
                        children: [
                          const Text('Status', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 2),
                          Text(percentage >= 60 ? 'Shortlisted' : 'Try Again',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: percentage >= 60 ? Colors.green : Colors.red)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Detailed Solutions & Explanations',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ...List.generate(widget.quiz.questions.length, (idx) {
              final q = widget.quiz.questions[idx];
              final userAns = _selectedAnswers[idx];
              final isCorrect = userAns == q.correctOptionIndex;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isCorrect ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                          color: isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Q${idx + 1}: ${q.questionText}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your Answer: ${userAns != null ? q.options[userAns] : "Not Answered"}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isCorrect ? const Color(0xFF15803D) : const Color(0xFFDC2626),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isCorrect) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Correct Answer: ${q.options[q.correctOptionIndex]}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.w600),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '💡 Explanation: ${q.explanation}',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF475569)),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PlaceTrackTheme.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Back to Training Hub', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
