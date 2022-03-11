import 'dart:io';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gully_news/resources/resources.dart';
import 'package:gully_news/widgets/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:video_player/video_player.dart';

class AddNewsScreen extends StatefulWidget {
  static const route = '/Add-News-Screen';

  const AddNewsScreen({Key? key}) : super(key: key);

  @override
  _AddNewsScreenState createState() => _AddNewsScreenState();
}

class _AddNewsScreenState extends State<AddNewsScreen> {
  final TextEditingController _newsController = TextEditingController();
  final TextEditingController _headLineController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _detailsController = TextEditingController();
  bool newsListen = false;
  bool headlineListen = false;
  bool stateListen = false;
  bool cityListen = false;
  bool detailsListen = false;

  bool _isSelectDateTime = false;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final _newsSpeech = SpeechToText();
  final _headlineSpeech = SpeechToText();
  final _stateSpeech = SpeechToText();
  final _citySpeech = SpeechToText();
  final _detailsSpeech = SpeechToText();

  File? _pickedFile;
  ImagePicker picker = ImagePicker();
  VideoPlayerController? _videoPlayerController;
  bool isPlay = false;
  bool isPause = true;

  Future<bool> toggleRecording({
    required SpeechToText speechToText,
    required Function(String text) onResult,
    required ValueChanged<bool> onListening,
  }) async {
    if (speechToText.isListening) {
      speechToText.stop();
      return true;
    }

    print('---available----${speechToText.isListening}');
    final isAvailable = await speechToText.initialize(
      onStatus: (status) => onListening(speechToText.isListening),
      onError: (e) => print('Error: $e'),
    );

    if (isAvailable) {
      speechToText.listen(onResult: (value) => onResult(value.recognizedWords));
    }
    print('---available----$isAvailable');
    return isAvailable;
  }

  Future<bool?> _toggleRecording(
      TextEditingController controller, SpeechToText speech) async {
    await toggleRecording(
      speechToText: speech,
      onResult: (text) => setState(() => controller.text = text),
      onListening: (isListened) {
        setState(() {
          if (controller == _newsController) {
            newsListen = isListened;
          }
          if (controller == _headLineController) {
            headlineListen = isListened;
          }
          if (controller == _stateController) {
            stateListen = isListened;
          }
          if (controller == _cityController) {
            cityListen = isListened;
          }
          if (controller == _detailsController) {
            detailsListen = isListened;
          }
        });
        print('---- 333-----$headlineListen');
      },
    );
  }

