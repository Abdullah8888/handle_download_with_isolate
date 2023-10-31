import 'dart:isolate';

import 'package:dio/dio.dart';

typedef ProgressHandler = Function(int rec, int total);
typedef ErrorHandler = Function(String);

abstract class VideoDownloader {
  Future<void> download({required DownloaderParams downloaderParams});
}

class VideoDownloaderImp implements VideoDownloader {
  VideoDownloaderImp();

  @override
  Future<void> download({required DownloaderParams downloaderParams}) async {
    try {
      Isolate.spawn(_startDownload, downloaderParams);
    } catch (e) {
      downloaderParams.errorHandler(e.toString());
    }
  }

  Future<void> _startDownload(DownloaderParams downloaderParams) async {
    try {
      await downloaderParams.dio
          .download(downloaderParams.downloadUrl, downloaderParams.path,
              onReceiveProgress: (rec, total) {
        final progressResponse = ProgressResponse(rec: rec, total: total);
        downloaderParams.sendPort.send(progressResponse);
      });
    } catch (e) {
      final error = ErrorResponse(message: e.toString());
      downloaderParams.sendPort.send(error);
    }
  }
}

class ProgressResponse {
  int? rec;
  int? total;
  String? error;
  ProgressResponse({this.rec, this.total, this.error});
}

class ErrorResponse {
  String? message;
  ErrorResponse({this.message});
}

class DownloaderParams {
  Dio dio;
  String downloadUrl;
  String path;
  ErrorHandler errorHandler;
  SendPort sendPort;
  DownloaderParams(
      {required this.dio,
      required this.sendPort,
      required this.downloadUrl,
      required this.path,
      required this.errorHandler});
}
