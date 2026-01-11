import 'package:flutter/material.dart';

class CustomAutocompleteField extends StatelessWidget {
  final String label;
  final List<String> options;
  final TextEditingController controller;

  const CustomAutocompleteField({
    super.key,
    required this.label,
    required this.options,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: _filterOptions,
      onSelected: _onOptionSelected,
      fieldViewBuilder: _buildTextField,
    );
  }

  Iterable<String> _filterOptions(TextEditingValue textEditingValue) {
    if (textEditingValue.text == '') {
      return const Iterable<String>.empty();
    }
    return options.where((String option) {
      return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
    });
  }

  void _onOptionSelected(String selection) {
    controller.text = selection;
  }

  Widget _buildTextField(
    BuildContext context,
    TextEditingController fieldTextController,
    FocusNode focusNode,
    VoidCallback onFieldSubmitted,
  ) {
    if (controller.text.isNotEmpty && fieldTextController.text.isEmpty) {
      fieldTextController.text = controller.text;
    }
    return TextFormField(
      controller: fieldTextController,
      focusNode: focusNode,
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
      validator: (v) => v!.isEmpty ? 'Заполните поле' : null,
      onChanged: (val) => controller.text = val,
    );
  }
}
