# PLAN Card Game - Climate Change Awareness

A digital implementation of the "Play Learn and Act Now" (PLAN) card game in Godot 4.4.

## About the Game

PLAN is a climate change awareness card game that aims to bridge the environmental education gap and inspire climate action. The game features problem cards representing environmental challenges and solution cards that address these problems.

### Game Features

- 2-5 player support
- Educational gameplay about climate issues and solutions
- Strategic card play
- Scoring system with multiple rounds
- Ultimate cards that can solve any problem

## How to Play

1. Players receive 2-5 cards each (depending on the number of players)
2. The game starts with a problem card on the table
3. The first player must play a solution card that solves the current problem
4. After playing a solution, the player must play a problem card to continue the game
5. Players continue taking turns in this pattern
6. A player wins the round (CHECKMATE) when they play their last problem card
7. Points are awarded at the end of each round (5 points for CHECKMATE, 3/2/1 for other players)
8. The player with the highest cumulative score after all rounds is the CHAMPION

## Installation

1. Clone this repository
2. Open the project in Godot 4.4
3. Run the game from the editor or export it to your platform of choice

## Project Structure

```
plan_card_game/
├── assets/
│   ├── cards/
│   │   ├── problem_cards/
│   │   └── solution_cards/
│   ├── fonts/
│   ├── icons/
│   └── sounds/
├── scenes/
│   ├── card/
│   │   ├── card_display.tscn
│   │   └── card_display.gd
│   ├── main_menu/
│   │   ├── main_menu.tscn
│   │   └── main_menu.gd
│   ├── game/
│   │   ├── game.tscn
│   │   ├── game.gd
│   │   ├── player/
│   │   │   ├── player.tscn
│   │   │   └── player.gd
│   │   ├── table/
│   │   │   ├── table.tscn
│   │   │   └── table.gd
│   │   └── ui/
│   │       ├── game_ui.tscn
│   │       └── game_ui.gd
│   └── rules/
│       ├── rules.tscn
│       └── rules.gd
└── scripts/
    ├── autoload/
    │   ├── game_manager.gd
    │   └── card_database.gd
    ├── classes/
    │   ├── card.gd
    │   ├── problem_card.gd
    │   ├── solution_card.gd
    │   └── deck.gd
    └── utils/
        └── utils.gd
```

## Development

This game was developed with Godot 4.4 using GDScript. The code is structured following object-oriented principles and the Godot style guidelines.

## Credits

Based on the "Play Learn and Act Now" (PLAN) card game created by Ecocykle Foundation.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
