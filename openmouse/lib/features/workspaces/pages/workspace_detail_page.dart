import 'package:flutter/material.dart';

import '../../../models/workspace.dart';
import '../../documents/pages/documents_page.dart';

class WorkspaceDetailPage extends StatefulWidget {
  const WorkspaceDetailPage({super.key, required this.workspace});

  final Workspace workspace;

  @override
  State<WorkspaceDetailPage> createState() => _WorkspaceDetailPageState();
}

class _WorkspaceDetailPageState extends State<WorkspaceDetailPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _PlaceholderTab(title: 'Neuigkeiten'),
      DocumentsPage(workspaceId: widget.workspace.id),
      const _PlaceholderTab(title: 'Aktuelle Arbeit'),
      const _PlaceholderTab(title: 'Dispo'),
      const _PlaceholderTab(title: 'Baujournal'),
      const _PlaceholderTab(title: 'Team'),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.workspace.projektname),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Neuigkeiten'),
              Tab(text: 'Dokumentenablage'),
              Tab(text: 'Aktuelle Arbeit'),
              Tab(text: 'Dispo'),
              Tab(text: 'Baujournal'),
              Tab(text: 'Team'),
            ],
          ),
        ),
        body: TabBarView(children: tabs),
      ),
    );
  }
}

class _PlaceholderTab extends StatelessWidget {
  const _PlaceholderTab({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text(title));
  }
}
