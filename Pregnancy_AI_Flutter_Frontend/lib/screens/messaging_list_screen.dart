import 'package:flutter/material.dart';
import '../widgets/app_background.dart';
import '../theme/app_theme.dart';
import '../utils/date_utils.dart';

class MessagingListScreen extends StatefulWidget {
  const MessagingListScreen({super.key});

  @override
  State<MessagingListScreen> createState() => _MessagingListScreenState();
}

class _MessagingListScreenState extends State<MessagingListScreen> {
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
              child: _buildHeaderBar(isSmall),
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
                      _buildSearchField(),
                      const SizedBox(height: 16),
                      _buildConversationTile(
                        name: 'Emily Carter',
                        message: "Let's discuss the new protocol...",
                        time: '10:42 AM',
                        unreadCount: 2,
                        avatarColor: Colors.grey,
                        onTap: () => Navigator.pushNamed(context, '/messaging-chat'),
                      ),
                      const SizedBox(height: 8),
                      _buildConversationTile(
                        name: 'Ben Carter',
                        message: "Attached is the patient's latest report.",
                        time: 'Yesterday',
                        avatarColor: Colors.teal,
                        roleBadge: 'PATIENT',
                        onTap: () => Navigator.pushNamed(context, '/messaging-chat'),
                      ),
                      const SizedBox(height: 8),
                      _buildConversationTile(
                        name: 'Olivia White',
                        message: 'Typing...',
                        time: '9:15 AM',
                        isHighlighted: true,
                        onTap: () => Navigator.pushNamed(context, '/messaging-chat'),
                      ),
                      const SizedBox(height: 8),
                      _buildConversationTile(
                        name: 'Sam Wilson',
                        message: 'Great, thanks!',
                        time: 'Wednesday',
                        avatarColor: Colors.green,
                        roleBadge: 'PATIENT',
                        onTap: () => Navigator.pushNamed(context, '/messaging-chat'),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderBar(bool isSmall) {
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
              'Messaging',
              style: TextStyle(
                fontSize: isSmall ? 18 : 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              AppDateUtils.getCurrentDate(),
              style: TextStyle(fontSize: isSmall ? 12 : 14, color: Colors.grey[600]),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.search, size: isSmall ? 20 : 22, color: Colors.black87),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.lightGray),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppTheme.textGray),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search conversations',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationTile({
    required String name,
    required String message,
    required String time,
    int unreadCount = 0,
    Color? avatarColor,
    bool isHighlighted = false,
    String? roleBadge,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: isHighlighted ? Colors.blue.withOpacity(0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: avatarColor ?? Colors.grey.shade300,
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(width: 6),
                        if (roleBadge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: Colors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text(roleBadge, style: const TextStyle(fontSize: 10, color: Colors.teal)),
                          ),
                        const Spacer(),
                        Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textGray)),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(message, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textGray)),
                  ],
                ),
              ),
              if (unreadCount > 0)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(color: Color(0xFF6C63FF), shape: BoxShape.circle),
                  child: Center(
                    child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}


