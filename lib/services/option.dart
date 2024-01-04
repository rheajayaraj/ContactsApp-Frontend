import 'package:flutter/material.dart';
import 'package:contact_app/theme/colours.dart';

class OptionEntryWidget extends StatefulWidget {
  final Function(String) onOptionAdded;
  OptionEntryWidget({required this.onOptionAdded});

  @override
  _OptionEntryWidgetState createState() => _OptionEntryWidgetState();
}

class _OptionEntryWidgetState extends State<OptionEntryWidget> {
  late TextEditingController _optionController;

  @override
  void initState() {
    super.initState();
    _optionController = TextEditingController();
  }

  @override
  void dispose() {
    _optionController.dispose();
    super.dispose();
  }

  void _addOption() {
    final enteredOption = _optionController.text.trim();
    if (enteredOption.isNotEmpty) {
      widget.onOptionAdded(enteredOption);
      _optionController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _optionController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              hintText: 'Shared interests',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: primary, width: 2.0),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            style: TextStyle(
                fontSize: 16.0, fontWeight: FontWeight.w400, color: accent),
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          height: 60.0,
          child: ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll<Color>(primary),
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
            ),
            onPressed: _addOption,
            child: Text(
              'Add',
              style: TextStyle(
                color: secondary,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
