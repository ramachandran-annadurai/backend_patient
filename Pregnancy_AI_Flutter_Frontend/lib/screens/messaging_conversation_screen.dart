import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';

class MessagingConversationScreen extends StatefulWidget {
  final String name;
  const MessagingConversationScreen({super.key, this.name = 'Emily Carter'});

  @override
  State<MessagingConversationScreen> createState() => _MessagingConversationScreenState();
}

class _MessagingConversationScreenState extends State<MessagingConversationScreen> {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final paddings = MediaQuery.of(context).padding;
    final bool isSmall = size.width < 360;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isSmall ? 12.0 : 16.0,
                vertical: 8.0,
              ),
              child: _buildHeaderBar(isSmall, widget.name),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: size.height - paddings.top - paddings.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      _assistantBubble("Hello Jessica! I'm your AI assistant. How can I help you today? You can ask me questions or leave a voice message for Dr. Carter."),
                      const SizedBox(height: 12),
                      _voiceBubble(),
                      const SizedBox(height: 12),
                      _replyBubble("Hi Jessica, I've listened to your message. Mild back pain is quite common. Try using a warm compress and gentle stretches. If it persists or worsens, let me know. We can discuss it further at your next appointment.", '10:32 AM'),
                      const SizedBox(height: 12),
                      _assistantQuickActions(),
                      const SizedBox(height: 24),
                      _micCTA(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            _messageInputBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar(bool isSmall, String name) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.arrow_back, size: isSmall ? 20 : 24, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        Column(
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: isSmall ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Text('Online', style: TextStyle(color: Colors.green)),
          ],
        ),
        IconButton(
          icon: Icon(Icons.more_horiz, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _assistantBubble(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        margin: const EdgeInsets.only(right: 64),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
      ),
    );
  }

  Widget _voiceBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 24),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)],
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        width: 200,
        height: 56,
        child: const Icon(Icons.play_arrow, color: Colors.white),
      ),
    );
  }

  Widget _replyBubble(String text, String time) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 24),
        padding: const EdgeInsets.all(14),
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFE9F2FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(text, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 6),
            Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textGray)),
          ],
        ),
      ),
    );
  }

  Widget _assistantQuickActions() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 40),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("I can help with that. Say 'book an appointment' or 'go to vitals page' for quick actions.", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray)),
            const SizedBox(height: 10),
            Column(
              children: [
                _assistantActionButton('Book an Appointment', primary: true),
                const SizedBox(height: 8),
                _assistantActionButton('Go to Vitals Page'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _assistantActionButton(String label, {bool primary = false}) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: primary ? const Color(0xFFE9F2FF) : Colors.grey[100],
                foregroundColor: primary ? Colors.blue : Colors.black87,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _micCTA() {
    return Column(
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)]),
          ),
          child: const Icon(Icons.mic, color: Colors.white, size: 36),
        ),
        const SizedBox(height: 8),
        const Text('Tap to record a voice message'),
      ],
    );
  }

  Widget _messageInputBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          children: [
            IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline)),
            IconButton(onPressed: () {}, icon: const Icon(Icons.emoji_emotions_outlined)),
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Type a message...',
                ),
              ),
            ),
            IconButton(onPressed: () {}, icon: const Icon(Icons.attach_file)),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [Color(0xFF6C63FF), Color(0xFFFF6B9D)]),
              ),
              child: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}