import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class Videoplayer extends StatefulWidget {
  final VideoPlayerController? controller; // now nullable

  const Videoplayer({super.key, required this.controller});

  @override
  VideoplayerState createState() => VideoplayerState();
}

class VideoplayerState extends State<Videoplayer> with WidgetsBindingObserver {
  bool _isPausedByLifecycle = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    widget.controller?.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        if (widget.controller?.value.isPlaying ?? false) {
          widget.controller?.pause();
          _isPausedByLifecycle = true;
        }
        break;
      case AppLifecycleState.resumed:
        if (_isPausedByLifecycle) {
          widget.controller?.play();
          _isPausedByLifecycle = false;
        }
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  Widget _buildVideoPlayer() {
    return Positioned.fill(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: widget.controller!.value.size.width,
          height: widget.controller!.value.size.height,
          child: VideoPlayer(widget.controller!),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.controller == null || !widget.controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return VisibilityDetector(
      key: Key(widget.controller.hashCode.toString()),
      onVisibilityChanged: (visibilityInfo) {
        var visibilityPercentage = visibilityInfo.visibleFraction * 100;
        if (visibilityPercentage > 50) {
          if (!(widget.controller?.value.isPlaying ?? false) &&
              !_isPausedByLifecycle) {
            widget.controller?.play();
          }
        } else {
          if (widget.controller?.value.isPlaying ?? false) {
            widget.controller?.pause();
          }
        }
      },
      child: GestureDetector(
        onTap: () {
          if (widget.controller?.value.isPlaying ?? false) {
            widget.controller?.pause();
          } else {
            widget.controller?.play();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(child: Container(color: Colors.black)),
            _buildVideoPlayer(),
            // if (!(widget.controller?.value.isPlaying ?? false))
              // const Center(
              //   child: Icon(
              //     Icons.play_arrow_rounded,
              //     size: 100,
              //     color: Colors.white70,
              //   ),
              // ),
          ],
        ),
      ),
    );
  }
}
