import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/placement_models.dart';
import '../../services/placement_data_service.dart';
import 'quiz_screen.dart';

class TrainingScreen extends StatefulWidget {
  final bool isStudentView;

  const TrainingScreen({
    super.key,
    this.isStudentView = false,
  });

  @override
  State<TrainingScreen> createState() => _TrainingScreenState();
}

class _TrainingScreenState extends State<TrainingScreen> {
  final _service = PlacementDataService();
  String _selectedFilter = 'All'; // 'All', 'Ongoing', 'Upcoming', 'Completed'

  @override
  void initState() {
    super.initState();
    _service.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  List<TrainingWorkshop> get _filteredWorkshops {
    final list = _service.workshops;
    if (_selectedFilter == 'All') return list;
    return list.where((w) => w.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
  }

  void _showAddWorkshopDialog() {
    final titleController = TextEditingController();
    final trainerController = TextEditingController();
    final venueController = TextEditingController(text: 'Seminar Hall 2 / Audio-Visual Room');
    final batchController = TextEditingController(text: 'MCA, BCA, B.Sc CS Final Years');
    final timingController = TextEditingController(text: 'Mon - Fri, 03:30 PM - 05:00 PM');
    final sessionsController = TextEditingController(text: '10 Sessions Planned');
    final syllabusController = TextEditingController();
    String selectedStatus = 'Ongoing';
    int selectedColor = 0xFF2563EB;

    final colorOptions = [
      {'name': 'Blue', 'val': 0xFF2563EB},
      {'name': 'Purple', 'val': 0xFF7E3AF2},
      {'name': 'Teal', 'val': 0xFF0D9488},
      {'name': 'Orange', 'val': 0xFFEA580C},
      {'name': 'Green', 'val': 0xFF16A34A},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                const Row(
                  children: [
                    Icon(Icons.add_task_rounded, color: PlaceTrackTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Schedule New Training Workshop',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Workshop / Program Title *',
                    hintText: 'e.g. Full-Stack Web Development Bootcamp',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: trainerController,
                  decoration: const InputDecoration(
                    labelText: 'Trainer / Resource Person *',
                    hintText: 'e.g. Industry Expert / Faculty Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: venueController,
                        decoration: const InputDecoration(
                          labelText: 'Venue / Mode',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: timingController,
                        decoration: const InputDecoration(
                          labelText: 'Timing / Days',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: batchController,
                  decoration: const InputDecoration(
                    labelText: 'Target Batches & Courses',
                    hintText: 'e.g. MCA, BCA, B.Sc CS',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: sessionsController,
                        decoration: const InputDecoration(
                          labelText: 'Sessions Count',
                          hintText: 'e.g. 10 Sessions',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Ongoing', child: Text('Ongoing')),
                          DropdownMenuItem(value: 'Upcoming', child: Text('Upcoming')),
                          DropdownMenuItem(value: 'Completed', child: Text('Completed')),
                        ],
                        onChanged: (v) => setModalState(() => selectedStatus = v ?? 'Ongoing'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: syllabusController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Syllabus & Key Topics Covered',
                    hintText: 'e.g. Flutter, REST APIs, Git, Cloud basics, Mock tests',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 14),
                const Text('Theme Accent Color:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 8),
                Row(
                  children: colorOptions.map((opt) {
                    final colorVal = opt['val'] as int;
                    final isSel = selectedColor == colorVal;
                    return GestureDetector(
                      onTap: () => setModalState(() => selectedColor = colorVal),
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Color(colorVal),
                          shape: BoxShape.circle,
                          border: isSel ? Border.all(color: Colors.black, width: 2.5) : null,
                        ),
                        child: isSel ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlaceTrackTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      if (titleController.text.trim().isEmpty || trainerController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter Title and Trainer name.')),
                        );
                        return;
                      }
                      final newW = TrainingWorkshop(
                        id: 'w_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleController.text.trim(),
                        trainer: trainerController.text.trim(),
                        venueOrMode: venueController.text.trim().isNotEmpty ? venueController.text.trim() : 'Seminar Hall',
                        targetBatch: batchController.text.trim().isNotEmpty ? batchController.text.trim() : 'All Batches',
                        timing: timingController.text.trim().isNotEmpty ? timingController.text.trim() : 'TBD',
                        sessions: sessionsController.text.trim().isNotEmpty ? sessionsController.text.trim() : 'Planned',
                        status: selectedStatus,
                        syllabus: syllabusController.text.trim().isNotEmpty ? syllabusController.text.trim() : 'Curriculum based training',
                        progress: selectedStatus == 'Completed' ? 1.0 : (selectedStatus == 'Upcoming' ? 0.0 : 0.25),
                        colorValue: selectedColor,
                      );
                      _service.addWorkshop(newW);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Workshop "${newW.title}" added successfully!'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
                    },
                    child: const Text('Add Training Workshop'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showWorkshopDetailsDialog(TrainingWorkshop workshop) {
    final color = Color(workshop.colorValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workshop.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Trainer: ${workshop.trainer}',
                          style: const TextStyle(fontSize: 13, color: PlaceTrackTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withAlpha(30),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      workshop.status,
                      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.location_on_outlined, 'Venue / Mode', workshop.venueOrMode),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.access_time_rounded, 'Timings', workshop.timing),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.school_outlined, 'Target Batches', workshop.targetBatch),
                    const SizedBox(height: 8),
                    _buildInfoRow(Icons.repeat_rounded, 'Sessions Progress', workshop.sessions),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text('Syllabus & Modules Covered:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                workshop.syllabus,
                style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
              ),
              const SizedBox(height: 16),
              Text(
                'Overall Progress: ${(workshop.progress * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: workshop.progress,
                minHeight: 8,
                backgroundColor: const Color(0xFFE2E8F0),
                color: color,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 20),
              if (!widget.isStudentView) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.check_circle_outline, size: 18),
                        label: const Text('Mark Complete'),
                        onPressed: () {
                          final updated = workshop.copyWith(
                            status: 'Completed',
                            progress: 1.0,
                            sessions: 'Completed (100% Attendance)',
                          );
                          _service.updateWorkshop(updated);
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Workshop marked as Completed!')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                      tooltip: 'Delete Workshop',
                      onPressed: () {
                        _service.deleteWorkshop(workshop.id);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Deleted "${workshop.title}"')),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: PlaceTrackTheme.textSecondary),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PlaceTrackTheme.textSecondary)),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.black87)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final workshops = _filteredWorkshops;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Training & Upskilling'),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz_rounded),
            tooltip: 'Campus Mock Tests',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizListScreen()),
              );
            },
          ),
          if (!widget.isStudentView)
            IconButton(
              icon: const Icon(Icons.add_rounded),
              tooltip: 'Add Workshop',
              onPressed: _showAddWorkshopDialog,
            ),
        ],
      ),
      floatingActionButton: !widget.isStudentView
          ? FloatingActionButton.extended(
              onPressed: _showAddWorkshopDialog,
              backgroundColor: PlaceTrackTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('New Program'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Header Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4338CA).withAlpha(50),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Placement Bootcamps',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(40),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_service.workshops.length} Programs',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Aptitude, DSA, Soft Skills & Company Specific Technical Mock Assessments.',
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Practice Mock Tests & Aptitude Card
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuizListScreen()),
              );
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF047857), Color(0xFF10B981)],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF047857).withAlpha(40),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Row(
                children: [
                  Icon(Icons.quiz_rounded, color: Colors.white, size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Practice Campus Mock Tests & Aptitude',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Timed Quantitative, Logical & Coding questions with explanations',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Ongoing', 'Upcoming', 'Completed'].map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    selectedColor: PlaceTrackTheme.primary.withAlpha(30),
                    checkmarkColor: PlaceTrackTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? PlaceTrackTheme.primary : PlaceTrackTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    onSelected: (val) => setState(() => _selectedFilter = filter),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),

          if (workshops.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Text(
                  'No $_selectedFilter workshops found.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...workshops.map((w) {
              final color = Color(w.colorValue);
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(8),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: () => _showWorkshopDetailsDialog(w),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: color.withAlpha(20),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.school_rounded, color: color, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    w.title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Trainer: ${w.trainer}',
                                    style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: color.withAlpha(20),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                w.status,
                                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                '${w.timing} • ${w.venueOrMode}',
                                style: const TextStyle(fontSize: 11, color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        LinearProgressIndicator(
                          value: w.progress,
                          backgroundColor: const Color(0xFFF1F5F9),
                          color: color,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              w.sessions,
                              style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                            const Text(
                              'Tap for Details ↗',
                              style: TextStyle(fontSize: 11, color: PlaceTrackTheme.primary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

