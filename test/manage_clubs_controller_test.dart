import 'package:bierdygame/app/modules/clubAdmin/games/controller/manage_clubs_controller.dart';
import 'package:bierdygame/app/modules/clubAdmin/newGame/model/game_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('addGame inserts latest game at top', () {
    final controller = ManageClubsController();
    final first = GameModel(
      name: 'Game A',
      date: '2024-01-01',
      passkey: 'AAA111',
      status: GameStatus.active,
    );
    final second = GameModel(
      name: 'Game B',
      date: '2024-01-02',
      passkey: 'BBB222',
      status: GameStatus.draft,
    );

    controller.addGame(first);
    controller.addGame(second);

    expect(controller.games.first.name, 'Game B');
    expect(controller.games.length, 2);
  });

  test('filteredGames respects selected tab status', () {
    final controller = ManageClubsController();
    controller.games.addAll([
      GameModel(
        name: 'Active Game',
        date: '2024-01-01',
        passkey: 'AAA111',
        status: GameStatus.active,
      ),
      GameModel(
        name: 'Draft Game',
        date: '2024-01-02',
        passkey: 'BBB222',
        status: GameStatus.draft,
      ),
      GameModel(
        name: 'Completed Game',
        date: '2024-01-03',
        passkey: 'CCC333',
        status: GameStatus.completed,
      ),
    ]);

    controller.changeTab(1);
    expect(controller.filteredGames.length, 1);
    expect(controller.filteredGames.first.status, GameStatus.active);

    controller.changeTab(2);
    expect(controller.filteredGames.length, 1);
    expect(controller.filteredGames.first.status, GameStatus.draft);

    controller.changeTab(3);
    expect(controller.filteredGames.length, 1);
    expect(controller.filteredGames.first.status, GameStatus.completed);
  });
}
