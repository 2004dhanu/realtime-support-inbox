import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../shared/widgets/empty_view.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_view.dart';

import '../../../core/realtime/realtime_service.dart';

import '../bloc/inbox_bloc.dart';
import '../data/inbox_api_repository.dart';
import '../realtime/inbox_realtime_adapter.dart';
import 'conversation_page.dart';
import '../../../core/realtime/ws_client.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  static const routeName = '/inbox';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => InboxBloc(
        repository: InboxApiRepository(),
      )..add(const LoadInbox()),
      child: const _InboxView(),
    );
  }
}

class _InboxView extends StatefulWidget {
  const _InboxView();

  @override
  State<_InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<_InboxView> {
  late final InboxRealtimeAdapter realtimeAdapter;
  final RealtimeService realtimeService = WsClient();

  @override
  void initState() {
    super.initState();

    final bloc = context.read<InboxBloc>();

    realtimeAdapter = InboxRealtimeAdapter(
      realtimeService: realtimeService,
      inboxBloc: bloc,
    );

    // Start websocket connection
    realtimeAdapter.start("dev-token");
  }

  @override
  void dispose() {
    realtimeAdapter.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support Inbox'),
        actions: [
          IconButton(
            onPressed: () =>
                context.read<InboxBloc>().add(const RefreshInbox()),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => Get.toNamed('/debug'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        children: [
          _ConnectionBanner(realtimeService: realtimeService),
          _FilterRow(),
          Expanded(
            child: BlocBuilder<InboxBloc, InboxState>(
              builder: (context, state) {
                if (state.status == InboxStatus.loading) {
                  return const LoadingView(message: 'Loading conversations');
                }

                if (state.status == InboxStatus.failure) {
                  return ErrorView(
                      message: state.errorMessage ?? 'Failed to load');
                }

                if (state.items.isEmpty) {
                  return const EmptyView(message: 'No conversations');
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final convo = state.items[index];

                    return GestureDetector(
                      onTap: () => Get.toNamed(
  ConversationPage.routeName,
  arguments: {
    "id": convo.id,
    "status": convo.status,
  },
),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      convo.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
                                    ),
                                  ),
                                  Text(
                                      DateFormat.Hm().format(convo.lastMessageAt)),
                                ],
                              ),

                              const SizedBox(height: 6),

                             convo.isTyping
    ? const Text(
        "Agent typing...",
        style: TextStyle(
          color: Colors.orange,
          fontStyle: FontStyle.italic,
        ),
      )
    : Text(
        convo.lastMessagePreview,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),


                              const SizedBox(height: 8),

                            Row(
  children: [
    _StatusChip(label: convo.status),
    const SizedBox(width: 6),

    _PriorityBadge(priority: convo.priority),

    const Spacer(),

    if (convo.unreadCount > 0)
      _UnreadBadge(count: convo.unreadCount),
  ],
),

                              const SizedBox(height: 4),

                            Row(
  children: [
    Text('Assignee: ${convo.assignee ?? "Unassigned"}'),

    if (convo.presenceState != null) ...[
      const SizedBox(width: 6),

      Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: convo.presenceState == "online"
              ? Colors.green
              : Colors.orange,
          shape: BoxShape.circle,
        ),
      ),

      const SizedBox(width: 4),

      Text(
        convo.presenceState!,
        style: TextStyle(
          fontSize: 12,
          color: convo.presenceState == "online"
              ? Colors.green
              : Colors.orange,
        ),
      ),
    ]
  ],
)

                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    final filter = context.select((InboxBloc bloc) => bloc.state.filterStatus);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          FilterChip(
            label: const Text('Open'),
            selected: filter == 'open',
            onSelected: (_) =>
                context.read<InboxBloc>().add(const SetInboxFilter('open')),
          ),
          const SizedBox(width: 8),

          FilterChip(
            label: const Text('Pending'),
            selected: filter == 'pending',
            onSelected: (_) =>
                context.read<InboxBloc>().add(const SetInboxFilter('pending')),
          ),
          const SizedBox(width: 8),

          FilterChip(
            label: const Text('Closed'),
            selected: filter == 'closed',
            onSelected: (_) =>
                context.read<InboxBloc>().add(const SetInboxFilter('closed')),
          ),
        ],
      ),
    );
  }
}

class _ConnectionBanner extends StatefulWidget {
  const _ConnectionBanner({required this.realtimeService});

  final RealtimeService realtimeService;

  @override
  State<_ConnectionBanner> createState() => _ConnectionBannerState();
}

class _ConnectionBannerState extends State<_ConnectionBanner> {
  late bool _connected;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    _connected = widget.realtimeService.isConnected;
    _sub = widget.realtimeService.connectionStream.listen((value) {
      setState(() => _connected = value);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
@override
Widget build(BuildContext context) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: double.infinity,
    color: _connected ? Colors.green.shade100 : Colors.red.shade100,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Row(
      children: [
        Icon(
          _connected ? Icons.wifi : Icons.wifi_off,
          color: _connected ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          _connected
              ? "Realtime Connected"
              : "Realtime Disconnected (Reconnecting...)",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  Color get _color {
    switch (label) {
      case 'open':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.blueGrey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}


class _UnreadBadge extends StatelessWidget {
  const _UnreadBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.redAccent,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$count new',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.priority});

  final String priority;

  Color get _color {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        priority.toUpperCase(),
        style: TextStyle(
          color: _color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
