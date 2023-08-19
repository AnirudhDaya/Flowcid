import 'package:flutter/material.dart';

class DndButton extends StatelessWidget {
  final bool isDndOn;
  final bool isEnabled;
  final ValueChanged<bool> onChanged;

  const DndButton({
    required this.isDndOn,
    required this.isEnabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
       onPressed: () {
        onChanged(!isEnabled); // Toggle isEnabled without changing isSoundOn
      },
      style: ElevatedButton.styleFrom(
        primary: isEnabled ? (isDndOn ? Colors.green : Colors.red) : Colors.grey,
        shape: CircleBorder(),
        padding: EdgeInsets.all(20),
      ),
      child: Icon(
         (isDndOn ? Icons.do_not_disturb_on_sharp : Icons.do_not_disturb_off_sharp), // Keep the same icon when disabled
      ),
    );
  }
}





  