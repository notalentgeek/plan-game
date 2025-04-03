# PLAN Card Game - Developer Documentation

This document provides technical information for developers who want to understand, modify, or extend the PLAN card game implementation.

## Architecture Overview

The game is built using a modular architecture with clear separation of concerns:

### Core Components

1. **Card System**
   - `Card`: Base class for all cards
   - `ProblemCard`: Class for environmental problem cards
   - `SolutionCard`: Class for solution cards (including ultimate cards)
   - `Deck`: Class for managing card collections

2. **Game Management**
   - `GameManager`: Central controller for game state, turns, and rules
   - `CardManager`: Handles card interactions and validity checks
   - `CardDatabase`: Manages card data and provides access to cards

3. **User Interface**
   - `CardDisplay`: Visual representation of a card
   - `Table`: Game table display
   - `GameUI`: UI elements for game controls and messaging
   - `MainMenu`: Game entry point and settings
   - `Rules`: Rules display and information

4. **Player System**
   - `Player`: Player state management (hand, actions, points)

## Class Details

### Card Classes

#### Card (Base Class)
```gdscript
class_name Card
extends Resource

enum CardType {
    PROBLEM,
    SOLUTION,
    ULTIMATE
}

var id: String           # Unique identifier
var card_name: String    # Display name
var description: String  # Card description
var card_type: int       # Type from CardType enum
var texture_path: String # Path to card image
var texture: Texture     # Loaded texture
```

#### ProblemCard
```gdscript
class_name ProblemCard
extends Card

var letter_code: String  # Alphabetical identifier (A-R)
var severity_index: int  # Numerical severity (1-10)
```

#### SolutionCard
```gdscript
class_name SolutionCard
extends Card

var solvable_problems: Array[String] # Problem letter codes this solution can solve
var is_ultimate: bool = false        # If true, can solve any problem
```

### Management Classes

#### GameManager
Singleton that manages the overall game state:
- Player turns
- Game initialization and setup
- Round management
- Score calculation
- Game flow control

#### CardManager
Singleton that handles card interactions:
- Checking if solution cards can solve problem cards
- Managing card playing logic
- Validating card plays

#### CardDatabase
Singleton that manages all card data:
- Initializes card data
- Provides access to cards
- Creates and shuffles decks

### UI Classes

#### CardDisplay
Visual representation of a card with:
- Card appearance based on type
- Selection and hover effects
- Click handling

#### Table
Game table where cards are played.

#### GameUI
Handles:
- Game action buttons
- Message popups
- Score display
- Game over screen

## Game Flow

1. **Game Initialization**
   - `MainMenu` → `GameManager.initialize_game()` → `GameManager.start_game()`
   - Cards are distributed to players
   - Initial problem card is placed on table

2. **Turn Cycle**
   - Active player plays a solution card to solve current problem
   - If solution is valid, player plays a problem card
   - Turn passes to next player

3. **Round End**
   - Player achieves CHECKMATE by playing their last problem card
   - Scores calculated (CHECKMATE = 5 points, others based on remaining cards)
   - New round begins

4. **Game End**
   - After predetermined number of rounds (default: 3)
   - Player with highest cumulative score is champion

## Signal Flow

The game uses a signal-based communication pattern:
- `GameManager` emits signals for game state changes
- `CardManager` emits signals for card interactions
- UI components listen for these signals and update accordingly

### Key Signals

```gdscript
# GameManager signals
signal game_started
signal player_turn_changed(player_id)
signal round_ended(scores)
signal game_ended(champion, final_scores)
signal card_dealt(player_id, card)

# CardManager signals
signal card_played(player_id, card)
signal invalid_play(player_id, reason)

# UI Component signals
signal card_clicked(card_display)
signal card_hovered(card_display)
```

## Adding New Cards

To add new cards to the game:

1. Add card data to `CardDatabase._initialize_problem_cards()` or `CardDatabase._initialize_solution_cards()`
2. Create card image in SVG or PNG format
3. Place image in appropriate directory:
   - Problem cards: `assets/cards/problem_cards/`
   - Solution cards: `assets/cards/solution_cards/`

Example of adding a new problem card:
```gdscript
# In CardDatabase._initialize_problem_cards()
var problems = [
    // ... existing cards ...
    ["p19", "New Problem", "Description of the new problem.",
     "res://assets/cards/problem_cards/new_problem.png", "S", 7]
]
```

## Modifying Game Rules

Game rules are implemented primarily in the `GameManager` and `CardManager` classes. To modify rules:

1. For turn mechanics, modify `GameManager.next_turn()`
2. For card playing logic, modify `CardManager` methods
3. For scoring, modify `GameManager._calculate_round_scores()`
4. For winning conditions, modify `CardManager.is_checkmate()`

## Performance Considerations

- Card textures are loaded on demand to reduce memory usage
- Use the `duplicate()` method when creating copies of cards
- Card displays are created and freed dynamically as needed

## Testing

The game should be tested with various scenarios:
- Different player counts (2-5)
- Edge cases like playing last card
- Invalid card plays
- Ultimate card functionality

## Future Improvements

Potential enhancements:
- Network multiplayer
- AI opponents
- Additional card types
- Animated card effects
- More detailed statistics and analytics
- Achievement system
- Custom card creator

## Troubleshooting Common Issues

- **Cards not displaying properly**: Check texture paths and ensure SVG/PNG files exist
- **Autoload errors**: Verify autoload order in Project Settings (CardDatabase should load before GameManager)
- **Card interaction issues**: Debug card_manager.is_valid_solution() logic
- **Turn sequence problems**: Check GameManager.next_turn() implementation
