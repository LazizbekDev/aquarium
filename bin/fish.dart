import 'dart:isolate';
import 'dart:async';
import 'aquarium.dart';

class Fish {
  final String id;
  final String gender;
  final Duration lifespan;
  SendPort sendPort;

  Fish(this.id, this.gender, this.lifespan, this.sendPort);

  static void fishIsolate(Map<String, dynamic> data) async {
    final id = data['id'] as String;
    final gender = data['gender'] as String;
    final lifespan = Duration(seconds: data['lifespan'] as int);
    final sendPort = data['sendPort'] as SendPort;

    await Future.delayed(lifespan);
    sendPort.send({'event': 'death', 'fish': {'id': id, 'gender': gender}});
  }
}

void main() {
  final aquarium = Aquarium();
  aquarium.start(15);
}
