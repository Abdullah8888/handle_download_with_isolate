import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WatchMovie extends StatefulWidget {
  const WatchMovie({super.key});

  @override
  State<WatchMovie> createState() => _WatchMovieState();
}

class _WatchMovieState extends State<WatchMovie> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.asset('assets/sample-mov-file.mov')
      ..initialize().then((_) {
        setState(() {});
      });

    // Add listener to restart the video when it reaches the end
    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        _controller.seekTo(Duration.zero);
        _controller.play();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video Demo')),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: _controller.value.isInitialized
          ? FloatingActionButton(
              onPressed: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: Icon(
                _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
              ),
            )
          : null,
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
