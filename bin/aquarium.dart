import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'aqurium_body.dart';
import 'fish.dart';

class Aquarium extends AquariumBody {
  Aquarium();

  @override
  void info() {
    final male = fishData.where((element) => element.gender == 'male').length;
    final female =
        fishData.where((element) => element.gender == 'female').length;
    print("_____________________________");
    print("Baliqlar soni: ${fishData.length}, male: $male, female: $female");
    print("-----------------------------");
  }

  @override
  void deadFish(Fish fish) {
    print("_____________________________");
    print("Baliq nobud bo'ldi.\nID: ${fish.id}, gender: ${fish.gender}");
    print("-----------------------------");
    fishData.removeWhere((element) => element.id == fish.id);
    info();
  }

  @override
  void populate(String mId, String fId) async {
    final lifeSpan = Duration(seconds: random.nextInt(50) + 10);
    final id = uuid.v1(options: {
      'Male': mId,
      'Female': fId,
    });

    final gender = Random().nextBool() ? 'male' : 'female';
    final fish = Fish(id, gender, lifeSpan, receivePort.sendPort);
    final isolate = await Isolate.spawn(
      Fish.fishIsolate,
      {
        'id': id,
        'gender': gender,
        'lifespan': lifeSpan.inSeconds,
        'sendPort': receivePort.sendPort
      },
    );
    fishList.add(isolate);
    fishData.add(fish);

    info();
    print(
        "Yangi baliq qo'shildi: $gender (ID: $id, Lifespan: ${lifeSpan.inSeconds} seconds)");
    // schedule(fish);
  }

  void repopulate() {
    final male = fishData.where((element) => element.gender == 'male').toList();
    final female =
        fishData.where((element) => element.gender == 'female').toList();

    if (male.isNotEmpty && female.isNotEmpty) {
      final randomMale = male[random.nextInt(male.length)];
      final randomFemale = female[random.nextInt(female.length)];

      final randomDuration = Duration(seconds: random.nextInt(40) + 10);
      Timer(randomDuration, () {
        populate(randomMale.id, randomFemale.id);
      });

      print("Baliqlar ko'payishi rejalashtirildi.");
      info();
    }
  }

  @override
  void start(int fishCount) async {
    init();
    for (int i = 0; i < fishCount; i++) {
      final gender = Random().nextBool() ? 'male' : 'female';
      final lifeSpan = Duration(seconds: random.nextInt(50) + 10);
      final fish = Fish(uuid.v1(), gender, lifeSpan, receivePort.sendPort);
      final isolate = await Isolate.spawn(
        Fish.fishIsolate,
        {
          'id': fish.id,
          'gender': gender,
          'lifespan': lifeSpan.inSeconds,
          'sendPort': receivePort.sendPort
        },
      );
      fishList.add(isolate);
      fishData.add(fish);
      // schedule(fish);
      info();
    }

    Timer.periodic(Duration(seconds: 10), (timer) {
      if (fishData.isNotEmpty) {
        repopulate();
      } else {
        print("Baliqlar qirilib ketdi!");
        exit(1);
      }
    });
  }
}
