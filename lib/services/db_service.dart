import 'package:monobank/models/game.dart';
import 'package:monobank/models/player.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// class DbService {
//   void init() async {
//     final database = openDatabase(
//       // Set the path to the database. Note: Using the `join` function from the
//       // `path` package is best practice to ensure the path is correctly
//       // constructed for each platform.
//       join(await getDatabasesPath(), 'monobank.db'),
//       // When the database is first created, create a table to store dogs.
//       onCreate: (db, version) {
//         // Run the CREATE TABLE statement on the database.
//         db.execute(
//             'CREATE TABLE Players(id TEXT PRIMARY KEY, name TEXT, color TEXT)');
//         db.execute('CREATE TABLE Games(id TEXT PRIMARY KEY, player_list TEXT)');
//       },
//       // Set the version. This executes the onCreate function and provides a
//       // path to perform database upgrades and downgrades.
//       version: 1,
//     );
//   }
// }

class DummyDbService implements DbService {
  static final players = <Player>[];
  static final games = <Game>[];

  @override
  void addPlayer(Player player) {
    players.add(player);
  }

  @override
  List<Player> getPlayers() {
    return players;
  }

  @override
  Player getPlayerById(String id) {
    return players.firstWhere((player) => player.id == id);
  }

  @override
  void deletePlayer(Player player) {
    players.remove(player);
  }

  @override
  void addGame(Game game) {
    games.add(game);
  }

  @override
  List<Game> getGames() {
    return games;
  }

  @override
  void deleteGame(Game game) {
    games.remove(game);
  }
}

abstract class DbService {
  void addPlayer(Player player);
  List<Player> getPlayers();
  Player getPlayerById(String id);
  void deletePlayer(Player player);

  void addGame(Game game);
  List<Game> getGames();
  void deleteGame(Game game);
}
