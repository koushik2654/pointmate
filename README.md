# PointMate

PointMate is a simple and fast score-tracking application built with Flutter for card games, board games, family games, and group competitions.

Instead of tracking scores on paper, players can create a game, add participants, record scores for each round, and view live rankings throughout the game.

## Features

### Create Games

* Create unlimited games
* Give each game a custom name
* Manage multiple ongoing games

### Add Players

* Add any number of players
* Simple player management
* Avatar initials generated automatically

### Round-Based Scoring

* Create rounds dynamically
* Enter positive or negative points
* Update scores in real time

### Live Leaderboard

* Automatic ranking calculation
* Highlight current leader
* View total scores instantly

### Round History

* View all previous rounds
* Track score progression
* Edit or delete rounds

### Game Summary

* Final rankings
* Winner announcement
* Share results with friends

### Offline First

* No account required
* No internet connection required
* Local data storage
* Fast startup and performance

---

## Target Use Cases

PointMate can be used for:

* Rummy score tracking
* Poker score keeping
* Card games
* Board games
* Family game nights
* Team competitions
* Classroom point systems
* Any activity involving round-based scoring

---

## User Flow

1. Open PointMate
2. Create a new game
3. Add players
4. Start recording rounds
5. View live leaderboard
6. Finish game and review results

---

## Tech Stack

### Frontend

* Flutter
* Dart

### State Management

* GetX

### Local Storage

* Hive

### Architecture

* MVVM-inspired structure
* Repository pattern
* Feature-based organization

---

## Project Structure

```text
lib/
├── models/
│   ├── game_model.dart
│   ├── player_model.dart
│   ├── round_model.dart
│   └── score_model.dart
│
├── controllers/
│   ├── home_controller.dart
│   ├── game_controller.dart
│   ├── player_controller.dart
│   └── score_controller.dart
│
├── services/
│   └── local_storage_service.dart
│
├── views/
│   ├── home/
│   ├── create_game/
│   ├── game_dashboard/
│   ├── add_round/
│   ├── leaderboard/
│   └── history/
│
└── utils/
```

---

## Future Enhancements

### Version 2

* Dark mode
* Export to PDF
* Share game results
* Undo last round
* Custom game themes

### Version 3

* Cloud backup
* Google Sign-In
* Real-time multiplayer scoring
* Cross-device synchronization
* Tournament management

---

## Design Principles

* Fast score entry
* Minimal taps
* Clean user experience
* Offline-first approach
* No mandatory sign-up
* Simple and intuitive navigation

---

## Why PointMate?

Most casual games still rely on paper and pen for score tracking. PointMate provides a modern, reliable, and organized way to track scores, maintain history, and determine winners without interrupting gameplay.

Track every point. Never lose a score.
