import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:flutter_dnd/flutter_dnd.dart';


class Settings {
  Future<void> toggleSetting(String setting) async{
    if(setting == "sound") {
      _turnSoundModeOff();
    }
    if(setting == "dnd") {
      _turnDndOn();
    }
  }

  void _turnSoundModeOff() async {
    try {
      // Check if the required permission is granted
      bool? isGranted = await PermissionHandler.permissionsGranted;

      if (isGranted == true) {
        // Permission is granted, proceed with changing sound mode
        await SoundMode.setSoundMode(RingerModeStatus.silent);
      } else {
        // Permission is not granted, open settings or show message
        await PermissionHandler.openDoNotDisturbSetting();
      }
    } on PlatformException {
      print('Please enable permissions required');
    }
  }

  void _turnDndOn() async {
      try {
      bool? isAccessGranted = await FlutterDnd.isNotificationPolicyAccessGranted;

      if (isAccessGranted == true) {
        await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_NONE);
      } else {
        FlutterDnd.gotoPolicySettings();
      }
    } catch (e) {
      print('Error while setting DND mode ON: $e');
    }
  }

  Future<String?> pickAndLaunchApplication(BuildContext context) async {

    String? setting;

    if (context.mounted) {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[900],
            title: const Text('Settings', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: const Text(' Toggle Sound', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      setting = "sound";
                      Navigator.pop(context); // Close the dialog
                    },
                  ),
                   ListTile(
                    title: const Text(' Toggle DND', style: TextStyle(color: Colors.white)),
                    onTap: () {
                      setting = "dnd";
                      Navigator.pop(context); // Close the dialog
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
    // ignore: unnecessary_null_comparison
    if (setting!= null) {
      return setting;
    }

    return null;
  }


}
