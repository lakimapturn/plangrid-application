import 'package:flutter/material.dart';

class ContractorDialog extends StatefulWidget {
  final List<String> values;

  const ContractorDialog({Key? key, required this.values}) : super(key: key);

  @override
  _ContractorDialogState createState() => _ContractorDialogState();
}

class _ContractorDialogState extends State<ContractorDialog> {
  String? selectedValue;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Example data'),
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Room name'),
          DropdownButtonFormField(
            value: widget.values.isNotEmpty ? widget.values[0] : 'Room 1',
            items: ['Room 1', 'Room 2', 'Room 3', 'Room 4'].map((peer) {
              return DropdownMenuItem<String>(
                value: peer,
                child: Text(peer),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedValue = newValue;
              });
            },
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            if (selectedValue != null) {
              Navigator.of(context).pop(selectedValue);
            }
          },
        ),
      ],
    );
  }
}

