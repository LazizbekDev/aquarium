import 'dart:isolate';
import 'dart:math';
import 'package:uuid/uuid.dart';
import 'fish.dart';

abstract class AquariumBody {
  final List<Isolate> fishList = [];
  final List<Fish> fishData = [];
  final Random random = Random();
  final ReceivePort receivePort = ReceivePort();
  final Uuid uuid = Uuid();

  AquariumBody();

  void init() {
    receivePort.listen((message) {
      if (message['event'] == 'death') {
        final fishData = message['fish'];
        final fish = Fish(fishData['id'], fishData['gender'], Duration.zero, receivePort.sendPort);
        deadFish(fish);
      }
    });
  }

  void deadFish(Fish fish);

  void populate(String m, String f);

  void info();

  void start(int fishCount);
}