  Widget textField(String hintText, TextEditingController controller,
      SpeechToText speech, bool isListen,
      [int? length]) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SizedBox(
          height: (hintText == 'Add State' || hintText == 'Add City')
              ? deviceHeight(context) * 0.06
              : deviceHeight(context) * 0.09,
          width: deviceWidth(context) * 0.7,
          child: TextFormField(
            controller: controller,
            maxLength: length,
            decoration: InputDecoration(
                filled: true,
                fillColor: colorGrey.withOpacity(0.11),
                hintText: hintText,
                hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
                enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: colorBlue2A4),
                    borderRadius: BorderRadius.circular(7)),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: colorBlue2A4),
                  borderRadius: BorderRadius.circular(7),
                ),
                border: InputBorder.none),
            keyboardType: TextInputType.text,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _toggleRecording(controller, speech);
            });
          },
          child: Container(
            height: deviceHeight(context) * 0.06,
            width: deviceWidth(context) * 0.17,
            decoration: BoxDecoration(
                border: Border.all(width: 1, color: colorBlue2A4),
                borderRadius: BorderRadius.circular(7),
                color: Colors.grey.shade200),
            child: AvatarGlow(
              animate: isListen,
              endRadius: 20,
              glowColor: Theme.of(context).primaryColor,
              child: Image.asset(isListen ? icAudio : icAudioNon,
                  width: deviceWidth(context) * 0.03),
            ),
          ),
        ),
      ],
    );
  }

  void _presentDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime.now())
        .then((pickedDate) {
      if (pickedDate == null) {
        return;
      }
      setState(() {
        _selectedDate = pickedDate;
      });
    }).whenComplete(_presentTimePicker);
  }

  _presentTimePicker() {
    showTimePicker(
            context: context,
            initialTime: TimeOfDay(
                hour: DateTime.now().hour, minute: DateTime.now().minute))
        .then((pickedTime) {
      if (pickedTime == null) {
        return;
      }
      setState(() {
        _selectedTime = pickedTime;
        _isSelectDateTime = true;
      });
    });
  }

  void goToSecondScreen() async {
    _pickedFile = null;
    _videoPlayerController = null;
    Navigator.of(context).pop();
    var result = await Navigator.of(context).pushNamed(CameraScreen.route);
    setState(() {
      _pickedFile = result as File?;
      _pickedFile.toString().contains('.mp4')
          ? _videoPlayerController = VideoPlayerController.file(_pickedFile!)
          : null;
    });
  }

  _getImageFromGallery() async {
    Navigator.of(context).pop();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 100);
    if (pickedFile != null) {
      setState(() {
        _pickedFile = File(pickedFile.path);
      });
    }
  }

  // _getVideoFromGallery() async {
  //   _pickedImage = null;
  //   final pickedFile = await picker.pickVideo(source: ImageSource.gallery);
  //   _pickedVideo = File(pickedFile!.path);
  //   _videoPlayerController = VideoPlayerController.file(_pickedVideo!)
  //     ..initialize().then((_) {
  //       setState(() {});
  //       _videoPlayerController!.play();
  //     });
  // }

  cameraGalley(String icon, String title, Function() onClick) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
            onTap: onClick,
            child: Image.asset(icon,
                color: colorBlue2A4, width: deviceWidth(context) * 0.08)),
        SizedBox(height: deviceHeight(context) * 0.005),
        Text(title, style: textStyle14())
      ],
    );
  }

  bottomSheet() {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: deviceHeight(context) * 0.13,
            color: colorBlue2A4.withOpacity(0.11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                cameraGalley(icCamera, 'Camera', goToSecondScreen),
                cameraGalley(icGallery, 'Gallery', _getImageFromGallery),
              ],
            ),
          );
        });
  }

  @override
  void dispose() {
    _videoPlayerController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('----pickedFile -----$_pickedFile');
    print('===xx---bool-------${_pickedFile.toString().contains('.mp4')}');
    print('----videoPlayerController -----$_videoPlayerController');
    return SafeArea(
        child: Scaffold(
      body: Column(
        children: [
          SizedBox(height: deviceHeight(context) * 0.03),
          Padding(
            padding:
                EdgeInsets.symmetric(horizontal: deviceWidth(context) * 0.05),
            child: Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(icSqrBack,
                        width: deviceWidth(context) * 0.06)),
                const Spacer(),
                Text('News', style: textStyle18Bold(colorBlue2A4)),
                const Spacer(),
                SizedBox(width: deviceWidth(context) * 0.06)
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: deviceHeight(context) * 0.03),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: deviceHeight(context) * 0.2,
                        width: deviceWidth(context) * 0.05,
                        decoration: BoxDecoration(
                            color: colorGrey.withOpacity(0.11),
                            borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(5),
                                bottomRight: Radius.circular(5))),
                      ),
                      if (_pickedFile == null)
                        Container(
                          height: deviceHeight(context) * 0.25,
                          width: deviceWidth(context) * 0.8,
                          decoration: BoxDecoration(
                              color: colorGrey.withOpacity(0.11),
                              borderRadius: BorderRadius.circular(5)),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: bottomSheet,
                                child: Image.asset(icADD,
                                    color: colorBlue2A4,
                                    width: deviceWidth(context) * 0.1),
                              ),
                              SizedBox(
                                height: deviceHeight(context) * 0.02,
                              ),
                              Text('Add Photos or Videos',
                                  style:
                                      textStyle12(colorBlack.withOpacity(0.4)))
                            ],
                          ),
                        ),
                      if (_pickedFile != null)
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Stack(
                              children: [
                                Container(
                                  height: deviceHeight(context) * 0.25,
                                  width: deviceWidth(context) * 0.8,
                                  decoration: BoxDecoration(
                                      color: colorGrey.withOpacity(0.11),
                                      borderRadius: BorderRadius.circular(5)),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: _pickedFile
                                            .toString()
                                            .contains('.mp4')
                                        ? (_videoPlayerController != null &&
                                                _videoPlayerController!
                                                    .value.isInitialized
                                            ? AspectRatio(
                                                aspectRatio:
                                                    _videoPlayerController!
                                                        .value.aspectRatio,
                                                child: VideoPlayer(
                                                    _videoPlayerController!))
                                            : Container())
                                        : Image.file(_pickedFile!,
                                            fit: BoxFit.fitHeight),
                                  ),
                                ),
                                if (_pickedFile.toString().contains('.mp4'))
                                  Positioned(
                                    top: deviceHeight(context) * 0.09,
                                    left: deviceWidth(context) * 0.34,
                                    child: IconButton(
                                        onPressed: () async {
                                          setState(() async {
                                            if (_videoPlayerController!
                                                .value.isPlaying) {
                                              isPause = true;
                                              isPlay = false;
                                              _videoPlayerController!.pause();
                                            } else {
                                              isPlay = true;
                                              isPause = false;
                                              await _videoPlayerController!
                                                  .initialize()
                                                  .then((_) {
                                                setState(() {});
                                              });
                                              await _videoPlayerController!
                                                  .setLooping(false);
                                              await _videoPlayerController!
                                                  .play();
                                              //     .timeout(Duration(
                                              //         hours:
                                              //             _videoPlayerController!
                                              //                 .value
                                              //                 .duration
                                              //                 .inHours,
                                              //         minutes:
                                              //             _videoPlayerController!
                                              //                 .value
                                              //                 .duration
                                              //                 .inMinutes,
                                              //         seconds:
                                              //             _videoPlayerController!
                                              //                 .value
                                              //                 .duration
                                              //                 .inSeconds,
                                              //         milliseconds:
                                              //             _videoPlayerController!
                                              //                 .value
                                              //                 .duration
                                              //                 .inMilliseconds))
                                              //     .whenComplete(() {
                                              //   setState(() {
                                              //     isPause = true;
                                              //   });
                                              // });
                                            }
                                          });
                                        },
                                        icon: Icon(
                                          isPause
                                              ? Icons.play_arrow
                                              : Icons.pause,
                                        )),
                                  )
                              ],
                            ),
                            Positioned(
                              top: -deviceHeight(context) * 0.04,
                              right: -deviceWidth(context) * 0.031,
                              child: GestureDetector(
                                onTap: bottomSheet,
                                child: Container(
                                  height: deviceHeight(context) * 0.09,
                                  width: deviceWidth(context) * 0.09,
                                  decoration: BoxDecoration(
                                      color: colorWhite,
                                      border: Border.all(
                                          color: colorBlue2A4,
                                          width: deviceWidth(context) * 0.003),
                                      shape: BoxShape.circle),
                                  child: Center(
                                      child: Image.asset(icEdit,
                                          color: colorBlue2A4,
                                          width: deviceWidth(context) * 0.04)),
                                ),
                              ),
                            )
                          ],
                        ),
                      Container(
                        height: deviceHeight(context) * 0.2,
                        width: deviceWidth(context) * 0.05,
                        decoration: BoxDecoration(
                            color: colorGrey.withOpacity(0.11),
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(5),
                                bottomLeft: Radius.circular(5))),
                      )
                    ],
                  ),
                  SizedBox(height: deviceHeight(context) * 0.03),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: deviceWidth(context) * 0.05),
                    child: Column(
                      children: [
                        textField('News', _newsController, _newsSpeech,
                            newsListen, 100),
                        SizedBox(
                          height: deviceHeight(context) * 0.025,
                        ),
                        textField('Add Headline', _headLineController,
                            _headlineSpeech, headlineListen, 300),
                        SizedBox(
                          height: deviceHeight(context) * 0.025,
                        ),
                        textField('Add State', _stateController, _stateSpeech,
                            stateListen),
                        SizedBox(
                          height: deviceHeight(context) * 0.04,
                        ),
                        textField('Add City', _cityController, _citySpeech,
                            cityListen),
                        SizedBox(
                          height: deviceHeight(context) * 0.04,
                        ),
                        Container(
                            height: deviceHeight(context) * 0.06,
                            width: deviceWidth(context),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: colorBlue2A4,
                                    width: deviceWidth(context) * 0.0025),
                                borderRadius: BorderRadius.circular(7),
                                color: colorGrey.withOpacity(0.11)),
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: deviceWidth(context) * 0.026),
                              child: GestureDetector(
                                onTap: _presentDatePicker,
                                child: Text(
                                  _isSelectDateTime
                                      ? DateFormat()
                                              .add_yMd()
                                              .format(_selectedDate!) +
                                          ', ${_selectedTime!.hour > 12 ? _selectedTime!.hour - 12 : _selectedTime!.hour}:${_selectedTime!.minute} ${_selectedTime!.period.name}'
                                      : 'Add Date & Time',
                                  style: _isSelectDateTime
                                      ? textStyle14Medium(colorBlack)
                                      : textStyle14Bold(
                                          colorBlack.withOpacity(0.4),
                                        ),
                                ),
                              ),
                            )),
                        SizedBox(
                          height: deviceHeight(context) * 0.04,
                        ),
                        textField('More Details', _detailsController,
                            _detailsSpeech, detailsListen),
                        SizedBox(height: deviceHeight(context) * 0.06),
                        Container(
                          width: deviceWidth(context),
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                              color: colorBlue2A4.withOpacity(0.3),
                              offset: const Offset(0.0, 7.0),
                              blurRadius: 6.0,
                            ),
                          ]),
                          child: TextButton(
                            onPressed: () {},
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: deviceHeight(context) * 0.003),
                              child: Text(
                                'Submit',
                                style: textStyle18Bold(),
                              ),
                            ),
                            style: TextButton.styleFrom(
                                primary: colorWhite,
                                backgroundColor: colorBlue2A4,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5))),
                          ),
                        ),
                        SizedBox(height: deviceHeight(context) * 0.06),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    ));
  }
}

