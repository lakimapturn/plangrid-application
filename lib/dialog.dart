import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:plangrid/models/annotation_data.dart';
import 'dart:io';

import 'package:plangrid/models/room_manager.dart';

class ContractorDialog extends StatefulWidget {
  final AnnotationData data;
  final String roomKey;

  const ContractorDialog({Key? key, required this.data, required this.roomKey}) : super(key: key);

  @override
  _ContractorDialogState createState() => _ContractorDialogState();
}

class _ContractorDialogState extends State<ContractorDialog> {
  late AnnotationData selectedData;
  final ImagePicker _picker = ImagePicker();
  late List<String> roomOptions;
  final RoomManager roomManager = RoomManager();

  @override
  void initState() {
    super.initState();
    selectedData = widget.data;
    roomOptions = roomManager.getRoomsFromPage(widget.roomKey);
    print(roomOptions);
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedData.images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        selectedData.images.add(File(pickedFile.path));
      });
    }
  }

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
            value: widget.data.room != "" ? widget.data.room : roomOptions[0],
            items: roomOptions.map((peer) {
              return DropdownMenuItem<String>(
                value: peer,
                child: Text(peer),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedData.room = newValue!;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Pick Image'),
          ),
          ElevatedButton(
            onPressed: _takePhoto,
            child: const Text('Take a Photo'),
          ),
          const SizedBox(height: 20),
          Wrap(
            children: selectedData.images.map((file) {
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Image.file(
                  file,
                  width: 100,
                  height: 100,
                ),
              );
            }).toList(),
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
            Navigator.of(context).pop(selectedData);
          },
        ),
      ],
    );
  }
}
