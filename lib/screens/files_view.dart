import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pothole/constants.dart';
import 'package:pothole/service/network.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FilesView extends StatefulWidget {
  const FilesView({Key? key}) : super(key: key);

  @override
  _FilesViewState createState() => _FilesViewState();
}

class _FilesViewState extends State<FilesView> {
  List<FileSystemEntity> files = <FileSystemEntity>[]; //Recording Files
  List<String> uploadedFiles = <String>[]; //Uploded File Paths
  final Connectivity _connectivity = Connectivity();

  @override
  void initState() {
    //Refresh all files at initial
    _listOfFiles();

    //Check which files are uploded
    _uploadedFilesPref();

    //Check network connection to upload files automatically
    _uploadFilesWhenNetworkAvailable();

    //When network connection is changed (mobile-wifi-none) try to upload files
    _connectivity.onConnectivityChanged.listen((event) {
      _uploadFilesWhenNetworkAvailable();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () async {
                await NetworkHandler.getFirst();
              },
              child: Text("Network Test")),
          Expanded(
              child: ListView.builder(
            itemCount: files.length,
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: buildFileCard(files[index]),
            ),
          ))
        ],
      ),
    );
  }

  void _listOfFiles() {
    getApplicationDocumentsDirectory().then((value) {
      final myPath = value.path;
      final newfiles = Directory("$myPath/records/").listSync();
      setState(() {
        files = newfiles;
      });
    });
  }

  Future<void> uploadFile(String path) async {
    if (uploadedFiles.contains(path)) return;
    try {
      await NetworkHandler.patchFile(path);
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        uploadedFiles.add(path);
        prefs.setStringList("uploadedFiles", uploadedFiles);
      });
    } catch (e) {
      print(e);
    }
  }

  buildFileCard(FileSystemEntity file) {
    IconData? chooseIcon(String path) {
      return uploadedFiles.contains(path) ? Icons.check : Icons.upload;
    }

    return Card(
      color: Constant.card,
      child: ListTile(
        onTap: () {
          OpenFile.open(
            file.path,
            type: "application/vnd.ms-excel",
          );
        },
        title: Text(file.path.split('/').last),
        subtitle:
            Text((file.statSync().size / 1024).toStringAsFixed(2) + " kb"),
        leading: Icon(Icons.folder),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                onPressed: () {
                  uploadFile(file.path);
                },
                icon: Icon(
                  chooseIcon(file.path),
                  color: Colors.blueGrey,
                )),
            IconButton(
                icon: Icon(
                  Icons.share,
                  color: Colors.blueAccent,
                ),
                onPressed: () async {
                  await Share.shareFiles([file.path]);
                }),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.redAccent,
              ),
              onPressed: () {
                file.deleteSync(recursive: true);
                setState(() {
                  uploadedFiles.remove(file.path);
                  _listOfFiles();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void _uploadedFilesPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uploadedFiles = prefs.getStringList("uploadedFiles") ?? <String>[];
  }

  Future<void> _uploadFilesWhenNetworkAvailable() async {
    final result = await _connectivity.checkConnectivity();
    try {
      if (result != ConnectivityResult.none) {
        for (var file in files) {
          uploadFile(file.path);
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
