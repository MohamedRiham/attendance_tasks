import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final Function(String?) onChanged;
  final List<String> items;
  const CustomDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownButtonFormField<String>(
        isExpanded: true,
        value: value,
        onChanged: onChanged,

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
