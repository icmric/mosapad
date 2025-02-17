import 'dart:convert';
import 'dart:io';
import '../models/canvas_page_data.dart';
import '../widgets/canvas/draggable_text_field.dart';
import 'package:flutter/material.dart';
/// Service responsible for handling file storage operations, such as saving and loading canvas pages.
class FileStorageService {
  /// Gets the local path for storing files.
  Future<String> get _localPath async {
    String dirPath = r"C:\src\temp";
    final directory = Directory(dirPath);
    return directory.path;
  }

  // Creates a File object for the given filename in the local storage directory.
  Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    String filePath = path + r"\" + fileName;
    return File(filePath);
  }

  /// Saves the given CanvasPageData to a JSON file with the specified filename.
  Future<void> savePage(CanvasPageData pageData, String fileName) async {
    final file = await _localFile(fileName);

    final List<Map<String, dynamic>> textFieldsJson = pageData.textFields.map((textField) => textField.toJson()).toList(); // Convert text fields to JSON.
    final jsonString = jsonEncode(textFieldsJson); // Encode the list as a JSON string.

    await file.writeAsString(jsonString); // Write the JSON string to the file.
  }

  /// Loads CanvasPageData from a JSON file with the specified filename.
  Future<CanvasPageData?> loadPage(String fileName) async {
    try {
      final file = await _localFile(fileName);

      if (await file.exists()) {
        final jsonString = await file.readAsString(); // Read the JSON string from the file.
        final List<dynamic> jsonList = jsonDecode(jsonString); // Decode the JSON string into a list.
        // Create DraggableTextField widgets from the JSON data.
        final List<DraggableTextField> loadedTextFields = jsonList
            .map((json) => DraggableTextField.fromJson(
                  json,
                  (newPosition) {}, // Placeholder for onDragEnd callback.
                  () {}, // Placeholder for onEmptyDelete callback.
                  () {}, // Placeholder for onDragStart callback.
                ))
            .toList();

        return CanvasPageData(
          textFields: loadedTextFields,
          canvasSize: const Size(2000, 1000), // You might want to save/load canvas size as well.
        );
      } else {}
    } catch (e) {
      debugPrint("Error loading page: $e");
    }
    return null; // Return null if the file doesn't exist or there's an error.
  }

  // Loads the list of saved page filenames from the local storage directory.
  Future<List<String>> loadSavedPages() async {
    final path = await _localPath;
    final dir = Directory(path);

    List<String> savedPages = [];

    Future<void> listFiles(Directory dir, String currentPath) async {
      await for (var entity in dir.list(recursive: false)) {
        if (entity is File && entity.path.endsWith('.json')) {
          final relativePath = entity.path.replaceFirst(path + r'\', '');
          savedPages.add(currentPath + relativePath);
        } else if (entity is Directory) {
          //final folderName = entity.path.split(r'\').last;
          await listFiles(entity, currentPath);
        }
      }
    }

    if (await dir.exists()) {
      await listFiles(dir, '');
    }

    return savedPages;
  }
}
