import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import 'main.dart';
import 'resource/icon.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  File? _imageFile;
  File? _videoFile;

  bool is43 = false;
  bool isFullScreen = true;
  bool is11 = false;


  CameraController? controller;
  double zoom = 1.0;
  double _scaleFactor = 1.0;

  VideoPlayerController? videoController;

  bool _isCameraInitialized = false;
  final resolutionPresets = ResolutionPreset.values;
  ResolutionPreset currentResolutionPreset = ResolutionPreset.high;

  // double _minAvailableZoom = 1.0;
  // double _maxAvailableZoom = 1.0;
  // double _currentZoomLevel = 1.0;
  //
  // double _minAvailableExposureOffset = 0.0;
  // double _maxAvailableExposureOffset = 0.0;
  // double _currentExposureOffset = 0.0;

  FlashMode? _currentFlashMode;

  bool _isRearCameraSelected = false;

  bool _isRecordingInProgress = false;
  bool _isVideoCameraSelected = false;

  Future<XFile?> takePicture() async {
    videoController = null;
    final CameraController? cameraController = controller;
    if (cameraController!.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }
    try {
      XFile file = await cameraController.takePicture();
      return file;
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
      return null;
    }
  }

  Future<void> startVideoRecording() async {
    final CameraController? cameraController = controller;
    if (controller!.value.isRecordingVideo) {
      // A recording has already started, do nothing.
      return;
    }
    try {
      await cameraController!.startVideoRecording();
      setState(() {
        _isRecordingInProgress = true;
        print(_isRecordingInProgress);
      });
    } on CameraException catch (e) {
      print('Error starting to record video: $e');
    }
  }

  Future<XFile?> stopVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Recording is already is stopped state
      return null;
    }
    try {
      XFile file = await controller!.stopVideoRecording();
      setState(() {
        _isRecordingInProgress = false;
        print(_isRecordingInProgress);
      });
      return file;
    } on CameraException catch (e) {
      print('Error stopping video recording: $e');
      return null;
    }
  }

  Future<void> pauseVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // Video recording is not in progress
      return;
    }
    try {
      await controller!.pauseVideoRecording();
    } on CameraException catch (e) {
      print('Error pausing video recording: $e');
    }
  }

  Future<void> resumeVideoRecording() async {
    if (!controller!.value.isRecordingVideo) {
      // No video recording was in progress
      return;
    }
    try {
      await controller!.resumeVideoRecording();
    } on CameraException catch (e) {
      print('Error resuming video recording: $e');
    }
  }

  Future<void> _startVideoPlayer() async {
    if (_videoFile != null) {
      _imageFile = null;
      videoController = VideoPlayerController.file(_videoFile!);
      print('----videoController-----$videoController');
      await videoController!.initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized,
        // even before the play button has been pressed.
        setState(() {});
      });
      await videoController!.setLooping(true);
      await videoController!.play();
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = controller;

    // Instantiating the camera controller
    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // Dispose the previous controller
    await previousCameraController?.dispose();

    // Replace with the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    // Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    // Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    // Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }

    // cameraController
    //     .getMaxZoomLevel()
    //     .then((value) => _maxAvailableZoom = value);
    //
    // cameraController
    //     .getMinZoomLevel()
    //     .then((value) => _minAvailableZoom = value);
    //
    // cameraController
    //     .getMinExposureOffset()
    //     .then((value) => _minAvailableExposureOffset = value);
    //
    // cameraController
    //     .getMaxExposureOffset()
    //     .then((value) => _maxAvailableExposureOffset = value);

    _currentFlashMode = controller!.value.flashMode;
  }

  @override
  void initState() {
    SystemChrome.setEnabledSystemUIOverlays([]);
    onNewCameraSelected(cameras[0]);
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    videoController?.dispose();
    super.dispose();
  }

  Widget screenController(String icon, bool isExpand, Function() onClick) {
    return InkWell(
      onTap: onClick,
      child: Image.asset(
        icon,
        width: icon == icFullScreen ? 30 : 50,
        color: isExpand ? Colors.amber : Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isCameraInitialized
          ? Stack(
              alignment: Alignment.topCenter,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onScaleStart: (details) {
                    zoom = _scaleFactor;
                  },
                  onScaleUpdate: (details) {
                    _scaleFactor = zoom * details.scale;
                    controller!.setZoomLevel(_scaleFactor);
                    debugPrint('Gesture updated');
                  },
                  child: AspectRatio(
                      aspectRatio: isFullScreen
                          ? MediaQuery.of(context).size.aspectRatio
                          : is43
                              ? 4/3
                              : is11
                                  ? 1/1
                                  : controller!.value.aspectRatio,
                      child: controller!.buildPreview()),
                ),
                // if (_isRearCameraSelected)
                //   Positioned(
                //       top: 10,
                //       child: SizedBox(
                //           width: MediaQuery.of(context).size.width,
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                //             children: [
                //               screenController(ic43, is43, () async {
                //                 setState(() {
                //                   is43 = true;
                //                   isFullScreen = false;
                //                   is11 = false;
                //                 });
                //               }),
                //               screenController(icFullScreen, isFullScreen,
                //                   () async {
                //                 setState(() {
                //                   isFullScreen = true;
                //                   is43 = false;
                //                   is11 = false;
                //                 });
                //               }),
                //               screenController(ic11, is11, () async {
                //                 setState(() {
                //                   is11 = true;
                //                   is43 = false;
                //                   isFullScreen = false;
                //                 });
                //               })
                //             ],
                //           ))),
                if (!_isRearCameraSelected)
                  Positioned(
                      top: 10,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  _currentFlashMode = FlashMode.off;
                                });
                                await controller!.setFlashMode(
                                  FlashMode.off,
                                );
                              },
                              child: Icon(
                                Icons.flash_off,
                                color: _currentFlashMode == FlashMode.off
                                    ? Colors.amber
                                    : Colors.white,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  _currentFlashMode = FlashMode.auto;
                                });
                                await controller!.setFlashMode(
                                  FlashMode.auto,
                                );
                              },
                              child: Icon(
                                Icons.flash_auto,
                                color: _currentFlashMode == FlashMode.auto
                                    ? Colors.amber
                                    : Colors.white,
                              ),
                            ),
                            InkWell(
                              onTap: () async {
                                setState(() {
                                  _currentFlashMode = FlashMode.always;
                                });
                                await controller!.setFlashMode(
                                  FlashMode.always,
                                );
                              },
                              child: Icon(
                                Icons.flash_on,
                                color: _currentFlashMode == FlashMode.always
                                    ? Colors.amber
                                    : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      )),
                // Positioned(
                //   top: 80,
                //   right: 20,
                //   child: Column(
                //     children: [
                //       Container(
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.circular(10.0),
                //         ),
                //         child: Padding(
                //           padding: const EdgeInsets.all(8.0),
                //           child: Text(
                //             _currentExposureOffset.toStringAsFixed(1) + 'x',
                //             style: TextStyle(color: Colors.black),
                //           ),
                //         ),
                //       ),
                //       RotatedBox(
                //         quarterTurns: 3,
                //         child: SizedBox(
                //           width: 470,
                //           height: 10,
                //           child: Slider(
                //             value: _currentExposureOffset,
                //             min: _minAvailableExposureOffset,
                //             max: _maxAvailableExposureOffset,
                //             activeColor: Colors.white,
                //             inactiveColor: Colors.white30,
                //             onChanged: (value) async {
                //               setState(() {
                //                 _currentExposureOffset = value;
                //               });
                //               await controller!.setExposureOffset(value);
                //             },
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.225,
                    width: MediaQuery.of(context).size.width,
                    color: Colors.black12,
                    child: Column(
                      children: [
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.center,
                        //   children: [
                        //     SizedBox(
                        //       width: 320,
                        //       child: Slider(
                        //         value: _currentZoomLevel,
                        //         min: _minAvailableZoom,
                        //         max: _maxAvailableZoom,
                        //         activeColor: Colors.white,
                        //         inactiveColor: Colors.white30,
                        //         onChanged: (value) async {
                        //           setState(() {
                        //             _currentZoomLevel = value;
                        //           });
                        //           await controller!.setZoomLevel(value);
                        //         },
                        //       ),
                        //     ),
                        //     Container(
                        //       decoration: BoxDecoration(
                        //         color: Colors.black87,
                        //         borderRadius: BorderRadius.circular(10.0),
                        //       ),
                        //       child: Padding(
                        //         padding: EdgeInsets.all(8.0),
                        //         child: Text(
                        //           _currentZoomLevel.toStringAsFixed(1) + 'x',
                        //           style: const TextStyle(color: Colors.white),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: _isRecordingInProgress
                                  ? null
                                  : () {
                                if (_isVideoCameraSelected) {
                                  setState(() {
                                    _isVideoCameraSelected = false;
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                primary: _isVideoCameraSelected
                                    ? Colors.black54
                                    : Colors.black,
                                backgroundColor: _isVideoCameraSelected
                                    ? Colors.white30
                                    : Colors.white,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 45, vertical: 3),
                                child: Text('IMAGE'),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (!_isVideoCameraSelected) {
                                  setState(() {
                                    _isVideoCameraSelected = true;
                                  });
                                }
                              },
                              style: TextButton.styleFrom(
                                primary: _isVideoCameraSelected
                                    ? Colors.black
                                    : Colors.black54,
                                backgroundColor: _isVideoCameraSelected
                                    ? Colors.white
                                    : Colors.white30,
                              ),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 45, vertical: 3),
                                child: Text('VIDEO'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isCameraInitialized = false;
                                });
                                onNewCameraSelected(
                                  cameras[_isRearCameraSelected ? 0 : 1],
                                );
                                setState(() {
                                  _isRearCameraSelected =
                                      !_isRearCameraSelected;
                                });
                              },
                              child: Container(
                                height: 50,
                                width: 50,
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Icon(
                                  _isRearCameraSelected
                                      ? Icons.camera_front
                                      : Icons.camera_rear,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: _isVideoCameraSelected
                                  ? () async {
                                      if (_isRecordingInProgress) {
                                        XFile? rawVideo =
                                            await stopVideoRecording();
                                        File videoFile = File(rawVideo!.path);

                                        int currentUnix = DateTime.now()
                                            .millisecondsSinceEpoch;

                                        final directory =
                                            await getApplicationDocumentsDirectory();
                                        String fileFormat =
                                            videoFile.path.split('.').last;

                                        _videoFile = await videoFile.copy(
                                          '${directory.path}/$currentUnix.$fileFormat',
                                        );

                                        videoController = VideoPlayerController.file(_videoFile!);
                                        print('----videoController-----$videoController');

                                        _startVideoPlayer();
                                      } else {
                                        await startVideoRecording();
                                      }
                                    }
                                  : () async {
                                      XFile? rawImage = await takePicture();
                                      File imageFile = File(rawImage!.path);

                                      int currentUnix =
                                          DateTime.now().millisecondsSinceEpoch;
                                      final directory =
                                          await getApplicationDocumentsDirectory();
                                      String fileFormat =
                                          imageFile.path.split('.').last;

                                      _imageFile = await imageFile.copy(
                                        '${directory.path}/$currentUnix.$fileFormat',
                                      );
                                    },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    color: _isVideoCameraSelected
                                        ? Colors.white38
                                        : Colors.white38,
                                    size: 80,
                                  ),
                                  Icon(
                                    Icons.circle,
                                    color: _isVideoCameraSelected
                                        ? Colors.red
                                        : Colors.white,
                                    size: 70,
                                  ),
                                  _isVideoCameraSelected &&
                                          _isRecordingInProgress
                                      ? const Icon(
                                          Icons.stop_rounded,
                                          color: Colors.white,
                                          size: 32,
                                        )
                                      : Container(),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height * 0.05,
                              width: MediaQuery.of(context).size.width * 0.1,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(10.0),
                                border:
                                    Border.all(color: Colors.white, width: 1),
                                image: _imageFile != null
                                    ? DecorationImage(
                                        image: FileImage(_imageFile!),
                                        fit: BoxFit.fill,
                                      )
                                    : null,
                              ),
                              child: videoController != null &&
                                      videoController!.value.isInitialized
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: AspectRatio(
                                        aspectRatio:
                                            videoController!.value.aspectRatio,
                                        child: VideoPlayer(videoController!),
                                      ),
                                    )
                                  : Container(),
                            )
                          ],
                        ),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                )
              ],
            )
          : Container(),
    );
  }
}
