import 'dart:async';

import 'package:get_it/get_it.dart';
import 'package:monobank/models/game.dart';
import 'package:monobank/services/db_service.dart';

class GameRoomController {
  final Game game;

  GameRoomController({required this.game});

  final _dbService = GetIt.instance.get<DbService>();

  final _gameRoomStateStreamController = StreamController<GameRoomState>();
  Stream<GameRoomState> get gameRoomStateStream =>
      _gameRoomStateStreamController.stream;

  void addTransaction(Transaction transaction) {
    game.addTransaction(transaction);
    //TODO Update DB
    _gameRoomStateStreamController.add(TransactionsUpdatedGameRoomState());
  }
}

abstract class GameRoomState {}

class TransactionsUpdatedGameRoomState extends GameRoomState {}
