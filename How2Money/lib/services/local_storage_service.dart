import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/chat_message.dart';
import '../models/debt.dart';
import '../models/game.dart';
import '../models/learn_slide.dart';
import '../models/split_item.dart';

class LocalStorageService {
  static const String _userKey = 'user';
  static const String _chatMessagesKey = 'chat_messages';
  static const String _chatThreadsKey = 'chat_threads';
  static const String _debtsKey = 'debts';
  static const String _gameSessionsKey = 'game_sessions';
  static const String _learnSlidesKey = 'learn_slides';
  static const String _completedSlidesKey = 'completed_slides';
  static const String _splitsKey = 'splits';
  static const String _participantsKey = 'participants';
  static const String _personalGamesKey = 'personal_games';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    try {
      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      return null;
    }
  }

  Future<void> saveChatMessages(String threadId, List<ChatMessage> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final allMessages = await getChatMessages(threadId);
    allMessages.addAll(messages);
    final messagesJson = allMessages.map((m) => m.toJson()).toList();
    await prefs.setString('$_chatMessagesKey/$threadId', jsonEncode(messagesJson));
  }

  Future<List<ChatMessage>> getChatMessages(String threadId) async {
    final prefs = await SharedPreferences.getInstance();
    final messagesJson = prefs.getString('$_chatMessagesKey/$threadId');
    if (messagesJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(messagesJson);
      return decoded.map((m) => ChatMessage.fromJson(m)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveChatThread(ChatThread thread) async {
    final prefs = await SharedPreferences.getInstance();
    final threads = await getChatThreads();
    threads.removeWhere((t) => t.id == thread.id);
    threads.add(thread);
    final threadsJson = threads.map((t) => t.toJson()).toList();
    await prefs.setString(_chatThreadsKey, jsonEncode(threadsJson));
  }

  Future<List<ChatThread>> getChatThreads() async {
    final prefs = await SharedPreferences.getInstance();
    final threadsJson = prefs.getString(_chatThreadsKey);
    if (threadsJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(threadsJson);
      return decoded.map((t) => ChatThread.fromJson(t)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveDebt(Debt debt) async {
    final prefs = await SharedPreferences.getInstance();
    final debts = await getDebts();
    debts.removeWhere((d) => d.id == debt.id);
    debts.add(debt);
    final debtsJson = debts.map((d) => d.toJson()).toList();
    await prefs.setString(_debtsKey, jsonEncode(debtsJson));
  }

  Future<List<Debt>> getDebts() async {
    final prefs = await SharedPreferences.getInstance();
    final debtsJson = prefs.getString(_debtsKey);
    if (debtsJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(debtsJson);
      return decoded.map((d) => Debt.fromJson(d)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> deleteDebt(String debtId) async {
    final prefs = await SharedPreferences.getInstance();
    final debts = await getDebts();
    debts.removeWhere((d) => d.id == debtId);
    final debtsJson = debts.map((d) => d.toJson()).toList();
    await prefs.setString(_debtsKey, jsonEncode(debtsJson));
  }

  Future<void> saveGameSession(GameSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final sessions = await getGameSessions();
    sessions.removeWhere((s) => s.id == session.id);
    sessions.add(session);
    final sessionsJson = sessions.map((s) => s.toJson()).toList();
    await prefs.setString(_gameSessionsKey, jsonEncode(sessionsJson));
  }

  Future<List<GameSession>> getGameSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionsJson = prefs.getString(_gameSessionsKey);
    if (sessionsJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(sessionsJson);
      return decoded.map((s) => GameSession.fromJson(s)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> saveLearnSlides(List<LearnSlide> slides) async {
    final prefs = await SharedPreferences.getInstance();
    final slidesJson = slides.map((s) => s.toJson()).toList();
    await prefs.setString(_learnSlidesKey, jsonEncode(slidesJson));
  }

  Future<List<LearnSlide>> getLearnSlides() async {
    final prefs = await SharedPreferences.getInstance();
    final slidesJson = prefs.getString(_learnSlidesKey);
    if (slidesJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(slidesJson);
      return decoded.map((s) => LearnSlide.fromJson(s)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> markSlideCompleted(String slideId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedSlides = await getCompletedSlides();
    if (!completedSlides.contains(slideId)) {
      completedSlides.add(slideId);
      await prefs.setStringList(_completedSlidesKey, completedSlides);
    }
  }

  Future<List<String>> getCompletedSlides() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_completedSlidesKey) ?? [];
  }

  Future<void> saveSplit(List<SplitItem> items, List<Participant> participants) async {
    final prefs = await SharedPreferences.getInstance();
    final splitsJson = items.map((s) => s.toJson()).toList();
    await prefs.setString(_splitsKey, jsonEncode(splitsJson));
    final participantsJson = participants.map((p) => p.toJson()).toList();
    await prefs.setString(_participantsKey, jsonEncode(participantsJson));
  }

  Future<List<SplitItem>> getSplits() async {
    final prefs = await SharedPreferences.getInstance();
    final splitsJson = prefs.getString(_splitsKey);
    if (splitsJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(splitsJson);
      return decoded.map((s) => SplitItem.fromJson(s)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<Participant>> getParticipants() async {
    final prefs = await SharedPreferences.getInstance();
    final participantsJson = prefs.getString(_participantsKey);
    if (participantsJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(participantsJson);
      return decoded.map((p) => Participant.fromJson(p)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> savePersonalGame(PersonalGame game) async {
    final prefs = await SharedPreferences.getInstance();
    final games = await getPersonalGames();
    games.removeWhere((g) => g.id == game.id);
    games.add(game);
    final gamesJson = games.map((g) => g.toJson()).toList();
    await prefs.setString(_personalGamesKey, jsonEncode(gamesJson));
  }

  Future<List<PersonalGame>> getPersonalGames() async {
    final prefs = await SharedPreferences.getInstance();
    final gamesJson = prefs.getString(_personalGamesKey);
    if (gamesJson == null) return [];
    try {
      final List<dynamic> decoded = jsonDecode(gamesJson);
      return decoded.map((g) => PersonalGame.fromJson(g)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}


