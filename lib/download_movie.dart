import 'dart:io';
import 'dart:isolate';

import 'package:dio/dio.dart';
import 'package:download_with_isolate/video_downloader.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import 'di.dart';

class DownloadMovie extends StatefulWidget {
  const DownloadMovie({super.key});

  @override
  State<DownloadMovie> createState() => _DownloadMovieState();
}

class _DownloadMovieState extends State<DownloadMovie> {
  late VideoDownloader videoDownloader;
  late Dio dio;
  String btnText = 'Download Movie';
  String downloadUrl =
      "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";

  @override
  void initState() {
    super.initState();
    videoDownloader = getIt.get<VideoDownloader>();
    dio = getIt.get<Dio>();
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        setState(() {
          btnText = 'Downloading...';
        });
        showToast('Downloading...');
        await download();
      },
      child: Text(btnText),
    );
  }

  Future<void> download() async {
    final downloadsDir = await getDownloadsDirectory();
    final savePathUrl = '${downloadsDir!.path}/bee.mp4';
    print("savePathUrl is $savePathUrl");
    final receivePort = ReceivePort();
    final downloaderParams = DownloaderParams(
      dio: dio,
      sendPort: receivePort.sendPort,
      downloadUrl: downloadUrl,
      path: savePathUrl,
      errorHandler: (message) {
        print("error here: $message");
      },
    );

    videoDownloader.download(downloaderParams: downloaderParams);

    receivePort.listen((message) {
      if (message is ProgressResponse) {
        final progressResponse = message;
        print('rec is ${progressResponse.rec}');
        print('total is ${progressResponse.total}');
        if (progressResponse.rec == progressResponse.total) {
          showToast('Done downloading');
          setState(() {
            btnText = 'Done downloading';
          });
        }
      }
      if (message is ErrorResponse) {
        final errorResponse = message;
        print('progress error is ${errorResponse.message}');
      }
    });
  }
}

Future<void> showToast(String message) async {
  await Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP,
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 32);
}

Future<void> clearDownloadsDirectory() async {
  try {
    // Get the downloads directory
    final downloadsDir = await getDownloadsDirectory();
    // List all files in the directory
    List<FileSystemEntity> files = downloadsDir!.listSync();

    // Delete each file
    for (var file in files) {
      if (file is File) {
        file.deleteSync();
      }
    }

    print('All files in the downloads directory have been deleted.');
  } catch (e) {
    print('Error: $e');
  }
}
