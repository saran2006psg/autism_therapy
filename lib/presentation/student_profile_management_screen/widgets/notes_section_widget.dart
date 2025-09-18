import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotesSectionWidget extends StatefulWidget {
  final List<Map<String, dynamic>> notes;
  final Function(Map<String, dynamic>) onNoteAdded;
  final Function(int, Map<String, dynamic>) onNoteUpdated;
  final Function(int) onNoteDeleted;

  const NotesSectionWidget({
    super.key,
    required this.notes,
    required this.onNoteAdded,
    required this.onNoteUpdated,
    required this.onNoteDeleted,
  });

  @override
  State<NotesSectionWidget> createState() => _NotesSectionWidgetState();
}

class _NotesSectionWidgetState extends State<NotesSectionWidget> {
  bool _isExpanded = false;
  final List<String> _availableTags = [
    'Behavioral',
    'Communication',
    'Social',
    'Academic',
    'Medical',
    'Family',
    'Progress',
    'Concerns',
    'Achievements',
    'Recommendations'
  ];

  void _showAddNoteDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    List<String> selectedTags = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 4.w,
                right: 4.w,
                top: 2.h,
                bottom: MediaQuery.of(context).viewInsets.bottom + 2.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 12.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.outline,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Add New Note',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Voice-to-text functionality would be implemented here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  const Text('Voice-to-text feature coming soon'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                        },
                        icon: CustomIconWidget(
                          iconName: 'mic',
                          color: Theme.of(context).colorScheme.primary,
                          size: 24,
                        ),
                        tooltip: 'Voice to Text',
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  TextFormField(
                    controller: titleController,
                    decoration: const InputDecoration(
                      labelText: 'Note Title *',
                      hintText: 'Enter note title',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 2.h),
                  TextFormField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      labelText: 'Note Content *',
                      hintText: 'Enter detailed note content',
                    ),
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Tags (Select relevant categories)',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    runSpacing: 1.h,
                    children: _availableTags.map((tag) {
                      final isSelected = selectedTags.contains(tag);
                      return FilterChip(
                        label: Text(tag),
                        selected: isSelected,
                        onSelected: (selected) {
                          setModalState(() {
                            if (selected) {
                              selectedTags.add(tag);
                            } else {
                              selectedTags.remove(tag);
                            }
                          });
                        },
                        backgroundColor:
                            Theme.of(context).colorScheme.surface,
                        selectedColor: Theme.of(context).colorScheme.primary
                            .withValues(alpha: 0.2),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                        labelStyle:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Cancel'),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (titleController.text.trim().isNotEmpty &&
                                contentController.text.trim().isNotEmpty) {
                              final newNote = {
                                'id': DateTime.now().millisecondsSinceEpoch,
                                'title': titleController.text.trim(),
                                'content': contentController.text.trim(),
                                'tags': selectedTags,
                                'createdDate': DateTime.now(),
                                'author': 'Current Therapist', // Dynamic therapist name
                              };
                              widget.onNoteAdded(newNote);
                              Navigator.of(context).pop();
                            }
                          },
                          child: const Text('Add Note'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showNoteDetails(Map<String, dynamic> note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 80.h,
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 3.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note['title'] ?? 'Note Details',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          // Edit functionality would be implemented here
                          break;
                        case 'share':
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Sharing note with team...'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                          break;
                        case 'export':
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Exporting note data...'),
                              backgroundColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          );
                          break;
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'edit',
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            const Text('Edit'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'share',
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'share',
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            const Text('Share with Team'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'export',
                        child: Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'download',
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 20,
                            ),
                            SizedBox(width: 2.w),
                            const Text('Export Data'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'person',
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      'By ${note['author'] ?? 'Unknown'} • ${_formatDate(note['createdDate'])}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 2.h),
              if (note['tags'] != null &&
                  (note['tags'] as List).isNotEmpty) ...[
                Wrap(
                  spacing: 2.w,
                  runSpacing: 1.h,
                  children: (note['tags'] as List).map<Widget>((tag) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary
                            .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        tag.toString(),
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 3.h),
              ],
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    note['content'] ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 6.h),
                ),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return '';
    if (date is DateTime) {
      return '${date.day}/${date.month}/${date.year}';
    }
    return date.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          leading: CustomIconWidget(
            iconName: 'note',
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
          title: Text(
            'Notes (${widget.notes.length})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: _showAddNoteDialog,
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
              ),
              CustomIconWidget(
                iconName: _isExpanded ? 'expand_less' : 'expand_more',
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                size: 24,
              ),
            ],
          ),
          children: [
            Padding(
              padding: EdgeInsets.all(4.w),
              child: widget.notes.isEmpty
                  ? Container(
                      padding: EdgeInsets.all(4.w),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'note_outlined',
                            color: AppTheme
                                .lightTheme.colorScheme.onSurfaceVariant,
                            size: 48,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No notes added yet',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'Tap the + button to add therapy notes',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.notes.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(height: 2.h),
                      itemBuilder: (context, index) {
                        final note = widget.notes[index];

                        return GestureDetector(
                          onTap: () => _showNoteDetails(note),
                          child: Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note['title'] ?? 'Untitled Note',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 1.h),
                                Text(
                                  note['content'] ?? '',
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    color: Theme.of(context).colorScheme
                                        .onSurfaceVariant,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (note['tags'] != null &&
                                    (note['tags'] as List).isNotEmpty) ...[
                                  SizedBox(height: 1.h),
                                  Wrap(
                                    spacing: 1.w,
                                    runSpacing: 0.5.h,
                                    children: (note['tags'] as List)
                                        .take(3)
                                        .map<Widget>((tag) {
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 1.5.w, vertical: 0.3.h),
                                        decoration: BoxDecoration(
                                          color: AppTheme
                                              .lightTheme.colorScheme.secondary
                                              .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          tag.toString(),
                                          style: AppTheme
                                              .lightTheme.textTheme.labelSmall
                                              ?.copyWith(
                                            color: AppTheme.lightTheme
                                                .colorScheme.secondary,
                                            fontSize: 10.sp,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ],
                                SizedBox(height: 1.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'By ${note['author'] ?? 'Unknown'} • ${_formatDate(note['createdDate'])}',
                                      style: AppTheme
                                          .lightTheme.textTheme.bodySmall
                                          ?.copyWith(
                                        color: Theme.of(context).colorScheme
                                            .onSurfaceVariant,
                                      ),
                                    ),
                                    CustomIconWidget(
                                      iconName: 'arrow_forward_ios',
                                      color: Theme.of(context).colorScheme
                                          .onSurfaceVariant,
                                      size: 16,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}


