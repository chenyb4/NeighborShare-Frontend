import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aad_hybrid/configs/backend_address.dart';
import '../configs/colors.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';





class AddItem extends StatefulWidget {
  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  late TextEditingController _partyNameController;
  late TextEditingController _descriptionController;
  late TextEditingController _apartmentNumberController;
  late File? _imageFile=null; // Added variable to hold the selected image file
  bool _isAvailable = true;
  late String _ownerEmail = '';
  late String? _token;

  @override
  void initState() {
    super.initState();
    _partyNameController = TextEditingController();
    _descriptionController = TextEditingController();
    _apartmentNumberController = TextEditingController();
    _fetchOwnerEmail();
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _descriptionController.dispose();
    _apartmentNumberController.dispose();
    super.dispose();
  }

  Future<void> _fetchOwnerEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null) {
      Map<String, dynamic> payload = _parseJwt(_token!);
      setState(() {
        _ownerEmail = payload['email'] ?? '';
      });
    }
  }

  Map<String, dynamic> _parseJwt(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw FormatException('Invalid JWT token');
    }
    final payload = parts[1];
    return jsonDecode(utf8.decode(base64Url.decode(payload)));
  }

  Future<void> _addItem() async {
    // Ensure that all required fields are filled
    if (_partyNameController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        _apartmentNumberController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Ensure that an image is selected
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select an image'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final Map<String, dynamic> itemData = {
      'name': _partyNameController.text,
      'description': _descriptionController.text,
      'apartmentNumber': _apartmentNumberController.text,
      'isAvailable': _isAvailable,
      'ownerEmail': _ownerEmail,
    };

    // Create multipart request body
    var request = http.MultipartRequest('POST', Uri.parse(baseUrl + '/items/'));
    request.headers['Authorization'] = 'Bearer $_token';

    // Add item data fields
    itemData.forEach((key, value) {
      request.fields[key] = value.toString();
    });

    // Add image file
    request.files.add(http.MultipartFile.fromBytes(
      'file',
      await _imageFile!.readAsBytes(),
      filename: 'item_image.jpg',
    ));

    // Send request
    var response = await request.send();

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Item added successfully'),
          backgroundColor: Colors.green,
        ),
      );
      _partyNameController.clear();
      _descriptionController.clear();
      _apartmentNumberController.clear();
      setState(() {
        _isAvailable = true;
        _imageFile = null; // Clear selected image file
      });

      Future.delayed(Duration(milliseconds: 800), () {
        Navigator.pushReplacementNamed(context, '/myItems');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add item'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      final Uint8List? compressedImageBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 100,
        minHeight: 100,
        quality: 80,
      );
      if (compressedImageBytes != null) {
        final File tempFile = await _createTempFile(compressedImageBytes);
        setState(() {
          _imageFile = tempFile;
        });
      }
    }
  }


  Future<File> _createTempFile(Uint8List compressedImageBytes) async {
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/temp_image.jpg');
    await tempFile.writeAsBytes(compressedImageBytes);
    return tempFile;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add an Item"),
        centerTitle: true,
        backgroundColor: themeColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageFile != null) // Display selected image if available
              Image.file(_imageFile!),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Take Photo'), // Button to take photo
            ),
            SizedBox(height: 16),
            TextField(
              controller: _partyNameController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Item Name',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Description',
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _apartmentNumberController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Apartment Number',
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Available'),
                Switch(
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addItem,
              style: ElevatedButton.styleFrom(
                primary: themeColor,
                elevation: 3,
              ),
              child: Text(
                "Add Item",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
