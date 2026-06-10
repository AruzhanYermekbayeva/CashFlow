# CashFlow — Personal Finance App

Mobile app for tracking personal finances. Built with Flutter, works fully offline with local storage.

## Features

- **Transactions** — add and delete income/expense entries
- **Budget** — set spending limits by category
- **Goals** — create savings goals and track progress
- **Reports** — visualize spending with charts
- **Profile** — personal settings

## Tech Stack

| | |
|---|---|
| Framework | Flutter (Dart) |
| State management | Provider |
| Local database | SQLite (sqflite) |
| Charts | fl_chart |
| Font | Montserrat |

## Project Structure

```
lib/
├── main.dart                  # App entry point, navigation
├── provider.dart              # Global state (TransactionProvider)
├── transactions_page.dart     # Income/expense tracking
├── budget_page.dart           # Budget management
├── goals_page.dart            # Savings goals
├── reports_page.dart          # Charts and statistics
├── profile_page.dart          # User profile
├── helper/
│   └── db_helper.dart         # SQLite CRUD operations
└── models/
    ├── transactions_model.dart
    ├── budget_model.dart
    └── goals_model.dart
```

## Getting Started

```bash
git clone https://github.com/AruzhanYermekbayeva/cashflow.git
cd cashflow
flutter pub get
flutter run
```

Requires Flutter SDK 3.7+. No API keys or environment variables needed — all data is stored locally on device.
