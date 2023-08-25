import 'dart:convert';

import 'package:monobank/models/game.dart';
import 'package:monobank/models/player.dart';
import 'package:monobank/models/transaction.dart' as MBTransaction;
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

  Future<void> addOrUpdatePlayerState({
    required PlayerState playerState,
    required Player player,
    required Game game,
  });
  Future<Map<Player, PlayerState>> getPlayerStates({required Game game});

  Future<void> addTransactionToGame({
    required MBTransaction.Transaction transaction,
    required Game game,
  });
  Future<List<MBTransaction.Transaction>> getTransactionsOfGame(
      {required Game game});
}

class SqlDbService implements DbService {
  late final Database database;

  @override
  Future<void> init() async {
    database = await openDatabase(
      // Set the path to the database. Note: Using the `join` function from the
      // `path` package is best practice to ensure the path is correctly
      // constructed for each platform.
      join(await getDatabasesPath(), 'monobank.db'),
      // onConfigure: (db) async {
      //   // Add support for cascade delete
      //   await db.execute("PRAGMA foreign_keys = ON");
      // },
      // When the database is first created, create a table to store dogs.
      onCreate: (db, version) async {
        await db.execute('CREATE TABLE Players('
            'id TEXT PRIMARY KEY,'
            'name TEXT'
            ')');

        await db.insert(
          "Players",
          bank.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await db.execute('CREATE TABLE Games('
            'id TEXT PRIMARY KEY,'
            'initialBalance INTEGER,'
            'moneyOnGo INTEGER,'
            'createdAt INTEGER,'
            'modifiedAt INTEGER,'
            'playerIds TEXT'
            ')');

        await db.execute('CREATE TABLE PlayerStates('
            'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            'gameId TEXT,'
            'playerId TEXT,'
            'balance INTEGER,'
            'isBankrupt INTEGER,'
            'colorValue INTEGER,'
            'FOREIGN KEY (gameId) REFERENCES Games(id),'
            'FOREIGN KEY (playerId) REFERENCES Players(id)'
            ')');

        await db.execute('CREATE TABLE Transactions('
            'id INTEGER PRIMARY KEY AUTOINCREMENT,'
            'gameId TEXT,'
            'senderId TEXT,'
            'receiverId TEXT,'
            'amount INTEGER,'
            'createdAt INTEGER,'
            'FOREIGN KEY (gameId) REFERENCES Games(id),'
            'FOREIGN KEY (senderId) REFERENCES Players(id),'
            'FOREIGN KEY (receiverId) REFERENCES Players(id)'
            ')');
      },
      // Set the version. This executes the onCreate function and provides a
      // path to perform database upgrades and downgrades.
      version: 2,
    );
  }

  @override
  Future<void> addPlayer(Player player) async {
    // TODO change function name to reflect update
    await database.insert(
      "Players",
      player.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Player>> getPlayers() async {
    final dbResult = await database.query("Players");
    final players = List.generate(
        dbResult.length, (index) => Player.fromJson(dbResult[index]));
    players.remove(players.firstWhere((player) => player.id == bank.id));
    return players;
  }

  @override
  Future<Player?> getPlayerById(String id) async {
    final dbResult =
        await database.query("Players", where: "id = ?", whereArgs: [id]);
    if (dbResult.isEmpty) {
      return null;
    }
    final player = Player.fromJson(dbResult.first);
    return player;
  }

  @override
  Future<void> deletePlayer(Player player) async {
    await database.delete("Players", where: "id = ?", whereArgs: [player.id]);
  }

  @override
  Future<void> addGame(Game game) async {
    print("Here");
    await database.insert(
      "Games",
      {
        "id": game.id,
        "initialBalance": game.initialBalance,
        "moneyOnGo": game.moneyOnGo,
        "createdAt": game.createdAt.millisecondsSinceEpoch,
        "modifiedAt": game.modifiedAt.millisecondsSinceEpoch,
        "playerIds": jsonEncode(game.players.map((player) => player.id))
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    final playerStateBatch = database.batch();
    game.playerStates.forEach((player, playerState) {
      playerStateBatch.insert("PlayerState", {
        "gameId": game.id,
        "playerId": player.id,
        "balance": playerState.balance,
        "isBankrupt": playerState.isBankrupt ? 1 : 0,
        "colorValue": playerState.colorValue,
      });
    });
    await playerStateBatch.commit(noResult: true);
  }

  @override
  Future<List<Game>> getGames() async {
    // TODO Optimize
    final players = await getPlayers();
    final playerMap = {for (final player in players) player.id: player};

    final gamesDbResult = await database.query("Games");
    final games = List.generate(gamesDbResult.length, (index) {
      final gameMap = gamesDbResult[index];
      final game = Game.lazyLoad(
          id: gameMap["id"] as String,
          initialBalance: gameMap["initialBalance"] as int,
          moneyOnGo: gameMap["moneyOnGo"] as int,
          createdAt:
              DateTime.fromMillisecondsSinceEpoch(gameMap["createdAt"] as int),
          modifiedAt:
              DateTime.fromMillisecondsSinceEpoch(gameMap["modifiedAt"] as int),
          players: (jsonDecode(gameMap["playerIds"] as String) as List<String>)
              .map((playerId) => playerMap[playerId]!)
              .toList());
      return game;
    });
    return games;
  }

  @override
  Future<void> deleteGame(Game game) async {
    throw UnimplementedError();
  }

  @override
  Future<void> addOrUpdatePlayerState({
    required PlayerState playerState,
    required Player player,
    required Game game,
  }) async {
    await database.insert("PlayerStates", {
      "gameId": game.id,
      "playerId": player.id,
      "balance": playerState.balance,
      "isBankrupt": playerState.isBankrupt ? 1 : 0,
      "colorValue": playerState.colorValue
    });
  }

  @override
  Future<Map<Player, PlayerState>> getPlayerStates({required Game game}) async {
    final dbResult = await database
        .query("PlayerStates", where: "gameId = ?", whereArgs: [game.id]);

    final playerStates = {
      for (final dbResultMap in dbResult)
        game.players
                .firstWhere((player) => player.id == dbResultMap["playerId"]):
            PlayerState(
          balance: dbResultMap["balance"] as int,
          isBankrupt: dbResultMap["isBankrupt"] as int == 1,
          colorValue: dbResultMap["colorValue"] as int,
        )
    };

    return playerStates;
  }

  @override
  Future<void> addTransactionToGame({
    required MBTransaction.Transaction transaction,
    required Game game,
  }) async {
    await database.insert("Transactions", {
      "gameId": game.id,
      "senderId": transaction.sender.id,
      "receiverId": transaction.receiver.id,
      "amount": transaction.amount,
      "createdAt": transaction.createdAt,
    });
  }

  @override
  Future<List<MBTransaction.Transaction>> getTransactionsOfGame(
      {required Game game}) async {
    final dbResult = await database.query(
      "Transactions",
      where: "gameId = ?",
      whereArgs: [game.id],
    );

    final transactions = List.generate(dbResult.length, (index) {
      final transactionMap = dbResult[index];
      final transaction = MBTransaction.Transaction.load(
        receiver: game.players
            .firstWhere((player) => player.id == transactionMap["receiverId"]),
        sender: game.players
            .firstWhere((player) => player.id == transactionMap["senderId"]),
        amount: transactionMap["amount"] as int,
        createdAt: DateTime.fromMillisecondsSinceEpoch(
            transactionMap["createdAt"] as int),
      );
      return transaction;
    });

    return transactions;
  }
}

// class DummyDbService implements DbService {
//   late final List<Player> players;
//   late final List<Game> games;
//
//   @override
//   Future<void> init() async {
//     players = [];
//     games = [];
//   }
//
//   @override
//   Future<void> addPlayer(Player player) async {
//     players.add(player);
//   }
//
//   @override
//   Future<List<Player>> getPlayers() async {
//     return players;
//   }
//
//   @override
//   Future<Player> getPlayerById(String id) async {
//     return players.firstWhere((player) => player.id == id);
//   }
//
//   @override
//   Future<void> deletePlayer(Player player) async {
//     players.remove(player);
//   }
//
//   @override
//   Future<void> addGame(Game game) async {
//     games.add(game);
//   }
//
//   @override
//   Future<List<Game>> getGames() async {
//     return games..sort((a, b) => -a.modifiedAt.compareTo(b.modifiedAt));
//   }
//
//   @override
//   Future<void> deleteGame(Game game) async {
//     games.remove(game);
//   }
// }
