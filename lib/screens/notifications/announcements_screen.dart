import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/placement_models.dart';
import '../../services/placement_data_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  final bool isAdmin;

  const AnnouncementsScreen({
    super.key,
    this.isAdmin = false,
  });

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  final _service = PlacementDataService();
  String _selectedCategory = 'All';

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

  List<PlacementAnnouncement> get _filteredAnnouncements {
    final all = _service.announcements;
    if (_selectedCategory == 'All') return all;
    return all.where((a) => a.category.toLowerCase() == _selectedCategory.toLowerCase()).toList();
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else {
      return '${diff.inDays}d ago';
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'urgent':
        return const Color(0xFFDC2626);
      case 'drive alert':
        return const Color(0xFF4F46E5);
      case 'workshop':
        return const Color(0xFF7C3AED);
      default:
        return const Color(0xFF0D9488);
    }
  }

  void _showNewAnnouncementDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    final authorController = TextEditingController(text: 'Placement Cell Officer');
    String selectedCategory = 'Drive Alert';
    bool isImportant = true;

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
                    Icon(Icons.campaign_rounded, color: PlaceTrackTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Broadcast New Announcement',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Announcement Title *',
                    hintText: 'e.g. Amazon Round 2 Technical Shortlist',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Drive Alert', child: Text('Drive Alert')),
                          DropdownMenuItem(value: 'Urgent', child: Text('Urgent Notice')),
                          DropdownMenuItem(value: 'Workshop', child: Text('Workshop & Training')),
                          DropdownMenuItem(value: 'General', child: Text('General')),
                        ],
                        onChanged: (v) => setModalState(() => selectedCategory = v ?? 'Drive Alert'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: authorController,
                        decoration: const InputDecoration(
                          labelText: 'Author / Role',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Announcement Message *',
                    hintText: 'Type instructions, drive details, or critical deadlines...',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Mark as High Priority / Urgent Alert', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  value: isImportant,
                  activeThumbColor: PlaceTrackTheme.danger,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (val) => setModalState(() => isImportant = val),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlaceTrackTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded, size: 18),
                    label: const Text('Broadcast to All Students'),
                    onPressed: () {
                      if (titleController.text.trim().isEmpty || messageController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill title and message.')),
                        );
                        return;
                      }

                      final newAnnounce = PlacementAnnouncement(
                        id: 'a_${DateTime.now().millisecondsSinceEpoch}',
                        title: titleController.text.trim(),
                        message: messageController.text.trim(),
                        category: selectedCategory,
                        author: authorController.text.trim().isNotEmpty ? authorController.text.trim() : 'Placement Cell',
                        timestamp: DateTime.now(),
                        isImportant: isImportant,
                      );

                      _service.addAnnouncement(newAnnounce);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Broadcast announcement published successfully!'),
                          backgroundColor: Color(0xFF059669),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredAnnouncements;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements & Alerts'),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.add_alert_rounded),
              tooltip: 'New Broadcast',
              onPressed: _showNewAnnouncementDialog,
            ),
        ],
      ),
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton.extended(
              onPressed: _showNewAnnouncementDialog,
              backgroundColor: PlaceTrackTheme.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.campaign_rounded),
              label: const Text('Broadcast'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Drive Alert', 'Urgent', 'Workshop', 'General'].map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(cat),
                    selected: isSelected,
                    selectedColor: PlaceTrackTheme.primary.withAlpha(25),
                    checkmarkColor: PlaceTrackTheme.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? PlaceTrackTheme.primary : PlaceTrackTheme.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          if (list.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  'No $_selectedCategory announcements available.',
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...list.map((a) {
              final catColor = _getCategoryColor(a.category);
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: a.isImportant ? const Color(0xFFFCA5A5) : const Color(0xFFE2E8F0),
                    width: a.isImportant ? 1.5 : 1.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: a.isImportant ? Colors.red.withAlpha(12) : Colors.black.withAlpha(6),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: catColor.withAlpha(25),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  a.category.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: catColor,
                                  ),
                                ),
                              ),
                              if (a.isImportant) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFF87171)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.priority_high_rounded, color: Colors.red, size: 10),
                                      Text(
                                        'HIGH PRIORITY',
                                        style: TextStyle(color: Colors.red, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                _formatTimestamp(a.timestamp),
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              if (widget.isAdmin) ...[
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                                  tooltip: 'Delete',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    _service.deleteAnnouncement(a.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Announcement removed')),
                                    );
                                  },
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        a.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        a.message,
                        style: const TextStyle(fontSize: 13, color: Colors.black87, height: 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.person_outline_rounded, size: 14, color: PlaceTrackTheme.textSecondary),
                          const SizedBox(width: 4),
                          Text(
                            a.author,
                            style: const TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