// newsRecord() =>
//     SpeechApi.newsRecording(
//       onResult: (text) => setState(() => _newsController.text = text),
//       onListening: (isListened) {
//         print('----isListened-----$isListened');
//         setState(() {
//           newsListen = isListened;
//         });
//         print('----isListen-----$isListened');
//       },
//     );

// headlineRecord() =>
//     SpeechApi.headlineRecording(
//       onResult: (text) => setState(() => _headLineController.text = text),
//       onListening: (isListened) {
//         print('----isListened-----$isListened');
//         setState(() {
//           headlineListen = isListened;
//         });
//         print('----isListen-----$isListened');
//       },
//     );

// stateRecord() =>
//     SpeechApi.stateRecording(
//       onResult: (text) => setState(() => _stateController.text = text),
//       onListening: (isListened) {
//         print('----isListened-----$isListened');
//         setState(() {
//           stateListen = isListened;
//         });
//         print('----isListen-----$isListened');
//       },
//     );

// cityRecord() =>
//     SpeechApi.cityRecording(
//       onResult: (text) => setState(() => _cityController.text = text),
//       onListening: (isListened) {
//         print('----isListened-----$isListened');
//         setState(() {
//           cityListen = isListened;
//         });
//         print('----isListen-----$isListened');
//       },
//     );

