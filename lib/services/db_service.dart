import 'package:monobank/models/game.dart';
import 'package:monobank/models/player.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

abstract class DbService {
  Future<void> init();

  Future<void> addPlayer(Player player);
  Future<List<Player>> getPlayers();
  Future<Player?> getPlayerById(String id);
  Future<void> deletePlayer(Player player);

  Future<void> addGame(Game game);
  Future<List<Game>> getGames();
  Future<void> deleteGame(Game game);
}

// class SqlDbService implements DbService {
//   late final Database database;
//
//   @override
//   Future<void> init() async {
//     database = await openDatabase(
//       // Set the path to the database. Note: Using the `join` function from the
//       // `path` package is best practice to ensure the path is correctly
//       // constructed for each platform.
//       join(await getDatabasesPath(), 'monobank.db'),
//       // When the database is first created, create a table to store dogs.
//       onCreate: (db, version) {
//         // Run the CREATE TABLE statement on the database.
//         db.execute('CREATE TABLE Players(id TEXT PRIMARY KEY, name TEXT)');
//         // db.execute('CREATE TABLE Games(id TEXT PRIMARY KEY, players TEXT)');
//       },
//       // Set the version. This executes the onCreate function and provides a
//       // path to perform database upgrades and downgrades.
//       version: 1,
//     );
//   }
//
//   @override
//   Future<void> addPlayer(Player player) async {
//     // TODO change function name to reflect update
//     await database.insert("Players", player.toJson(),
//         conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//   @override
//   Future<List<Player>> getPlayers() async {
//     final dbResult = await database.query("Players");
//     final players = List.generate(
//         dbResult.length, (index) => Player.fromJson(dbResult[index]));
//     return players;
//   }
//
//   @override
//   Future<Player?> getPlayerById(String id) async {
//     final dbResult =
//         await database.query("Players", where: "id = ?", whereArgs: [id]);
//     if (dbResult.isEmpty) {
//       return null;
//     }
//     final player = Player.fromJson(dbResult.first);
//     return player;
//   }
//
//   @override
//   Future<void> deletePlayer(Player player) async {
//     await database.delete("Players", where: "id = ?", whereArgs: [player.id]);
//   }
//
//   @override
//   Future<void> addGame(Game game) async {
//     // await database.insert("Games", game.toJson());
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<List<Game>> getGames() async {
//     throw UnimplementedError();
//   }
//
//   @override
//   Future<void> deleteGame(Game game) async {
//     throw UnimplementedError();
//   }
// }

class DummyDbService implements DbService {
  late final List<Player> players;
  late final List<Game> games;

  @override
  Future<void> init() async {
    players = [];
    games = [];
  }

  @override
  Future<void> addPlayer(Player player) async {
    players.add(player);
  }

  @override
  Future<List<Player>> getPlayers() async {
    return players;
  }

  @override
  Future<Player> getPlayerById(String id) async {
    return players.firstWhere((player) => player.id == id);
  }

  @override
  Future<void> deletePlayer(Player player) async {
    players.remove(player);
  }

  @override
  Future<void> addGame(Game game) async {
    games.add(game);
  }

  @override
  Future<List<Game>> getGames() async {
    return games..sort((a, b) => -a.modifiedAt.compareTo(b.modifiedAt));
  }

  @override
  Future<void> deleteGame(Game game) async {
    games.remove(game);
  }
}
