import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';
import '../data/inbox_api_repository.dart';
import '../models/message.dart';

class ConversationPage extends StatefulWidget {
const ConversationPage({super.key});

static const routeName = '/conversation';

@override
State<ConversationPage> createState() => _ConversationPageState();
}

class _ConversationPageState extends State<ConversationPage> {
final _repository = InboxApiRepository();
final _composer = TextEditingController();

List<Message> _messages = [];

bool _loading = true;
String? _error;
bool _canSend = false;
bool _sending = false;



late String conversationId;
late String conversationStatus;

@override
void initState() {
  super.initState();

  final args = Get.arguments as Map;

  conversationId = args["id"];
  conversationStatus = args["status"];

  _loadMessages();

  _composer.addListener(() {
    final hasText = _composer.text.trim().isNotEmpty;

    if (hasText != _canSend) {
      setState(() {
        _canSend = hasText;
      });
    }
  });
}
@override
void dispose() {
_composer.dispose();
super.dispose();
}

Future<void> _loadMessages() async {
  setState(() {
    _loading = true;
    _error = null;
  });

  try {
    final items =
        await _repository.fetchMessages(conversationId: conversationId);

    setState(() {
      _messages = items;
    });
  } catch (err) {
    setState(() {
      _error = 'Failed to load messages';
    });
  } finally {
    setState(() {
      _loading = false;
    });
  }
}
Future<void> _sendMessage() async {
   if (conversationStatus == "closed") {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Conversation is closed")),
    );
    return;
  }
if (_composer.text.trim().isEmpty) return;


final body = _composer.text.trim();

setState(() {
  _sending = true;
});

_composer.clear();
FocusScope.of(context).unfocus();
if (conversationStatus == "closed") {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Conversation is closed")),
  );
  return;
}
try {
  final message = await _repository.sendMessage(
    conversationId: conversationId,
    body: body,
  );

  setState(() {
    _messages.add(message);
  });
} catch (err) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("Failed to send message")),
  );
} finally {
  setState(() {
    _sending = false;
  });
}


}

Future<void> _reopenConversation() async {
await _repository.updateStatus(
conversationId: conversationId,
status: "open",
);


setState(() {
  conversationStatus = "open";
});


}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: Text('Conversation $conversationId'),
),
body: Column(
children: [
Expanded(child: _buildBody()),


      if (conversationStatus == "closed")
        Padding(
          padding: const EdgeInsets.all(12),
          child: ElevatedButton(
            onPressed: _reopenConversation,
            child: const Text("Reopen Conversation"),
          ),
        ),

      if (conversationStatus != "closed")
        _Composer(
          controller: _composer,
          onSend: _sendMessage,
          canSend: _canSend,
          sending: _sending,
        ),
    ],
  ),
);


}

Widget _buildBody() {
if (_loading) {
return const LoadingView(message: "Loading messages");
}


if (_error != null) {
  return ErrorView(message: _error!, onRetry: _loadMessages);
}

if (_messages.isEmpty) {
  return const EmptyView(message: "No messages");
}

return ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: _messages.length,
  itemBuilder: (context, index) {
    final message = _messages[index];

    final isAgent = message.senderType == "agent";

    return Align(
      alignment:
          isAgent ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        constraints: const BoxConstraints(maxWidth: 280),
        decoration: BoxDecoration(
          color:
              isAgent ? Colors.blue.shade50 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(message.body),
      ),
    );
  },
);

}
}

class _Composer extends StatelessWidget {
const _Composer({
required this.controller,
required this.onSend,
required this.canSend,
required this.sending,
});

final TextEditingController controller;
final VoidCallback onSend;
final bool canSend;
final bool sending;

@override
Widget build(BuildContext context) {
return SafeArea(
top: false,
child: Padding(
padding: const EdgeInsets.all(12),
child: Row(
children: [
Expanded(
child: TextField(
  controller: controller,
  readOnly: sending,
  decoration: const InputDecoration(
    hintText: "Type a reply...",
  ),
),
),
const SizedBox(width: 8),
IconButton(
onPressed: canSend && !sending ? onSend : null,
icon: sending
? const SizedBox(
width: 18,
height: 18,
child: CircularProgressIndicator(
strokeWidth: 2,
),
)
: Icon(
Icons.send,
color: canSend ? Colors.blue : Colors.grey,
),
),
],
),
),
);
}
}