// detailsRecord() =>
//     SpeechApi.detailsRecording(
//       onResult: (text) => setState(() => _detailsController.text = text),
//       onListening: (isListened) {
//         print('----isListened-----$isListened');
//         setState(() {
//           detailsListen = isListened;
//         });
//         print('----isListen-----$isListened');
//       },
//     );

// -------------NEWS------------
//   Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     SizedBox(
//       height: deviceHeight(context) * 0.09,
//       width: deviceWidth(context) * 0.7,
//       child: TextFormField(
//         controller: _newsController,
//         maxLength: 100,
//         decoration: InputDecoration(
//             filled: true,
//             fillColor: colorGrey.withOpacity(0.11),
//             hintText: 'News',
//             hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
//             enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: colorBlue2A4),
//                 borderRadius: BorderRadius.circular(7)),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: colorBlue2A4),
//               borderRadius: BorderRadius.circular(7),
//             ),
//             border: InputBorder.none),
//         keyboardType: TextInputType.text,
//       ),
//     ),
//     GestureDetector(
//       onTap: ()=>toggleRecording(_newsController,newsListen),
//       child: Container(
//         height: deviceHeight(context) * 0.06,
//         width: deviceWidth(context) * 0.17,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: colorBlue2A4),
//             borderRadius: BorderRadius.circular(7),
//             color: Colors.grey.shade200),
//         child: AvatarGlow(
//           animate: newsListen,
//           endRadius: 20,
//           glowColor: Theme.of(context).primaryColor,
//           child: Image.asset(newsListen ? icAudio : icAudioNon,
//               width: deviceWidth(context) * 0.03),
//         ),
//       ),
//     ),
//   ],
// ),

// -------------HEADLINE------------
// Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     SizedBox(
//       height: deviceHeight(context) * 0.09,
//       width: deviceWidth(context) * 0.7,
//       child: TextFormField(
//         controller: _headLineController,
//         maxLength: 100,
//         decoration: InputDecoration(
//             filled: true,
//             fillColor: colorGrey.withOpacity(0.11),
//             hintText: 'Add Headline',
//             hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
//             enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: colorBlue2A4),
//                 borderRadius: BorderRadius.circular(7)),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: colorBlue2A4),
//               borderRadius: BorderRadius.circular(7),
//             ),
//             border: InputBorder.none),
//         keyboardType: TextInputType.text,
//       ),
//     ),
//     GestureDetector(
//       onTap: ()=>toggleRecording(_headLineController,headlineListen),
//       child: Container(
//         height: deviceHeight(context) * 0.06,
//         width: deviceWidth(context) * 0.17,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: colorBlue2A4),
//             borderRadius: BorderRadius.circular(7),
//             color: Colors.grey.shade200),
//         child: AvatarGlow(
//           animate: headlineListen,
//           endRadius: 20,
//           glowColor: Theme.of(context).primaryColor,
//           child: Image.asset(headlineListen ? icAudio : icAudioNon,
//               width: deviceWidth(context) * 0.03),
//         ),
//       ),
//     ),
//   ],
// ),

