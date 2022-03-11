// import 'package:flutter/material.dart';
// import 'package:speech_to_text/speech_to_text.dart';
//
// class SpeechApi {
//   static final _speech = SpeechToText();
//
//   static Future<bool> toggleRecording({
//     required Function(String text) onResult,
//     required ValueChanged<bool> onListening,
//   }) async {
//     if (_speech.isListening) {
//       return true;
//     }
//
//     print('---available----${_speech.isListening}');
//     final isAvailable = await _speech.initialize(
//       onStatus: (status) => onListening(_speech.isListening),
//       onError: (e) => print('Error: $e'),
//     );
//
//     if (isAvailable) {
//       _speech.listen(onResult: (value) => onResult(value.recognizedWords));
//     }
//     print('---available----$isAvailable');
//     return _speech.isListening;
//   }
// }


// static final _newsSpeech = SpeechToText();
// static final _headlineSpeech = SpeechToText();
// static final _stateSpeech = SpeechToText();
// static final _citySpeech = SpeechToText();
// static final _detailsSpeech = SpeechToText();
//
//
// static Future<bool> newsRecording({
// required Function(String text) onResult,
// required ValueChanged<bool> onListening,
// }) async {
// if (_newsSpeech.isListening) {
// _newsSpeech.stop();
// return true;
// }
//
// print('---available----${_newsSpeech.isListening}');
// final isAvailable = await _newsSpeech.initialize(
// onStatus: (status) => onListening(_newsSpeech.isListening),
// onError: (e) => print('Error: $e'),
// );
//
// if (isAvailable) {
// _newsSpeech.listen(onResult: (value) => onResult(value.recognizedWords));
// }
// print('---available----$isAvailable');
// return isAvailable;
// }
//
// static Future<bool> headlineRecording({
// required Function(String text) onResult,
// required ValueChanged<bool> onListening,
// }) async {
// if (_headlineSpeech.isListening) {
// _headlineSpeech.stop();
// return true;
// }
//
// print('---available----${_headlineSpeech.isListening}');
// final isAvailable = await _headlineSpeech.initialize(
// onStatus: (status) => onListening(_headlineSpeech.isListening),
// onError: (e) => print('Error: $e'),
// );
//
// if (isAvailable) {
// _headlineSpeech.listen(onResult: (value) => onResult(value.recognizedWords));
// }
// print('---available----$isAvailable');
// return isAvailable;
// }
//
// static Future<bool> stateRecording({
// required Function(String text) onResult,
// required ValueChanged<bool> onListening,
// }) async {
// if (_stateSpeech.isListening) {
// _stateSpeech.stop();
// return true;
// }
//
// print('---available----${_stateSpeech.isListening}');
// final isAvailable = await _stateSpeech.initialize(
// onStatus: (status) => onListening(_stateSpeech.isListening),
// onError: (e) => print('Error: $e'),
// );
//
// if (isAvailable) {
// _stateSpeech.listen(onResult: (value) => onResult(value.recognizedWords));
// }
// print('---available----$isAvailable');
// return isAvailable;
// }
//
// static Future<bool> cityRecording({
// required Function(String text) onResult,
// required ValueChanged<bool> onListening,
// }) async {
// if (_citySpeech.isListening) {
// _citySpeech.stop();
// return true;
// }
//
// print('---available----${_citySpeech.isListening}');
// final isAvailable = await _citySpeech.initialize(
// onStatus: (status) => onListening(_citySpeech.isListening),
// onError: (e) => print('Error: $e'),
// );
//
// if (isAvailable) {
// _citySpeech.listen(onResult: (value) => onResult(value.recognizedWords));
// }
// print('---available----$isAvailable');
// return isAvailable;
// }
//
// static Future<bool> detailsRecording({
// required Function(String text) onResult,
// required ValueChanged<bool> onListening,
// }) async {
// if (_detailsSpeech.isListening) {
// _detailsSpeech.stop();
// return true;
// }
//
// print('---available----${_detailsSpeech.isListening}');
// final isAvailable = await _detailsSpeech.initialize(
// onStatus: (status) => onListening(_detailsSpeech.isListening),
// onError: (e) => print('Error: $e'),
// );
//
// if (isAvailable) {
// _detailsSpeech.listen(onResult: (value) => onResult(value.recognizedWords));
// }
// print('---available----$isAvailable');
// return isAvailable;
// }