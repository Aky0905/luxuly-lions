class Party {
  final String id;
  final String title;
  final String place;
  final DateTime dateTime;
  final int capacity;
  int joined; // 현재 인원
  final List<Participant> people;

  Party({
    required this.id,
    required this.title,
    required this.place,
    required this.dateTime,
    required this.capacity,
    required this.joined,
    required this.people,
  });
}

class Participant {
  final String name;
  final int level;
  bool ready;

  Participant({required this.name, required this.level, this.ready = false});
}
