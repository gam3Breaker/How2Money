# MoneyWise - Gamified Youth Financial App

MoneyWise is a Flutter mobile application designed to help South African youth learn financial skills through gamification, AI-powered assistance, and practical tools like bill splitting and debt tracking.

## Features

### 🎮 PlayWise - Charades Game
- Learn financial terms through interactive charades
- 30-second rounds with timer
- Personalized word selection based on learning progress
- AI-powered feedback after each game

### 🤖 KasiCash AI Assistant
- Premium AI-powered financial advisor
- Chat with friendly, youth-targeted responses
- Financial-only conversation enforcement
- Demo mode available for non-premium users
- Conversation history and thread management

### 📚 Learn Slides
- Bite-sized financial education slides
- Topics: Budgeting, Saving, Credit Score, Debt
- Progress tracking with completion percentage
- AI recommendations for next slides to learn

### 💰 Split Bills & Debt Tracker
- Fair split algorithm considering cash on hand
- Add items and participants
- Automatic debt creation from splits
- Weekly reminder system
- Mock SMS/WhatsApp reminder sharing

### 🎯 Personal Game
- Generate personalized games from bank statements
- Mock statement upload and processing
- Reflection questions based on spending patterns
- Categorized spending analysis

### 📱 TikTok Integration (Placeholder)
- UI for sharing challenges to TikTok
- Mock video preview generation
- Leaderboard placeholder
- TODO markers for backend integration

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── chat_message.dart
│   ├── debt.dart
│   ├── game.dart
│   ├── learn_slide.dart
│   └── split_item.dart
├── providers/                # State management (Provider)
│   ├── auth_provider.dart
│   ├── ai_provider.dart
│   ├── game_provider.dart
│   ├── split_provider.dart
│   └── learn_provider.dart
├── services/                 # Business logic & API mocks
│   ├── local_storage_service.dart
│   ├── mock_ai_service.dart
│   └── split_algorithm.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── dashboard_screen.dart
│   ├── learn_slides_screen.dart
│   ├── game_screen.dart
│   ├── chat_screen.dart
│   ├── split_screen.dart
│   ├── debt_list_screen.dart
│   ├── profile_screen.dart
│   ├── personal_game_screen.dart
│   └── tiktok_integration_screen.dart
├── theme/                    # App theme & styling
│   └── app_theme.dart
└── widgets/                  # Reusable widgets (if needed)
```

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / Xcode (for mobile development)
- VS Code or Android Studio (recommended IDE)

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd How2Money
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Running on Specific Platforms

- **Android**: `flutter run -d android`
- **iOS**: `flutter run -d ios`
- **Web**: `flutter run -d chrome` (limited functionality)

## Mock Data & Backend Integration

### Current Mock Implementation

The app currently uses mock data and local storage:

- **AI Service**: `lib/services/mock_ai_service.dart` - Returns canned responses
- **Local Storage**: `lib/services/local_storage_service.dart` - Uses `shared_preferences`
- **Statement Upload**: Mock upload that generates sample spending data

### Backend Integration Points

The following endpoints need to be integrated:

1. **POST /api/ai**
   - Location: `lib/services/mock_ai_service.dart`
   - TODO: Replace `getResponse()` method with real API call
   - Expected: Send user message, receive AI response

2. **POST /api/upload_statement**
   - Location: `lib/services/mock_ai_service.dart` - `generatePersonalGame()`
   - TODO: Replace mock statement processing with real upload
   - Expected: Upload bank statement, receive categorized transactions

3. **POST /api/split**
   - Location: `lib/services/split_algorithm.dart`
   - TODO: Add API call option for server-side split calculation
   - Current: Client-side algorithm implementation

4. **TikTok Integration**
   - Location: `lib/screens/tiktok_integration_screen.dart`
   - TODO: Integrate TikTok Developer API
   - TODO: Integrate TikTok Effect House for filters
   - TODO: Implement video generation service
   - TODO: Implement leaderboard API

### Environment Variables

Create a `.env` file (or use Flutter's environment configuration):

```env
OPENAI_API_KEY=your_openai_key_here
API_BASE_URL=https://your-api-url.com
TIKTOK_CLIENT_KEY=your_tiktok_key_here
```

## Demo Script

Use this script to demonstrate the app to mentors:

### Step 1: Splash Screen
- App opens with MoneyWise logo and splash animation
- Automatically navigates to onboarding (first time) or dashboard

### Step 2: Onboarding
- Navigate through 3 introductory slides
- Enter display name (e.g., "Tondani")
- Select financial background (Student/Employed/Freelance/None)
- Click "Get Started"

### Step 3: Dashboard
- See greeting from KasiCash AI
- View learning progress (0% initially)
- Three main action cards:
  - Play: Charades Game
  - Chat: KasiCash (PREMIUM)
  - Split: Bills & Debts

### Step 4: Play Charades Game
- Click "Play: Charades Game"
- Click "Start Game"
- See financial word cards with 30-second timer
- Click "Got it!" or "Skip" for each round
- After 5 rounds, see score and AI feedback

### Step 5: Split Bill
- Click "Split: Bills & Debts"
- Click "Add Item" - Add "Pizza" for R150
- Select participants
- Click "Add Participant" - Add "John" with R200 cash
- Click "Calculate Split"
- Review split results
- Click "Save Split & Create Debts"

### Step 6: KasiCash Chat (Demo)
- Click "Chat: KasiCash AI"
- See premium gate dialog
- Click "Try Demo"
- Send a message (e.g., "How do I save money?")
- See AI response
- Try non-financial message to see warning

### Step 7: Learn Slides
- Navigate to "Learn" tab
- Open a slide card
- Read bullet points
- Click "Mark as Read"
- See progress update

### Step 8: Personal Game
- Go to Profile tab
- Click "Personal Game"
- Click "Upload Statement (Mock)"
- Wait for processing
- Answer reflection questions
- See results and spending breakdown

## Testing

### Run Tests
```bash
flutter test
```

### Test Coverage
- Unit tests for split algorithm (TODO)
- Widget tests for main screens (TODO)
- Integration tests (TODO)

## Localization

### Current Status
- All text is in English
- TODO: Localize to South African youth slang
- Location markers: Check `mock_ai_service.dart` for response localization
- UI text: Check screen files for localization markers

### Localization Points
- KasiCash greetings and responses
- Game feedback messages
- Onboarding slides
- Chat messages

## Configuration

### Premium Features
- Premium status is stored in `shared_preferences`
- Toggle premium in Profile screen (demo mode)
- Premium gates: Chat with KasiCash, advanced features

### Currency
- Default: ZAR (South African Rand)
- Configurable in Profile screen (TODO: implement selection)

### Reminder Settings
- Weekly debt reminder toggle per debt
- Reminder time setting (TODO: implement)

## Troubleshooting

### Common Issues

1. **Flutter not found**
   - Ensure Flutter is installed and in PATH
   - Run `flutter doctor` to check setup

2. **Dependencies not installing**
   - Run `flutter pub get`
   - Check `pubspec.yaml` for correct dependencies

3. **Build errors**
   - Run `flutter clean`
   - Run `flutter pub get`
   - Run `flutter run` again

4. **Shared Preferences not working**
   - Ensure `shared_preferences` package is installed
   - Check platform-specific setup (iOS/Android permissions)

## Future Enhancements

- [ ] Backend API integration
- [ ] Real AI service (OpenAI/Claude)
- [ ] TikTok API integration
- [ ] Video generation for challenges
- [ ] Push notifications for reminders
- [ ] Social multiplayer for games
- [ ] Bank statement OCR integration
- [ ] Multi-currency support
- [ ] Advanced analytics
- [ ] Export financial reports

## License

[Your License Here]

## Contact

[Your Contact Information]

---

**Note**: This is a frontend-only implementation with mock data. Backend integration is required for production use.


