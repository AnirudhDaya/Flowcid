import 'package:android_intent_plus/android_intent.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

class AppLauncher {

  Future<void> launchApplication(String applicationPackage, {String? url}) async {
    if (url != null) {
      final intent = AndroidIntent(
        action: 'action_view',
        data: 'http://$url',
        package: applicationPackage,
      );
      await intent.launch();
    } else {
      final app = await DeviceApps.getApp(applicationPackage);
      if (app != null) {
        await InstalledApps.startApp(applicationPackage);
      }
    }
  }

 Future<Map<String, String>?> pickAndLaunchApplication(BuildContext context) async {
  List<AppInfo> apps = await InstalledApps.getInstalledApps();

  String? appName;
  String? appPackage;

  if (context.mounted) {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Choose an app', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: apps.map((app) {
                return ListTile(
                  title: Text(app.name ?? '', style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    appName = app.name;
                    appPackage = app.packageName;
                    Navigator.pop(context); // Close the dialog
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
  // ignore: unnecessary_null_comparison
  if (appName != null && appPackage != null) {
    return {
      'appName': appName!,
      'appPackage': appPackage!,
    };
  }

  return null;
}

  bool isBrowser(String appPackage) {
    return ['com.android.chrome', 'com.microsoft.emmx', 'org.mozilla.firefox']
        .contains(appPackage);
  }
}

