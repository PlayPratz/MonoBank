class Player {
  final String id;
  final String name;

  const Player({required this.id, required this.name});

  factory Player.fromJson(Map<String, dynamic> json) => Player(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

const bank = Player(id: "_bank", name: "Bank");
