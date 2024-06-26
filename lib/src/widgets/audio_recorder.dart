import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'state/inherited_chat_theme.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter_sound/public/flutter_sound_recorder.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart' show Level, Logger;

class AudioRecording {
  const AudioRecording({
    required this.filePath,
    required this.duration,
    required this.decibelLevels,
    required this.mimeType,
  });

  final String filePath;
  final Duration duration;
  final List<double> decibelLevels;
  final String mimeType;
}

class AudioRecorder extends StatefulWidget {
  const AudioRecorder({
    Key? key,
    required this.onCancelRecording,
    this.disabled = false,
  }) : super(key: key);

  final bool disabled;
  final void Function() onCancelRecording;

  @override
  AudioRecorderState createState() => AudioRecorderState();
}

class AudioRecorderState extends State<AudioRecorder> {
  final _audioRecorder = FlutterSoundRecorder(logLevel: Level.nothing);
  final _audioRecorderDurationFormat = DateFormat('mm:ss:SS', 'en_US');

  bool _audioRecorderReady = false;
  Duration _recordingDuration = const Duration();
  final List<double> _levels = [];
  late String _recordingMimeType;
  late Codec _recordingCodec;

  @override
  void initState() {
    super.initState();
    _initAudioRecorder();
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    await _audioRecorder.closeRecorder();
  }

