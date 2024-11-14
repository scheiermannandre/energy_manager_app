import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateBarWidget extends StatelessWidget {
  const DateBarWidget({
    required this.selectedDate,
    required this.onPrevious,
    required this.onNext,
    required this.pickDate,
    super.key,
  });

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback pickDate;
  final DateTime selectedDate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          _ArrowButton(onTap: onPrevious, isForward: false),
          Expanded(
            child: Stack(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: pickDate,
                      icon: const Icon(Icons.calendar_today_rounded),
                    ),
                    Text(DateFormat.yMEd().format(selectedDate)),
                  ],
                ),
              ],
            ),
          ),
          _ArrowButton(onTap: onNext, isForward: true),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.onTap,
    required this.isForward,
  });

  final VoidCallback onTap;
  final bool isForward;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        isForward
            ? Icons.keyboard_arrow_right_rounded
            : Icons.keyboard_arrow_left_rounded,
      ),
    );
  }
}
