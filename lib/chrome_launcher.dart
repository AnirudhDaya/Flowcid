import 'dart:io';

void openChromeWithTabs(List<String> urls) async {
  final chromePath = "C:\\Program Files\\Google\\Chrome\\Application\\chrome.exe";
  final arguments = ['-new-tab'];
  arguments.addAll(urls);

  try {
    await Process.run(chromePath, arguments);
    print('Chrome opened with specified tabs.');
  } catch (e) {
    print('Error opening Chrome: $e');
  }
}
