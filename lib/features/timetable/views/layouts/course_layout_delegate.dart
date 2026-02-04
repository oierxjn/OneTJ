import 'package:flutter/material.dart';

import 'package:onetj/models/timetable_index.dart';

class CourseLayoutDelegate extends MultiChildLayoutDelegate {
  CourseLayoutDelegate({
    required this.entries,
    required this.slotHeight,
    required this.slotCount,
  });

  final List<TimetableEntry> entries;
  final double slotHeight;
  final int slotCount;

  @override
  void performLayout(Size size) {
    for (int i = 0; i < entries.length; i += 1) {
      final TimetableEntry entry = entries[i];
      final Object id = courseId(i);
      if (!hasChild(id)) {
        continue;
      }
      final int startSlot = _clampSlot(entry.timeStart);
      final int endSlot = _clampSlot(entry.timeEnd);
      final double top = (startSlot - 1) * slotHeight + 6;
      final double height = (endSlot - startSlot + 1) * slotHeight - 12;
      final double cardHeight = height.clamp(40, double.infinity);

      layoutChild(
        id,
        BoxConstraints.tightFor(
          width: size.width,
          height: cardHeight,
        ),
      );
      positionChild(id, Offset(0, top));
    }
  }

  @override
  bool shouldRelayout(covariant CourseLayoutDelegate oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.slotHeight != slotHeight ||
        oldDelegate.slotCount != slotCount;
  }

  int _clampSlot(int slot) {
    if (slot < 1) {
      return 1;
    }
    if (slot > slotCount) {
      return slotCount;
    }
    return slot;
  }
}

Object courseId(int index) => 'course_$index';
