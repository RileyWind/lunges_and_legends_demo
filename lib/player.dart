import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:lunges_and_legends/player_common.dart';
import 'package:rxdart/rxdart.dart';
import 'homepage.dart';

class AudioPlayerFull extends StatelessWidget {
  final AudioPlayer player;

  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey;

  const AudioPlayerFull(this.player, this.scaffoldMessengerKey, {Key? key})
      : super(key: key);

  Stream<PositionData> get positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: backgroundColor,
        canvasColor: backgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            leadingWidth: 72.0,
            toolbarHeight: 72.0,
            backgroundColor: Colors.transparent,
            flexibleSpace: Stack(
              alignment: Alignment.center,
              children: [
                MediaQuery.of(context).size.width > 400
                    ? Image.asset(
                        "asset_files/vintageribbon_sample_03.png",
                        filterQuality: FilterQuality.high,
                        opacity: const AlwaysStoppedAnimation(.8),
                      )
                    : SizedBox(),
                Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    "Player",
                    style: TextStyle(
                      textBaseline: TextBaseline.alphabetic,
                      fontFamily: "FellEnglish",
                      //fontFamily: "Cinzel",
                      fontSize: 26.0,
                    ),
                  ),
                )
              ],
            ),
            leading: IconButton(
              iconSize: 48.0,
              icon: Icon(
                Icons.keyboard_arrow_down,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: StreamBuilder<SequenceState?>(
                    stream: player.sequenceStateStream,
                    builder: (context, snapshot) {
                      final state = snapshot.data;
                      if (state?.sequence.isEmpty ?? true) {
                        return const SizedBox();
                      }
                      final metadata = state!.currentSource!.tag as MediaItem;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Center(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black87, width: 2),
                                    shape: BoxShape.rectangle,
                                  ),
                                  child:
                                      Image.asset(metadata.artUri.toString()),
                                ),
                              ),
                              //Center(child: Image.network(metadata.artwork)),
                            ),
                          ),
                          Text(metadata.album as String,
                              style: Theme.of(context).textTheme.titleLarge),
                          Text(metadata.title),
                        ],
                      );
                    },
                  ),
                ),
                ControlButtons(player),
                StreamBuilder<PositionData>(
                  stream: positionDataStream,
                  builder: (context, snapshot) {
                    final positionData = snapshot.data;
                    return SeekBar(
                      duration: positionData?.duration ?? Duration.zero,
                      position: positionData?.position ?? Duration.zero,
                      bufferedPosition:
                          positionData?.bufferedPosition ?? Duration.zero,
                      onChangeEnd: (newPosition) {
                        player.seek(newPosition);
                      },
                    );
                  },
                ),
                const SizedBox(height: 8.0),
                const SizedBox(height: 50.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double playSize = 64.0;
    if (MediaQuery.of(context).size.width < 550) {
      playSize = 24.0;
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "Adjust volume",
                divisions: 10,
                min: 0.0,
                max: 1.0,
                value: player.volume,
                stream: player.volumeStream,
                onChanged: player.setVolume,
              );
            },
          ),
        ),
        Flexible(
          child: StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: const Icon(Icons.skip_previous),
              onPressed: () => player.seek(Duration.zero),
            ),
          ),
        ),
        Flexible(
          child: StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: const Icon(Icons.replay_10),
              onPressed: () =>
                  player.seek(player.position - const Duration(seconds: 10)),
            ),
          ),
        ),
        Flexible(
          child: StreamBuilder<PlayerState>(
            stream: player.playerStateStream,
            builder: (context, snapshot) {
              final playerState = snapshot.data;
              final processingState = playerState?.processingState;
              final playing = playerState?.playing;
              if (processingState == ProcessingState.loading ||
                  processingState == ProcessingState.buffering) {
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  width: playSize,
                  height: playSize,
                  child: const CircularProgressIndicator(),
                );
              } else if (playing != true) {
                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: playSize,
                  onPressed: player.play,
                );
              } else if (processingState != ProcessingState.completed) {
                return IconButton(
                  icon: const Icon(Icons.pause),
                  iconSize: playSize,
                  onPressed: player.pause,
                );
              } else {
                return IconButton(
                  icon: const Icon(Icons.play_arrow),
                  iconSize: playSize,
                  onPressed: () async {
                    await player.seek(Duration.zero);
                    player.play();
                  },
                );
              }
            },
          ),
        ),
        Flexible(
          child: StreamBuilder<SequenceState?>(
            stream: player.sequenceStateStream,
            builder: (context, snapshot) => IconButton(
              icon: const Icon(Icons.forward_10),
              onPressed: () =>
                  player.seek(player.position + const Duration(seconds: 10)),
            ),
          ),
        ),
        Flexible(
          child: StreamBuilder<LoopMode>(
            stream: player.loopModeStream,
            builder: (context, snapshot) {
              if (player.loopMode == LoopMode.one) {
                return IconButton(
                    icon: const Icon(Icons.repeat_on),
                    onPressed: () => player.setLoopMode(LoopMode.off));
              } else {
                return IconButton(
                    icon: const Icon(Icons.repeat),
                    //color: Colors.indigo.shade50,
                    onPressed: () => player.setLoopMode(LoopMode.one));
              }
            },
          ),
        ),
        Flexible(
          child: const SizedBox(width: 40.0),
        ),
      ],
    );
  }
}

class AudioMetadata {
  final String album;
  final String title;
  final String artwork;

  AudioMetadata({
    required this.album,
    required this.title,
    required this.artwork,
  });
}
