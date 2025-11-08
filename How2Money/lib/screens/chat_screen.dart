import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../services/mock_ai_service.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showFinancialWarning = false;

  @override
  void initState() {
    super.initState();
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    if (aiProvider.currentThreadId == null) {
      aiProvider.createNewThread();
    } else {
      aiProvider.loadThread(aiProvider.currentThreadId!);
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    // Check if message is financial-related
    final isFinancial = MockAIService.isFinancialMessage(message);
    if (!isFinancial) {
      setState(() {
        _showFinancialWarning = true;
      });
      // Still allow sending but show warning
    } else {
      setState(() {
        _showFinancialWarning = false;
      });
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final aiProvider = Provider.of<AIProvider>(context, listen: false);

    // Check premium status
    if (authProvider.user?.isPremium != true) {
      _showPremiumDialog();
      _messageController.clear();
      return;
    }

    // Send message
    aiProvider.sendMessage(message, userId: authProvider.user?.id);
    _messageController.clear();

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: const Text(
          'KasiCash AI chat is a premium feature. Upgrade to premium to chat with KasiCash, or try a demo conversation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _startDemoConversation();
            },
            child: const Text('Try Demo'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement premium upgrade flow
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Premium upgrade coming soon!')),
              );
            },
            child: const Text('Upgrade'),
          ),
        ],
      ),
    );
  }

  void _startDemoConversation() {
    final aiProvider = Provider.of<AIProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Load demo messages
    aiProvider.createNewThread();
    aiProvider.sendMessage('Hello', userId: authProvider.user?.id);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final aiProvider = Provider.of<AIProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy, color: AppTheme.accentGold),
            SizedBox(width: 8),
            Text('KasiCash'),
          ],
        ),
        actions: [
          if (authProvider.user?.isPremium != true)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.accentGold,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'PREMIUM',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Financial warning banner
          if (_showFinancialWarning)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppTheme.error.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: AppTheme.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'KasiCash is here for money help — ask me about budgets, saving, or splitting bills',
                      style: TextStyle(
                        color: AppTheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () {
                      setState(() {
                        _showFinancialWarning = false;
                      });
                    },
                  ),
                ],
              ),
            ),

          // Messages list
          Expanded(
            child: Consumer<AIProvider>(
              builder: (context, provider, _) {
                if (provider.currentMessages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline,
                          size: 64,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          authProvider.user?.isPremium == true
                              ? 'Start chatting with KasiCash!'
                              : 'Try the demo or upgrade to premium',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (authProvider.user?.isPremium != true) ...[
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _startDemoConversation,
                            child: const Text('Try Demo Conversation'),
                          ),
                        ],
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.currentMessages.length +
                      (provider.isLoading ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == provider.currentMessages.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    final message = provider.currentMessages[index];
                    return _MessageBubble(message: message);
                  },
                );
              },
            ),
          ),

          // Input area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Ask about money, budgets, saving...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: AppTheme.primaryTeal,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final dynamic message; // ChatMessage

  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primaryTeal : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isUser ? Colors.white : AppTheme.textPrimary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: isUser
                    ? Colors.white.withOpacity(0.7)
                    : AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}


