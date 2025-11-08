import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../models/learn_slide.dart';
import '../services/mock_ai_service.dart';
import '../services/local_storage_service.dart';
import 'package:uuid/uuid.dart';

class AIProvider with ChangeNotifier {
  final LocalStorageService _storage = LocalStorageService();
  final MockAIService _aiService = MockAIService();
  final Uuid _uuid = const Uuid();

  List<ChatMessage> _currentMessages = [];
  String? _currentThreadId;
  List<ChatThread> _threads = [];
  bool _isLoading = false;

  List<ChatMessage> get currentMessages => _currentMessages;
  String? get currentThreadId => _currentThreadId;
  List<ChatThread> get threads => _threads;
  bool get isLoading => _isLoading;

  AIProvider() {
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    _threads = await _storage.getChatThreads();
    notifyListeners();
  }

  Future<void> loadThread(String threadId) async {
    _currentThreadId = threadId;
    _currentMessages = await _storage.getChatMessages(threadId);
    notifyListeners();
  }

  Future<void> createNewThread() async {
    _currentThreadId = _uuid.v4();
    _currentMessages = [];
    notifyListeners();
  }

  Future<void> sendMessage(String message, {String? userId}) async {
    // Validate financial message
    if (!_aiService.isFinancialMessage(message)) {
      // Still allow the message but show a warning
      // In production, we might block it or send a warning message
    }

    // Add user message
    final userMessage = ChatMessage(
      id: _uuid.v4(),
      content: message,
      isUser: true,
      timestamp: DateTime.now(),
      threadId: _currentThreadId,
    );

    _currentMessages.add(userMessage);
    await _storage.saveChatMessages(_currentThreadId ?? '', [userMessage]);

    // Update thread
    if (_currentThreadId != null) {
      final thread = ChatThread(
        id: _currentThreadId!,
        title: message.length > 30 ? '${message.substring(0, 30)}...' : message,
        lastMessageTime: DateTime.now(),
        messageCount: _currentMessages.length,
      );
      await _storage.saveChatThread(thread);
      await _loadThreads();
    }

    notifyListeners();

    // Get AI response
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _aiService.getResponse(message, userId: userId);

      final aiMessage = ChatMessage(
        id: _uuid.v4(),
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
        threadId: _currentThreadId,
      );

      _currentMessages.add(aiMessage);
      await _storage.saveChatMessages(_currentThreadId ?? '', [aiMessage]);

      // Update thread again
      if (_currentThreadId != null) {
        final thread = ChatThread(
          id: _currentThreadId!,
          title: _currentMessages.first.content.length > 30
              ? '${_currentMessages.first.content.substring(0, 30)}...'
              : _currentMessages.first.content,
          lastMessageTime: DateTime.now(),
          messageCount: _currentMessages.length,
        );
        await _storage.saveChatThread(thread);
        await _loadThreads();
      }
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<LearnSlide?> recommendNextSlide({
    required List<LearnSlide> allSlides,
    required List<String> completedSlideIds,
  }) async {
    return await _aiService.recommendNextSlide(
      allSlides: allSlides,
      completedSlideIds: completedSlideIds,
    );
  }

  String getGreeting(String userName) {
    return _aiService.getGreeting(userName);
  }
}


