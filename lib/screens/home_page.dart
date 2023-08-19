import 'package:flutter/material.dart';
import 'package:flowcid/widgets/play_stop_button.dart';
import 'package:flowcid/widgets/sound_button.dart';
import 'package:flowcid/widgets/dnd_button.dart';
import 'package:flutter/services.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:flutter_dnd/flutter_dnd.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isPlaying = false;
  bool _isSoundOn = true;
  bool _isDndOn = false;
  bool _isSoundEnabled = true;
  bool _isDndEnabled = true;

  void _togglePlayStop() {
    
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        if (_isSoundEnabled && _isSoundOn) {
          _turnSoundModeOff();
        }
        if (_isDndEnabled && !_isDndOn) {
          _turnDndOn();
        }
      } else {
        if (_isSoundEnabled && !_isSoundOn) {
          _turnSoundModeOn();
        }
        if (_isDndEnabled && _isDndOn) {
          _turnDndOff();
        }
      }
    });
  }


  void _turnSoundModeOn() async {
  try {
    // Check if the required permission is granted
    bool? isGranted = await PermissionHandler.permissionsGranted;

    if (isGranted == true) {
      // Permission is granted, proceed with changing sound mode
      await SoundMode.setSoundMode(RingerModeStatus.normal);
      setState(() {
        _isSoundOn = true;
      });
    } else {
      // Permission is not granted, open settings or show message
      await PermissionHandler.openDoNotDisturbSetting();
    }
  } on PlatformException {
    print('Please enable permissions required');
  }
}

void _turnSoundModeOff() async {
  try {
    // Check if the required permission is granted
    bool? isGranted = await PermissionHandler.permissionsGranted;

    if (isGranted == true) {
      // Permission is granted, proceed with changing sound mode
      await SoundMode.setSoundMode(RingerModeStatus.silent);
      setState(() {
        _isSoundOn = false;
      });
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
      setState(() {
        _isDndOn = true;
        print('Turning DND mode ON');
      });
    } else {
      FlutterDnd.gotoPolicySettings();
    }
  } catch (e) {
    print('Error while setting DND mode ON: $e');
  }
  }

  void _turnDndOff() async {
    try {
      await FlutterDnd.setInterruptionFilter(FlutterDnd.INTERRUPTION_FILTER_ALL);
      setState(() {
        _isDndOn = false;
        print('Turning DND mode OFF');
      });
    } catch (e) {
      print('Error while setting DND mode OFF: $e');
    }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Workflow Toy App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PlayStopButton(isPlaying: _isPlaying, onPressed: _togglePlayStop),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SoundButton(
                    isSoundOn: _isSoundOn,
                    isEnabled: _isSoundEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isSoundEnabled = value;
                        if (!_isPlaying) {
                          _isSoundEnabled = value;
                        }
                      });
                    },
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: DndButton(
                    isDndOn: _isDndOn,
                    isEnabled: _isDndEnabled,
                    onChanged: (value) {
                      setState(() {
                        _isDndEnabled = value;
                        if (!_isPlaying) {
                          _isDndEnabled = value;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}




