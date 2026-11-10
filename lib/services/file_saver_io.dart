import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'file_saver_interface.dart';

class IoFileSaver implements FileSaver {
  @override
  Future<String> saveFile(List<int> bytes, String fileName, String categoryName) async {
    Directory? directory;
    if (Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download/laundry/$categoryName/');
      if (await downloadDir.exists() || await downloadDir.create(recursive: true).then((_) => true).catchError((_) => false)) {
        directory = downloadDir;
      }
    }
    directory ??= await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();

    final filePath = '${directory.path}${directory.path.endsWith('/') ? '' : '/'}$fileName';
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return 'Saved to $filePath';
  }
}

FileSaver getFileSaver() => IoFileSaver();
