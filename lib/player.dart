import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:insoft/controller.dart';
import 'package:video_player/video_player.dart';
import 'package:get/get.dart';

class PlayerPage extends StatefulWidget {
  final bool isOnline;

  const PlayerPage({super.key, this.isOnline = false});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  late VideoPlayerController _controller;
  double _currentSliderValue = 0;
  bool _showControls = true;

  @override
  void initState() {
    initialize();
    _hideControlsAfterDelay();
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void initialize() {
    if (widget.isOnline) {
      _controller = VideoPlayerController.networkUrl(Uri.parse(
          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4'))
        ..initialize().then((_) {
          setState(() {});
        })
        ..addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            Get.find<VideoController>().isPlaying.value = false;
          }
          setState(() {
            _currentSliderValue = _controller.value.position.inSeconds.toDouble();
          });
        });
    } else {
      _controller = VideoPlayerController.asset("lib/assets/otajonov.mp4")
        ..initialize().then((_) {
          setState(() {});
        })
        ..addListener(() {
          if (_controller.value.position == _controller.value.duration) {
            Get.find<VideoController>().isPlaying.value = false;
          }
          setState(() {
            _currentSliderValue = _controller.value.position.inSeconds.toDouble();
          });
        });
    }
  }

  void _seekForward10Seconds() {
    final newPosition = _controller.value.position + const Duration(seconds: 10);
    if (newPosition < _controller.value.duration) {
      _controller.seekTo(newPosition);
    } else {
      _controller.seekTo(_controller.value.duration);
    }
  }

  void _seekBackward10Seconds() {
    final newPosition = _controller.value.position - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      _controller.seekTo(newPosition);
    } else {
      _controller.seekTo(Duration.zero);
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_showControls) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(':');
  }

  void _showQualityDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Formatni tanlang', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                  SizedBox(height: 10),
                  Text('720', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                  Text('480', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                  Text('320', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
                ],
              ),
            )
          );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VideoController>(builder: (video) {
      return PopScope(
        canPop: !video.isLocked.value,
        onPopInvoked: (val) async => !video.isLocked.value,
        child: AnnotatedRegion<SystemUiOverlayStyle>(
          value: video.isLocked.value
              ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.black,
          )
              : SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showControls = !_showControls;
              });
              // if (_showControls) {
              //   _hideControlsAfterDelay();
              // }
            },
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.black,
                body: Stack(
                  children: [

                    Center(
                      child: _controller.value.isInitialized
                          ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: Stack(
                          children: [
                            VideoPlayer(_controller),
                            if (_showControls)
                              Positioned.fill(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _seekBackward10Seconds,
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.all(20),
                                          child: Image.asset("lib/assets/backward.png",
                                              height: 40, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          if (video.isPlaying.value) {
                                            _controller.pause();
                                            video.isPlaying.value = false;
                                            video.update();
                                          } else {
                                            _controller.play();
                                            video.isPlaying.value = true;
                                            video.update();
                                          }
                                        },
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.all(20),
                                          child: video.isPlaying.value ? Image.asset("lib/assets/big_pause.png",
                                              height: 40, color: Colors.white) :
                                          Image.asset("lib/assets/big_play.png",
                                              height: 40, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: _seekForward10Seconds,
                                        child: Container(
                                          color: Colors.transparent,
                                          padding: const EdgeInsets.all(20),
                                          child: Image.asset("lib/assets/forward.png",
                                              height: 40, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )
                          : const CircularProgressIndicator(color: Colors.white),
                    ),

                    if (_showControls)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            height: 100,
                            child: video.isLocked.value
                                ? const SizedBox()
                                : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  style: IconButton.styleFrom(
                                      backgroundColor: Colors.white12,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(7))),
                                  icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                IconButton(
                                  style: IconButton.styleFrom(
                                      backgroundColor: video.isMuted.value
                                          ? Colors.white12
                                          : const Color(0xff6F94F4),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(7))),
                                  icon: video.isMuted.value
                                      ? Image.asset("lib/assets/unmute.png",
                                      height: 22, color: Colors.white)
                                      : Image.asset("lib/assets/mute.png",
                                      height: 22, color: Colors.white),
                                  onPressed: () {
                                    setState(() {
                                      video.isMuted.value = !video.isMuted.value;
                                      _controller.setVolume(video.isMuted.value ? 0 : 1);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 150,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                video.isLocked.value
                                    ? const SizedBox()
                                    : Padding(padding: const EdgeInsets.symmetric(horizontal: 23),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(_formatDuration(_controller.value.position),
                                          style: const TextStyle(color: Colors.white)),
                                      Text(_formatDuration(_controller.value.duration),
                                          style: const TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                video.isLocked.value
                                    ? const SizedBox()
                                    : Slider(
                                  value: _currentSliderValue,
                                  min: 0,
                                  max: _controller.value.duration.inSeconds.toDouble(),
                                  activeColor: const Color(0xff6F94F4),
                                  secondaryActiveColor: const Color(0xff6F94F4),
                                  onChanged: (double value) {
                                    setState(() {
                                      _currentSliderValue = value;
                                      _controller.seekTo(Duration(seconds: value.toInt()));
                                    });
                                  },
                                ),
                                Padding(padding: const EdgeInsets.symmetric(horizontal: 11),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    video.isLocked.value
                                        ? const SizedBox()
                                        : IconButton(
                                      onPressed: () {
                                        if (video.isPlaying.value) {
                                          _controller.pause();
                                          video.isPlaying.value = false;
                                          video.update();
                                        } else {
                                          _controller.play();
                                          video.isPlaying.value = true;
                                          video.update();
                                        }
                                      },
                                      icon: video.isPlaying.value
                                          ? Image.asset("lib/assets/pause.png",
                                          height: 20, color: Colors.white)
                                          : Image.asset("lib/assets/play.png",
                                          height: 20, color: Colors.white),
                                    ),
                                    video.isLocked.value
                                        ? IconButton(
                                        onPressed: () {
                                          video.isLocked.value = false;
                                          video.update();
                                        },
                                        icon: Image.asset("lib/assets/locked.png",
                                            height: 24, color: Colors.white))
                                        : Row(
                                      children: [
                                        IconButton(
                                            onPressed: () {
                                              video.isLocked.value = true;
                                              video.update();
                                            },
                                            icon: Image.asset("lib/assets/unlocked.png",
                                                height: 24, color: Colors.white)),
                                        IconButton(
                                            onPressed: () {
                                              _seekForward10Seconds();
                                            },
                                            icon: Image.asset("lib/assets/fwd.png",
                                                height: 15, color: Colors.white)),
                                        IconButton(
                                            onPressed: _showQualityDialog,
                                            icon: Image.asset("lib/assets/hd.png",
                                                height: 20, color: Colors.white)),
                                        IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (MediaQuery.of(context).orientation ==
                                                    Orientation.portrait) {
                                                  SystemChrome.setPreferredOrientations([
                                                    DeviceOrientation.landscapeRight,
                                                    DeviceOrientation.landscapeLeft,
                                                  ]);
                                                } else {
                                                  SystemChrome.setPreferredOrientations([
                                                    DeviceOrientation.portraitUp,
                                                    DeviceOrientation.portraitDown,
                                                  ]);
                                                }
                                              });
                                            },
                                            icon: Image.asset("lib/assets/expand.png",
                                                height: 20, color: Colors.white)),
                                      ],
                                    )
                                  ],
                                ),
                                )
                              ],
                            ),
                          )
                        ],
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
