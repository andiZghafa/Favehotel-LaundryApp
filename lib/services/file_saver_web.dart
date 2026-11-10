import 'package:universal_html/html.dart' as html;
import 'file_saver_interface.dart';

class WebFileSaver implements FileSaver {
  @override
  Future<String> saveFile(List<int> bytes, String fileName, String categoryName) async {
    final blob = html.Blob(
      [bytes],
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    html.Url.revokeObjectUrl(url);
    return 'Downloaded $fileName successfully in browser.';
  }
}

FileSaver getFileSaver() => WebFileSaver();
