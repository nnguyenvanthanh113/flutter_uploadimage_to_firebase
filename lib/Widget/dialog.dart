import 'package:flutter/material.dart';

class ShowDialog extends StatelessWidget {
  const ShowDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: ElevatedButton(
      child: const Text('Open Dialog'),
      onPressed: () {
        showDialog(
            context: context,
            builder: (_) {
              return const MyDialog();
            });
      },
    )));
  }
}

class MyDialog extends StatefulWidget {
  const MyDialog({Key? key}) : super(key: key);

  @override
  _MyDialogState createState() => new _MyDialogState();
}

class _MyDialogState extends State<MyDialog> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _fileNameController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  late bool _authorValidation = false;
  late bool _fileNameValidation = false;
  //validation
  bool validateTextField(String userInput, String field) {
    print('field: $field');
    if (userInput.isEmpty) {
      setState(() {
        //isUserNameValidate = true;
        switch (field) {
          case 'author':
            _authorValidation = true;
            break;
          case 'filename':
            _fileNameValidation = true;
            break;
        }
      });
      return true;
    }
    setState(() {
      //isUserNameValidate = false;
      switch (field) {
        case 'author':
          _authorValidation = false;
          break;
        case 'filename':
          _fileNameValidation = false;
          break;
      }
    });
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('information file!'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            //author
            TextField(
              controller: _authorController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Vui lòng nhập tác giả!",
                errorText: _authorValidation ? 'Vui lòng nhập tác giả!' : null,
              ),
              onChanged: (value) {
                setState(() {
                  //_description = value;
                });
              },
            ),
            // file name
            TextField(
              controller: _fileNameController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: "Vui lòng nhập tên file!",
                errorText:
                    _fileNameValidation ? 'Vui lòng nhập tên file!' : null,
              ),
              onChanged: (value) {
                setState(() {
                  //_description = value;
                });
              },
            ),
            //description
            TextField(
              controller: _descriptionController,
              textInputAction: TextInputAction.go,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                hintText: "Vui lòng nhập miêu tả file",
              ),
              onChanged: (value) {
                setState(() {
                  //_description = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              primary: Colors.blue,
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
              textStyle:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          child: const Text('OK'),
          onPressed: () {
            //validateTextField(_authorController.text, 'author');
            //validateTextField(_fileNameController.text, 'filename');

            setState(() {
              // Navigator.pop(context);
            });
          },
        ),
      ],
    );
  }
}
