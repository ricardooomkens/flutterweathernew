import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String defaultCity;

  SettingsPage({required this.defaultCity});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  TextEditingController _cityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cityController.text = widget.defaultCity;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Default City:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _cityController,
              decoration: InputDecoration(
                labelText: 'Default City',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final newDefaultCity = _cityController.text;
                Navigator.pop(context, newDefaultCity);
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