// -------------STATE------------
// Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     SizedBox(
//       height: deviceHeight(context) * 0.06,
//       width: deviceWidth(context) * 0.7,
//       child: TextFormField(
//         controller: _stateController,
//         decoration: InputDecoration(
//             filled: true,
//             fillColor: colorGrey.withOpacity(0.11),
//             hintText: 'Add State',
//             hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
//             enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: colorBlue2A4),
//                 borderRadius: BorderRadius.circular(7)),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: colorBlue2A4),
//               borderRadius: BorderRadius.circular(7),
//             ),
//             border: InputBorder.none),
//         keyboardType: TextInputType.text,
//       ),
//     ),
//     GestureDetector(
//       onTap: ()=>toggleRecording(_stateController,stateListen),
//       child: Container(
//         height: deviceHeight(context) * 0.06,
//         width: deviceWidth(context) * 0.17,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: colorBlue2A4),
//             borderRadius: BorderRadius.circular(7),
//             color: Colors.grey.shade200),
//         child: AvatarGlow(
//           animate: stateListen,
//           endRadius: 20,
//           glowColor: Theme.of(context).primaryColor,
//           child: Image.asset(stateListen ? icAudio : icAudioNon,
//               width: deviceWidth(context) * 0.03),
//         ),
//       ),
//     ),
//   ],
// ),

// -------------CITY------------
// Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     SizedBox(
//       height: deviceHeight(context) * 0.06,
//       width: deviceWidth(context) * 0.7,
//       child: TextFormField(
//         controller: _cityController,
//         decoration: InputDecoration(
//             filled: true,
//             fillColor: colorGrey.withOpacity(0.11),
//             hintText: 'Add City',
//             hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
//             enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: colorBlue2A4),
//                 borderRadius: BorderRadius.circular(7)),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: colorBlue2A4),
//               borderRadius: BorderRadius.circular(7),
//             ),
//             border: InputBorder.none),
//         keyboardType: TextInputType.text,
//       ),
//     ),
//     GestureDetector(
//       onTap: ()=>toggleRecording(_cityController,cityListen),
//       child: Container(
//         height: deviceHeight(context) * 0.06,
//         width: deviceWidth(context) * 0.17,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: colorBlue2A4),
//             borderRadius: BorderRadius.circular(7),
//             color: Colors.grey.shade200),
//         child: AvatarGlow(
//           animate: cityListen,
//           endRadius: 20,
//           glowColor: Theme.of(context).primaryColor,
//           child: Image.asset(cityListen ? icAudio : icAudioNon,
//               width: deviceWidth(context) * 0.03),
//         ),
//       ),
//     ),
//   ],
// ),

// -------------DETAILS------------
// Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//   children: [
//     SizedBox(
//       height: deviceHeight(context) * 0.09,
//       width: deviceWidth(context) * 0.7,
//       child: TextFormField(
//         controller: _detailsController,
//         maxLength: 100,
//         decoration: InputDecoration(
//             filled: true,
//             fillColor: colorGrey.withOpacity(0.11),
//             hintText: 'More Details',
//             hintStyle: textStyle14Bold(colorBlack.withOpacity(0.4)),
//             enabledBorder: OutlineInputBorder(
//                 borderSide: const BorderSide(color: colorBlue2A4),
//                 borderRadius: BorderRadius.circular(7)),
//             focusedBorder: OutlineInputBorder(
//               borderSide: const BorderSide(color: colorBlue2A4),
//               borderRadius: BorderRadius.circular(7),
//             ),
//             border: InputBorder.none),
//         keyboardType: TextInputType.text,
//       ),
//     ),
//     GestureDetector(
//       onTap: ()=>toggleRecording(_detailsController,detailsListen),
//       child: Container(
//         height: deviceHeight(context) * 0.06,
//         width: deviceWidth(context) * 0.17,
//         decoration: BoxDecoration(
//             border: Border.all(width: 1, color: colorBlue2A4),
//             borderRadius: BorderRadius.circular(7),
//             color: Colors.grey.shade200),
//         child: AvatarGlow(
//           animate: detailsListen,
//           endRadius: 20,
//           glowColor: Theme.of(context).primaryColor,
//           child: Image.asset(detailsListen ? icAudio : icAudioNon,
//               width: deviceWidth(context) * 0.03),
//         ),
//       ),
//     ),
//   ],
// ),
