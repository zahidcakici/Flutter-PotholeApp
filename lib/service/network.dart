import 'package:http/http.dart' as http;
import 'package:pothole/constants.dart';

class NetworkHandler {
  //While working with emulator we use baseUrlEmulator:"http://10.0.2.2:5000/"
  //baseUrlLoal:"http://localhost:5000/"

  static String baseUrl = Constant.baseUrlEmulator; //Constant.baseUrlLocal

  static Future getFirst() => http.get(Uri.parse(baseUrl));

  static Future<http.StreamedResponse> patchFile(String filepath) async {
    String url = baseUrl + "file";
    var request = http.MultipartRequest('PATCH', Uri.parse(url));
    request.files.add(await http.MultipartFile.fromPath("recording", filepath));
    request.headers.addAll({
      "Content-type": "multipart/form-data",
    });
    return request.send();
  }

  static Future getMarkers() => http.get(Uri.parse(baseUrl + "markers"));
}