  Future<AudioRecording?> stopRecording() async {
    final fileName = await _audioRecorder.stopRecorder();
    if (fileName != null) {
      return AudioRecording(
        filePath: fileName,
        duration: _recordingDuration,
        decibelLevels: _levels,
        mimeType: _recordingMimeType,
      );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) => _audioRecorderReady
      ? StreamBuilder<RecordingDisposition>(
          stream: _audioRecorder.onProgress,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              const min = 9.0;
              final disposition = snapshot.data!;
              _recordingDuration = disposition.duration;
              _levels.add(disposition.decibels ?? 0.0);
              return Row(
                children: [
                  AnimatedContainer(
                    margin: const EdgeInsets.only(right: 16),
                    duration: const Duration(milliseconds: 50),
                    width: min + disposition.decibels! * 0.3,
                    height: min + disposition.decibels! * 0.3,
                    constraints: const BoxConstraints(
                      maxHeight: 25.0,
                      maxWidth: 25.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: InheritedChatTheme.of(context)
                          .theme
                          .recordColor
                          .withOpacity(
                            widget.disabled ? 0.5 : 1.0,
                          ),
                    ),
                  ),
                  // Stack(
                  //   alignment: Alignment.center,
                  //   children: [
                  //     if (_audioRecorder.isRecording)
                  //       AnimatedContainer(
                  //         margin: const EdgeInsets.only(right: 16),
                  //         duration: const Duration(milliseconds: 50),
                  //         width: min + disposition.decibels! * 0.3,
                  //         height: min + disposition.decibels! * 0.3,
                  //         constraints: const BoxConstraints(
                  //           maxHeight: 40.0,
                  //           maxWidth: 40.0,
                  //         ),
                  //         decoration: BoxDecoration(
                  //           shape: BoxShape.circle,
                  //           color: InheritedChatTheme.of(context)
                  //               .theme
                  //               .recordColor
                  //               .withOpacity(
                  //                 widget.disabled ? 0.5 : 1.0,
                  //               ),
                  //         ),
                  //       ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: Container(
                  //     width: 24,
                  //     height: 24,
                  //     margin: const EdgeInsets.only(right: 16),
                  //     child: IconButton(
                  //       icon: _audioRecorder.isRecording
                  //           ? (InheritedChatTheme.of(context)
                  //                       .theme
                  //                       .pauseButtonIcon !=
                  //                   null
                  //               ? Image.asset(
                  //                   InheritedChatTheme.of(context)
                  //                       .theme
                  //                       .pauseButtonIcon!,
                  //                   color: Color(0xFF1FD189).withOpacity(
                  //                     widget.disabled ? 0.5 : 1.0,
                  //                   ),
                  //                 )
                  //               : Icon(
                  //                   Icons.pause,
                  //                   color: Color(0xFF1FD189).withOpacity(
                  //                     widget.disabled ? 0.5 : 1.0,
                  //                   ),
                  //                 ))
                  //           : (InheritedChatTheme.of(context)
                  //                       .theme
                  //                       .recordButtonIcon !=
                  //                   null
                  //               ? Image.asset(
                  //                   InheritedChatTheme.of(context)
                  //                       .theme
                  //                       .recordButtonIcon!,
                  //                   color: InheritedChatTheme.of(context)
                  //                       .theme
                  //                       .recordColor
                  //                       .withOpacity(
                  //                         widget.disabled ? 0.5 : 1.0,
                  //                       ),
                  //                 )
                  //               : Icon(
                  //                   Icons.fiber_manual_record,
                  //                   color: InheritedChatTheme.of(context)
                  //                       .theme
                  //                       .recordColor
                  //                       .withOpacity(
                  //                         widget.disabled ? 0.5 : 1.0,
                  //                       ),
                  //                 )),
                  //       onPressed:
                  //           widget.disabled ? null : _toggleRecording,
                  //       padding: EdgeInsets.zero,
                  //     ),
                  //   ),
                  // ),
                  //   ],
                  // ),
                  IconButton(
                    icon: InheritedChatTheme.of(context)
                                .theme
                                .cancelRecordingButtonIcon !=
                            null
                        ? Image.asset(
                            InheritedChatTheme.of(context)
                                .theme
                                .cancelRecordingButtonIcon!,
                            color: Color(0xFF1FD189).withOpacity(
                              widget.disabled ? 0.5 : 1.0,
                            ),
                          )
                        : Icon(
                            Icons.delete,
                            color: Color(0xFF1FD189).withOpacity(
                              widget.disabled ? 0.5 : 1.0,
                            ),
                          ),
                    onPressed: widget.disabled ? null : _cancelRecording,
                    padding: EdgeInsets.zero,
                  ),
                  Expanded(
                    child: Text(
                      _audioRecorderDurationFormat.format(
                        DateTime.fromMillisecondsSinceEpoch(
                          snapshot.data!.duration.inMilliseconds,
                        ).toUtc(),
                      ),
                      textAlign: TextAlign.center,
                      style: InheritedChatTheme.of(context)
                          .theme
                          .inputTextStyle
                          .copyWith(
                            color: const Color(0xFF1FD189),
                          ),
                    ),
                  ),
                ],
              );
            } else {
              return Container();
            }
          },
        )
      : Container();

  Future<void> _initAudioRecorder() async {
    if (Platform.isIOS) {
      final session = await AudioSession.instance;
      await session.configure(AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth |
                AVAudioSessionCategoryOptions.defaultToSpeaker,
        avAudioSessionMode: AVAudioSessionMode.spokenAudio,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: const AndroidAudioAttributes(
          contentType: AndroidAudioContentType.speech,
          flags: AndroidAudioFlags.none,
          usage: AndroidAudioUsage.voiceCommunication,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
    }

    await _audioRecorder.openRecorder();
    setState(() {
      _audioRecorderReady = true;
    });

    await _audioRecorder.setSubscriptionDuration(
      const Duration(milliseconds: 50),
    );

    _startRecording();
  }

  /// Creates an path to a temporary file.
  Future<String> _createTempAacFilePath() async {
    if (kIsWeb) {
      throw Exception(
        'This method only works for mobile as it creates a temporary AAC file',
      );
    }
    const uuid = Uuid();
    String path;
    final tmpDir = await getTemporaryDirectory();
    path = '${join(tmpDir.path, uuid.v4())}.aac';
    final parent = dirname(path);
    await Directory(parent).create(recursive: true);

    return path;
  }

  void _startRecording() async {
    String filePath;
    final fileNameWithoutExtension = const Uuid().v4();
    if (kIsWeb) {
      if (await _audioRecorder.isEncoderSupported(Codec.opusWebM)) {
        filePath = '$fileNameWithoutExtension.webm';
        _recordingCodec = Codec.opusWebM;
        _recordingMimeType = 'audio/webm;codecs="opus"';
      } else {
        filePath = '$fileNameWithoutExtension.mp4';
        _recordingCodec = Codec.aacMP4;
        _recordingMimeType = 'audio/aac';
      }
    } else {
      filePath = await _createTempAacFilePath();
      _recordingCodec = Codec.aacADTS;
      _recordingMimeType = 'audio/aac';
    }

    await _audioRecorder.startRecorder(
      toFile: filePath,
      bitRate: 32000,
      sampleRate: 32000,
      codec: _recordingCodec,
    );
  }

  void _toggleRecording() async {
    if (_audioRecorder.isRecording) {
      await _audioRecorder.pauseRecorder();
      setState(() {});
    } else if (_audioRecorder.isPaused) {
      await _audioRecorder.resumeRecorder();
      setState(() {});
    }
  }

  Future<void> _cancelRecording() async {
    await _audioRecorder.stopRecorder();
    widget.onCancelRecording();
  }
}
