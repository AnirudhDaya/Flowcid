import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

class AppLauncher {
  // Define the ShellExecuteW function from the Windows API
  final shellExecute = DynamicLibrary.open('shell32.dll').lookupFunction<
      Int32 Function(
          IntPtr hwnd,
          Pointer<Utf16> lpOperation,
          Pointer<Utf16> lpFile,
          Pointer<Utf16> lpParameters,
          Pointer<Utf16> lpDirectory,
          Int32 nShowCmd),
      int Function(
          int hwnd,
          Pointer<Utf16> lpOperation,
          Pointer<Utf16> lpFile,
          Pointer<Utf16> lpParameters,
          Pointer<Utf16> lpDirectory,
          int nShowCmd)>('ShellExecuteW');

  // Function to launch another application
  void launchApplication(String applicationPath, {String? url}) async {
  if (url != null) {
    final browserPath = applicationPath.toNativeUtf16();
    final urlArg = url.toNativeUtf16();
    final result = shellExecute(0, nullptr, browserPath, urlArg, nullptr, 1);
    if (result <= 32) {
      // Handle error
    }
    calloc.free(browserPath);
    calloc.free(urlArg);
  } else {
    final path = applicationPath.toNativeUtf16();
    final result = shellExecute(0, nullptr, path, nullptr, nullptr, 1);
    if (result <= 32) {
      // Handle error
    }
    calloc.free(path);
  }
}
  Future<Map<String, String>?> pickAndLaunchApplication(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['exe'],
    );
    if (result != null) {
      final appPath = result.files.single.path;
      final appName = result.files.single.name;
      if (appPath != null) {
        return {'appName': appName, 'appPath': appPath};
      }
    }
    return null;  
  }

  bool isBrowser(String appName){
    if (appName.contains('chrome') || appName.contains('edge') || appName.contains('firefox') ||appName.contains('brave')){
      return true;
    }
    return false;
  }
}
