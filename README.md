# GitHub Repository Explorer

A Flutter application for searching public GitHub repositories, viewing repository details and open issues, and managing favourite repositories with offline support.

## Features

- Search public GitHub repositories
- Debounced search input
- Infinite scrolling with pagination
- Repository details
- Display the latest 5 open issues
- Add and remove favourite repositories
- Persist favourites across app restarts
- View favourites while offline
- Cache the last successful search results for offline use
- Loading, empty, error, and offline states
- GitHub API rate-limit handling
- Light and dark mode based on the system setting

## Tech Stack

- **Flutter / Dart** – Cross-platform application development
- **Provider** – State management with clear separation between UI and business logic
- **Dio** – HTTP client for GitHub API requests and error handling
- **SharedPreferences** – Lightweight local persistence for favourites and cached search results
- **connectivity_plus** – Detects offline state when the application starts

## Architecture

The app follows a simple layered structure. The UI layer contains screens and reusable widgets, while the Provider layer manages application state and business logic. The service layer handles communication with the GitHub REST API and local storage using SharedPreferences. Models are used to represent repository and issue data. This structure keeps the UI, business logic, and data handling separate and makes the code easier to maintain and test.


## Setup

### Requirements

- Flutter 3.16+
- Dart 3.x
- Android Studio or Xcode for running on a device or emulator

### Run the project

```bash
flutter pub get
flutter run
```
## Screenshots

### Search Results

![Search Results](media/search.png)

### Repository Details

![Repository Details](media/details.png)

### Open Issues

![Open Issues](media/issues.png)

### Favourites

![Favourites](media/favourites.png)

### Offline Mode

![Offline Mode](media/offline.png)

## Demo

[Watch the demo recording](media/demo.mov)

### Trade-offs and Known Limitations

- Only the latest successful search results are saved for offline use.
- The search text is not saved with the cached results. This keeps the offline feature simple.
- There is no retry or backoff when an API request fails.
- Language filtering and sorting are not included.
- Test coverage is limited because of the time available for the assessment.
- The required widget test for the search flow was not completed within the available time.

## What I Would Build Next

With another 8 hours, I would focus on the following improvements:

- Add language filtering and sorting by stars or recently updated repositories to make it easier to find relevant repositories.

- Add pull-to-refresh so users can refresh the current search results.

- Improve API reliability by adding retry and backoff for temporary network failures.

- Improve offline support by showing when cached results were last updated and refreshing them when the device comes back online.

- Add more repository information, such as topics, contributors, and pull requests.

- Add GitHub Actions to run `flutter analyze` and tests automatically when changes are pushed.

- Expand the test coverage to include the search flow, pagination, favourites, and offline behaviour.

