import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class DataCollectionWidget extends StatefulWidget {
  final Function(String type, String value)? onDataCollected;
  final VoidCallback? onPhotoCapture;
  final VoidCallback? onVoiceNote;

  const DataCollectionWidget({
    super.key,
    this.onDataCollected,
    this.onPhotoCapture,
    this.onVoiceNote,
  });

  @override
  State<DataCollectionWidget> createState() => _DataCollectionWidgetState();
}

class _DataCollectionWidgetState extends State<DataCollectionWidget> {
  final TextEditingController _notesController = TextEditingController();
  String _selectedBehavior = 'positive';

  final List<Map<String, dynamic>> _behavioralMarkers = [
    {
      'id': 'positive',
      'label': 'Positive Response',
      'icon': 'thumb_up',
      'color': Colors.green
    },
    {
      'id': 'neutral',
      'label': 'Neutral Response',
      'icon': 'horizontal_rule',
      'color': Colors.orange
    },
    {
      'id': 'challenging',
      'label': 'Challenging Behavior',
      'icon': 'thumb_down',
      'color': Colors.red
    },
    {
      'id': 'engaged',
      'label': 'Highly Engaged',
      'icon': 'star',
      'color': Colors.blue
    },
    {
      'id': 'distracted',
      'label': 'Distracted',
      'icon': 'visibility_off',
      'color': Colors.grey
    },
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _onBehaviorTap(String behaviorId) {
    setState(() {
      _selectedBehavior = behaviorId;
    });
    widget.onDataCollected?.call('behavior', behaviorId);
  }

  void _onNotesSubmit() {
    if (_notesController.text.trim().isNotEmpty) {
      widget.onDataCollected?.call('notes', _notesController.text.trim());
      _notesController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
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
          Text(
            'Quick Data Collection',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            'Behavioral Markers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _behavioralMarkers.map((marker) {
              final isSelected = _selectedBehavior == marker['id'];
              return GestureDetector(
                onTap: () => _onBehaviorTap(marker['id'] as String),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (marker['color'] as Color).withValues(alpha: 0.2)
                        : Theme.of(context).colorScheme.surface,
                    border: Border.all(
                      color: isSelected
                          ? (marker['color'] as Color)
                          : Theme.of(context).colorScheme.outline
                              .withValues(alpha: 0.5),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: marker['icon'] as String,
                        color: marker['color'] as Color,
                        size: 16,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        marker['label'] as String,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? (marker['color'] as Color)
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 4.h),
          Text(
            'Session Notes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 2.h),
          TextField(
            controller: _notesController,
            decoration: InputDecoration(
              hintText: 'Add observations, notes, or comments...',
              suffixIcon: IconButton(
                onPressed: _onNotesSubmit,
                icon: CustomIconWidget(
                  iconName: 'send',
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
              ),
            ),
            maxLines: 3,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _onNotesSubmit(),
          ),
          SizedBox(height: 3.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onPhotoCapture,
                  icon: CustomIconWidget(
                    iconName: 'camera_alt',
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Photo'),
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onVoiceNote,
                  icon: CustomIconWidget(
                    iconName: 'mic',
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  label: const Text('Voice Note'),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }
}
