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
      optionsBuilder: (TextEditingValue val) {
        if (val.text == '') return const Iterable<String>.empty();
        return options.where(
          (opt) => opt.toLowerCase().contains(val.text.toLowerCase()),
        );
      },
      onSelected: (String selection) => controller.text = selection,
      fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
        if (controller.text.isNotEmpty && textController.text.isEmpty) {
          textController.text = controller.text;
        }
        return TextFormField(
          controller: textController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            suffixIcon: const Icon(Icons.arrow_drop_down),
          ),
          validator: (v) => v!.isEmpty ? 'Заполните поле' : null,
          onChanged: (val) => controller.text = val,
        );
      },
    );
  }
}
