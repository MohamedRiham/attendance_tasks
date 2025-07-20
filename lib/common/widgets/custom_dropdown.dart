import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final Function(String?) onChanged;
  final List<String> items;
  final String labelText;
  const CustomDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
    required this.labelText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: value,
        onChanged: onChanged,
        decoration: InputDecoration(labelText: labelText),

        items: items
            .map(
              (status) =>
                  DropdownMenuItem<String>(value: status, child: Text(status)),
            )
            .toList(),
      ),
    );
  }
}
