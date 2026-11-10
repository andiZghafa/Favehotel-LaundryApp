import 'file_saver_interface.dart';
import 'file_saver_stub.dart'
    if (dart.library.html) 'file_saver_web.dart'
    if (dart.library.io) 'file_saver_io.dart';

Future<String> saveExportFile(List<int> bytes, String fileName, String categoryName) {
  return getFileSaver().saveFile(bytes, fileName, categoryName);
}
