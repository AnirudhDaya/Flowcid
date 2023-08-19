import 'package:flutter/material.dart';

class SoundButton extends StatelessWidget {
  final bool isSoundOn;
  final bool isEnabled ;
  final ValueChanged<bool> onChanged;

  const SoundButton({
    required this.isSoundOn,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
       onPressed: () {
        print("Before toggling isEnabled: $isSoundOn");
        onChanged(!isEnabled); // Toggle isEnabled without changing isSoundOn
        print("After toggling isEnabled: $isSoundOn");
      },
      style: ElevatedButton.styleFrom(
        primary: isEnabled ? (isSoundOn ? Colors.green : Colors.red) : Colors.grey,
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
      ),
      child: Icon(
         (isSoundOn ? Icons.volume_up : Icons.volume_off), // Keep the same icon when disabled
      ),
    );
  }
}


