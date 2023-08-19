import 'package:flutter/material.dart';

class PlayStopButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const PlayStopButton({required this.isPlaying, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        width: 80, // Equal width and height for a circular button
        height: 80, // Equal width and height for a circular button
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPlaying ? Colors.red : Colors.green,
        ),
        child: Center(
          child: Icon(
            isPlaying ? Icons.stop : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

