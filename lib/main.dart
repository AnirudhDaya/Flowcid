import 'package:flowcid_desktop/dbhelper/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'home_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await MongoDatabase.connect();
    runApp(const MyApp());
  } catch (e) {
    print('Error during app initialization: $e');
  }

  doWhenWindowReady(() {
    final win = appWindow;
    // const initialSize = Size(600, 450);
    // win.minSize = initialSize;
    // win.size = initialSize;
    win.alignment = Alignment.center;
    win.title = "Flowcid";
    win.show();
  });
}

const borderColor = Colors.black;

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: WindowBorder(
          color: borderColor,
          width: 0.001,
          child: const RightSide(),
        ),
      ),
    );
  }
}

const backgroundStartColor = Colors.black; // Transparent
const backgroundEndColor = Colors.black; // Transparent

class RightSide extends StatelessWidget {
  const RightSide({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [backgroundStartColor, backgroundEndColor],
          stops: [0.0, 1.0],
        ),
      ),
      child: Column(
        children: [
          WindowTitleBarBox(
            child: Row(
              children: [
                Expanded(child: MoveWindow()),
                const WindowButtons(),
              ],
            ),
          ),
          Expanded(child: HomeScreen()), // Add your existing HomeScreen here
        ],
      ),
    );
  }
}

final buttonColors = WindowButtonColors(
  iconNormal: Colors.blue,
  mouseOver: Colors.grey[500],
  mouseDown: const Color(0xFF805306),
  iconMouseOver: const Color(0xFF805306),
  iconMouseDown: const Color(0xFFFFD500),
);

final closeButtonColors = WindowButtonColors(
  mouseOver: const Color(0xFFD32F2F),
  mouseDown: const Color(0xFFB71C1C),
  iconNormal: Colors.blue,
  iconMouseOver: Colors.white,
);

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
