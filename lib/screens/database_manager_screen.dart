// lib/screens/database_manager_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:attendance_system/models/student.dart';

class DatabaseManagerScreen extends StatefulWidget {
  const DatabaseManagerScreen({super.key});

  @override
  State<DatabaseManagerScreen> createState() => _DatabaseManagerScreenState();
}

class _DatabaseManagerScreenState extends State<DatabaseManagerScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _regController = TextEditingController();
  String _selectedCollection = 'semester_4';
  final List<String> _collections = ['absent_attendance', 'semester_4'];

  @override
  void dispose() {
    _dateController.dispose();
    _regController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Manager'),
        backgroundColor: const Color(0xFF4361EE),
        actions: [
          IconButton(
            onPressed: _showAddDateDialog,
            icon: const Icon(Icons.add_box),
            tooltip: 'Add New Date',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButton<String>(
              segments: _collections.map((collection) {
                String displayText;
                if (collection == 'absent_attendance') {
                  displayText = 'Semester 3';
                } else if (collection == 'semester_4') {
                  displayText = 'Semester 4';
                } else {
                  displayText = collection; // Fallback
                }
                return ButtonSegment<String>(
                  value: collection,
                  label: Text(displayText),
                );
              }).toList(),
              selected: {_selectedCollection},
              onSelectionChanged: (Set<String> newSelection) {
                setState(() {
                  _selectedCollection = newSelection.first;
                });
              },
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Colors.white; // Active tab text color
                    }
                    return null; // Use the component's default.
                  },
                ),
                backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                    if (states.contains(WidgetState.selected)) {
                      return Theme.of(context).primaryColor; // Active tab background color
                    }
                    return null; // Use the component's default.
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection(_selectedCollection).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text('No attendance records in $_selectedCollection.'),
                        ElevatedButton.icon(
                          onPressed: _showAddDateDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add First Date'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    // Sort documents by ID (date string) in descending order
                    final sortedDocs = docs
                      ..sort(
                        (a, b) => b.id.compareTo(a.id),
                      ); // Descending: newest first

                    final doc = sortedDocs[index];
                    final dateStr = doc.id;
                    final data = doc.data() as Map<String, dynamic>? ?? {};

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ExpansionTile(
                        leading: const Icon(
                          Icons.calendar_month,
                          color: Color(0xFF4361EE),
                        ),
                        title: Text(
                          _formatDate(dateStr),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '${(data['absents']?.length ?? 0) + (data['internal_od']?.length ?? 0) + (data['external_od']?.length ?? 0)} marked',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDeleteDate(dateStr),
                        ),
                        children: [
                          _buildFieldSection(
                            'Absentees',
                            data['absents'],
                            dateStr,
                            'absents',
                            Colors.red,
                          ),
                          _buildFieldSection(
                            'Internal OD',
                            data['internal_od'],
                            dateStr,
                            'internal_od',
                            Colors.orange,
                          ),
                          _buildFieldSection(
                            'External OD',
                            data['external_od'],
                            dateStr,
                            'external_od',
                            Colors.purple,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldSection(
    String label,
    dynamic list,
    String dateStr,
    String field,
    Color color,
  ) {
    final items = (list is List) ? List<String>.from(list) : <String>[];

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$label (${items.length})',
                style: TextStyle(fontWeight: FontWeight.bold, color: color),
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddRegDialog(dateStr, field),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add'),
                style: ElevatedButton.styleFrom(backgroundColor: color),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text('— No entries —', style: TextStyle(color: Colors.grey)),
          ...items.map((reg) {
            final student = students.firstWhere(
              (s) => s.regNum == reg,
              orElse: () =>
                  Student(regNum: reg, name: 'Unknown', email: '', phone: ''),
            );
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                radius: 14,
                backgroundColor: color.withOpacity(0.2),
                child: Text(
                  reg.substring(reg.length - 3),
                  style: TextStyle(fontSize: 10, color: color),
                ),
              ),
              title: Text(student.name, style: const TextStyle(fontSize: 14)),
              subtitle: Text(reg, style: const TextStyle(fontSize: 12)),
              trailing: IconButton(
                icon: const Icon(
                  Icons.remove_circle,
                  color: Colors.red,
                  size: 20,
                ),
                onPressed: () => _removeRegFromField(dateStr, field, reg),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  void _showAddDateDialog() {
    _dateController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Date'),
        content: TextField(
          controller: _dateController,
          decoration: const InputDecoration(hintText: 'YYYY-MM-DD'),
          keyboardType: TextInputType.datetime,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final date = _dateController.text.trim();
              if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) {
                _addNewDate(date);
                Navigator.pop(ctx);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid format. Use YYYY-MM-DD'),
                  ),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNewDate(String dateStr) async {
    await _firestore.collection(_selectedCollection).doc(dateStr).set({
      'absents': [],
      'internal_od': [],
      'external_od': [],
    }, SetOptions(merge: true));
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Date $dateStr added')));
  }

  void _showAddRegDialog(String dateStr, String field) {
    _regController.clear();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add to $field'),
        content: TextField(
          controller: _regController,
          decoration: const InputDecoration(hintText: 'Enter Reg Number'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final reg = _regController.text.trim();
              if (reg.isNotEmpty) {
                _addRegToField(dateStr, field, reg);
                Navigator.pop(ctx);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _addRegToField(String dateStr, String field, String reg) async {
    await _firestore.collection(_selectedCollection).doc(dateStr).update({
      field: FieldValue.arrayUnion([reg]),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Added $reg to $field')));
  }

  Future<void> _removeRegFromField(
    String dateStr,
    String field,
    String reg,
  ) async {
    await _firestore.collection(_selectedCollection).doc(dateStr).update({
      field: FieldValue.arrayRemove([reg]),
    });
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Removed $reg from $field')));
  }

  void _confirmDeleteDate(String dateStr) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Date?'),
        content: Text('Delete $dateStr and all its data?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await _firestore
                  .collection(_selectedCollection)
                  .doc(dateStr)
                  .delete();
              if (!mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Deleted $dateStr')));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
