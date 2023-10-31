import 'package:dio/dio.dart';
import 'package:download_with_isolate/video_downloader.dart';
import 'package:get_it/get_it.dart';

GetIt getIt = GetIt.instance;

Future<void> serviceLocatorSetup() async {
  getIt.registerFactory<Dio>(() => Dio());
  getIt.registerFactory<VideoDownloader>(() => VideoDownloaderImp());
}
