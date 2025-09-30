import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final Function(DateTime?) onDateSelected;
  final String hintText;
  final IconData icon;

  const CustomDatePicker({
    super.key,
    this.selectedDate,
    required this.onDateSelected,
    required this.hintText,
    required this.icon,
  });

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.brightBlue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textGray,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateSelected(picked);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.lightGray,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(
                icon,
                color: AppTheme.textGray,
                size: 20,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  selectedDate != null ? _formatDate(selectedDate!) : hintText,
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedDate != null
                        ? AppTheme.textGray
                        : AppTheme.textGray.withOpacity(0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
