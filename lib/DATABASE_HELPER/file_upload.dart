import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
class ImageUploadScreen extends StatefulWidget {
  const ImageUploadScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _selectedImage;
  String? _imageUrl;
  bool _isUploading = false;

  // Method to pick image from gallery
  Future<void> _pickImageFromGallery() async {
  try {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
      await _uploadImageToFirebase();
    }
  } catch (e) {
    log('Error picking image: $e');
    ScaffoldMessenger.of(context as BuildContext).showSnackBar(
      SnackBar(content: Text('Error: Please check app permissions')),
    );
  }
}
  // Method to upload image to Firebase Storage
  Future<void> _uploadImageToFirebase() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      
      // Create a unique filename with timestamp
      String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final imageRef = storageRef.child('images/$fileName');

      // Upload the file to Firebase Storage
      await imageRef.putFile(_selectedImage!);
      
      // Get the download URL
      _imageUrl = await imageRef.getDownloadURL();
      
      // Print URL to console
      log('Image URL: $_imageUrl');
      log('Upload completed at: ${DateTime.now()}');

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Image uploaded successfully!')),
      );

    } catch (e) {
      log('Error uploading image: $e');
      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Method to clear selection
  void _clearSelection() {
    setState(() {
      _selectedImage = null;
      // _imageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Image Upload'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Display selected image or placeholder
              _selectedImage != null
                  ? Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.blue),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Image.file(_selectedImage!, fit: BoxFit.cover),
                    )
                  : Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
          
              SizedBox(height: 20),
          
              // Upload button
              _isUploading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _selectedImage != null 
                          ? _uploadImageToFirebase
                          : _pickImageFromGallery,
                      icon: Icon(_selectedImage != null 
                          ? Icons.cloud_upload 
                          : Icons.photo_library),
                      label: Text(_selectedImage != null 
                          ? 'Upload to Firebase' 
                          : 'Pick from Gallery'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                    ),
          
              SizedBox(height: 10),
          
              // Clear button
              if (_selectedImage != null)
                TextButton(
                  onPressed: _clearSelection,
                  child: Text('Clear Selection'),
                ),
          
              SizedBox(height: 20),
          
              // Display image URL if available
              if (_imageUrl != null)
                Column(
                  children: [
                    Text(
                      'Upload Successful!',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'URL printed to console',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}