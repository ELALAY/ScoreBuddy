import 'dart:async';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';

import '../Models/game_model.dart';
import '../Models/player_model.dart';
import '../Models/match_model.dart';
import '../Models/score_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  DatabaseHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'scorebuddy1.db');
    debugPrint('Database path: $path');
    return await openDatabase(
      path,
      version: 1,
      onCreate: createTables,
      onOpen: (db) async {
        debugPrint('Database opened');
      },
    );
  }

  Future<void> createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS Player (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Game (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Match (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        name TEXT UNIQUE NOT NULL,        
        game_id INTEGER NOT NULL,
        active INTEGER DEFAULT 1,               
        FOREIGN KEY (game_id) REFERENCES Game (id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS Score (
        id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
        game_id TEXT NOT NULL,
        match_id INTEGER NOT NULL,
        player_id INTEGER NOT NULL,
        score INTEGER DEFAULT 0,
        won INTEGER NOT NULL,
        FOREIGN KEY (player_id) REFERENCES Player (id) ON DELETE CASCADE,
        FOREIGN KEY (match_id) REFERENCES Match (id) ON DELETE CASCADE,        
        FOREIGN KEY (game_id) REFERENCES Game (id) ON DELETE CASCADE
      )
    ''');////-1:loss, 0: lost, 1: draw, 

    await db.execute('''
      INSERT INTO Game (name) VALUES ('Rami')
    ''');
    await db.execute('''
      INSERT INTO Player (name) VALUES ('Aymane')
    ''');
    await db.execute('''
      INSERT INTO Player (name) VALUES ('Sara')
    ''');
    await db.execute('''
      INSERT INTO Match (game_id, name) VALUES (1, 'Rami')
    ''');
    await db.execute('''
      INSERT INTO Score (game_id, match_id, player_id) VALUES (1, 1, 1)
    ''');
    await db.execute('''
      INSERT INTO Score (game_id, match_id, player_id) VALUES (1, 1, 2)
    ''');
  }

  //--------------------------------------------------------------------------------------
//********Player Player**********/
//--------------------------------------------------------------------------------------

  Future<String> getPlayerName(int id) async {
    var db = await database;
    List<Map<String, dynamic>> result =
        await db.rawQuery('SELECT name FROM Player WHERE id = ?', [id]);

    if (result.isNotEmpty) {
      return result.first['name'] as String;
    } else {
      return ""; // Return empty string if Player with given id is not found
    }
  }

  Future<List<Player>> getAllPlayers() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('Player');

    // Convert the query result to a list of Game objects
    List<Player> playerList = [];
    for (Map<String, dynamic> map in result) {
      Player player = Player.fromMap(map);
      playerList.add(player);
    }
    return playerList;
  }

  Future<void> insertPlayer(Player player) async {
    Database db = await instance.database;
    await db.execute('''
      INSERT INTO Player (name) VALUES (?)
    ''', [player.name]);
  }

  Future<void> deletePlayer(int id) async {
    Database db = await instance.database;
    await db.execute('''
      DELETE FROM Player WHERE id = ?
    ''', [id]);
  }

//--------------------------------------------------------------------------------------
//********Games Functions**********/
//--------------------------------------------------------------------------------------

  Future<List<Game>> getAllGames() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('Game');

    // Convert the query result to a list of Game objects
    List<Game> gameList = [];
    for (Map<String, dynamic> map in result) {
      Game game = Game.fromMap(map);
      gameList.add(game);
    }
    return gameList;
  }

  Future<int> insertGame(String gameName) async {
    Database db = await instance.database;

    // Insert the group and get its generated ID
    int groupId =
        await db.rawInsert('INSERT INTO Game (name) VALUES (?)', [gameName]);
    // Insert the group members for the inserted group ID

    return groupId;
  }

  Future<Game> getGameById(int id) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'Game',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isNotEmpty) {
      return Game.fromMap(result.first);
    } else {
      throw Exception('Group not found');
    }
  }

  Future<Game> getGameByName(String name) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query(
      'Game',
      where: 'name = ?',
      whereArgs: [name],
    );

    if (result.isNotEmpty) {
      return Game.fromMap(result.first);
    } else {
      throw Exception('Group not found');
    }
  }

  Future<void> updateGameName(int gameId, String newName) async {
    final db = await database;
    await db.update(
      'Game',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [gameId],
    );
  }

  Future<int> deleteGameById(int gameId) async {
    var db = await database;

    int result = await db.rawDelete('DELETE FROM Game WHERE id = ?', [gameId]);
    debugPrint('deleted $gameId');
    return result;
  }

//--------------------------------------------------------------------------------------
//********Match Functions**********/
//--------------------------------------------------------------------------------------

  Future<int> deleteMatchById(int matchId) async {
    var db = await database;

    int result =
        await db.rawDelete('DELETE FROM Match WHERE id = ?', [matchId]);
    debugPrint('deleted $matchId');
    return result;
  }

  Future<void> insertMatch(Match match) async {
    final db = await instance
        .database; // Assuming you have a function to open your database
    await db.rawInsert('''
      INSERT INTO Match (game_id, name) VALUES (?, ?)
    ''', [match.gameId, match.name]);
  }

  Future<List<Match>> getAllMatches() async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.query('Match');

    // Convert the query result to a list of Game objects
    List<Match> matchList = [];
    for (Map<String, dynamic> map in result) {
      Match match = Match.fromMap(map);
      matchList.add(match);
    }
    return matchList;
  }

  Future<Match> getMatch(int id) async {
    final db = await instance
        .database; // Assuming you have a function to open your database
    final maps = await db.rawQuery('''
      SELECT * FROM Match WHERE id = ?
      ''', [id]);

    if (maps.isNotEmpty) {
      return Match.fromMap(maps.first);
    } else {
      throw Exception('Match not found');
    }
  }

  Future<Map<int, int>> getMatchePlayerCounts() async {
    final db = await instance.database; // Your database opening function
    final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT match_id, COUNT(DISTINCT player_id) as player_count
    FROM Score
    GROUP BY match_id
  ''');

    // Convert result to a map where key is match_id and value is player_count
    Map<int, int> matchPlayerCounts = {};
    for (var row in result) {
      matchPlayerCounts[row['match_id']] = row['player_count'];
    }

    return matchPlayerCounts;
  }

//--------------------------------------------------------------------------------------
//********Sccores Functions**********/
//--------------------------------------------------------------------------------------

  //add a score
  Future<void> insertScore(Score score) async {
    final db = await instance
        .database; // Assuming you have a function to open your database
    await db.insert(
      'Score', // Your table name
      score.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> removeMatchMember(Score score) async {
    Database db = await instance.database;
    // Insert new group members for the given group ID
    await db.rawInsert('DELETE FROM score WHERE id = ?', [score.id]);
  }

  Future<List<Player>> getMatchPlayers(int matchId) async {
    Database db = await instance.database;
    List<Map<String, dynamic>> result = await db.rawQuery('''
      SELECT * FROM Player as p
      JOIN Score as s
      ON p.id = s.player_id
      WHERE s.match_id = ?
    ''', [matchId]);

    // Convert the query result to a list of Group objects
    List<Player> personList = [];
    for (Map<String, dynamic> map in result) {
      Player person = Player.fromMap(map);
      personList.add(person);
    }
    return personList;
  }
}
