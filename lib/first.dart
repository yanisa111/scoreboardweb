import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'graph.dart';
import 'leaderboard_page.dart';

class First extends StatefulWidget {
  final int initialIndex;

  const First({super.key, this.initialIndex = 0});

  @override
  State<First> createState() => _FirstState();
}

class _FirstState extends State<First> {
  List<TeamData> teams = [];
  int roundCount = 1;
  int selectedIndex = 0;

  // Stream Subscriptions สำหรับจัดการยกเลิก Listener ใน dispose()
  StreamSubscription<html.StorageEvent>? _storageSubscription;
  StreamSubscription<html.MessageEvent>? _messageSubscription;

  final List<String> mainBackgrounds = List.generate(
    17,
    (index) => 'bg/${index + 1}.jpg',
  );
  int currentMainBgIndex = 0;

  final List<Decoration> cardDecorations = [
    BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(255, 181, 203, 255),
          Color.fromARGB(255, 248, 215, 226),
          Color.fromARGB(255, 246, 248, 215),
        ],
      ),
    ),
    BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color.fromARGB(255, 86, 96, 110), Color(0xFF111827)],
      ),
    ),
    BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.fromARGB(255, 182, 204, 255),
          Color.fromARGB(255, 255, 255, 255),
        ],
      ),
    ),
  ];
  int currentCardBgIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex; // กำหนดค่าเริ่มต้นตามที่ส่งมาจาก Drawer
    _loadTeamsFromStorage();

    // ดักฟังเหตุการณ์การแก้ไขข้อมูลข้ามแท็บ
    _storageSubscription = html.window.onStorage.listen((html.StorageEvent event) {
      if (event.key == 'scoreboard_teams_data' && event.newValue != null) {
        _parseAndStoreTeams(event.newValue!);
      }
    });

    _messageSubscription = html.window.onMessage.listen((event) {
      try {
        final data = jsonDecode(event.data);
        if (data['action'] == 'update_teams') {
          if (!mounted) return;
          setState(() {
            if (data['roundCount'] != null) {
              roundCount = data['roundCount'];
            }
            _updateTeamsFromList(data['teams']);
          });
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    // ป้องกัน Memory Leak
    _storageSubscription?.cancel();
    _messageSubscription?.cancel();
    super.dispose();
  }

  void _loadTeamsFromStorage() {
    final savedData = html.window.localStorage['scoreboard_teams_data'];
    if (savedData != null) {
      _parseAndStoreTeams(savedData);
    }
  }

  void _parseAndStoreTeams(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (!mounted) return;
      setState(() {
        if (decoded is Map<String, dynamic>) {
          if (decoded['roundCount'] != null) {
            roundCount = decoded['roundCount'];
          }
          if (decoded['teams'] is List) {
            _updateTeamsFromList(decoded['teams']);
          }
        } else if (decoded is List) {
          _updateTeamsFromList(decoded);
        }
      });
    } catch (_) {}
  }

  void _updateTeamsFromList(List<dynamic> remoteTeams) {
    int maxRoundsFound = roundCount;

    for (var i = 0; i < teams.length; i++) {
      if (i < remoteTeams.length) {
        teams[i].name = remoteTeams[i]['name'] ?? teams[i].name;

        if (remoteTeams[i]['scores'] != null) {
          teams[i].scores = List<String>.from(
            (remoteTeams[i]['scores'] as List).map((e) => e.toString()),
          );
        } else if (remoteTeams[i]['scoreInput'] != null) {
          teams[i].scores = (remoteTeams[i]['scoreInput'] as String).split(',');
        }

        if (teams[i].scores.length > maxRoundsFound) {
          maxRoundsFound = teams[i].scores.length;
        }

        if (remoteTeams[i]['color'] != null) {
          teams[i].color = Color(remoteTeams[i]['color']);
        }
      }
    }

    if (remoteTeams.length > teams.length) {
      for (var i = teams.length; i < remoteTeams.length; i++) {
        List<String> parsedScores = [];
        if (remoteTeams[i]['scores'] != null) {
          parsedScores = List<String>.from(
            (remoteTeams[i]['scores'] as List).map((e) => e.toString()),
          );
        } else if (remoteTeams[i]['scoreInput'] != null) {
          parsedScores = (remoteTeams[i]['scoreInput'] as String).split(',');
        }

        if (parsedScores.length > maxRoundsFound) {
          maxRoundsFound = parsedScores.length;
        }

        teams.add(
          TeamData(
            id: remoteTeams[i]['id']?.toString() ?? i.toString(),
            name: remoteTeams[i]['name'] ?? 'Team ${i + 1}',
            scores: parsedScores,
            color: Color(
              remoteTeams[i]['color'] ?? Colors.blue.shade300.toARGB32(),
            ),
          ),
        );
      }
    }

    if (maxRoundsFound > roundCount) {
      roundCount = maxRoundsFound;
    }
  }

  Map<String, dynamic> _serializeData() {
    return {
      'roundCount': roundCount,
      'teams': teams
          .map(
            (t) => {
              'id': t.id,
              'name': t.name,
              'scores': t.scores,
              'color': t.color.toARGB32(),
            },
          )
          .toList(),
    };
  }

  void handleRemoveRound() {
    if (roundCount > 0) {
      setState(() {
        roundCount--;
        for (var team in teams) {
          if (team.scores.length > roundCount) {
            team.scores.removeLast();
          }
        }
      });
      updateState();
    }
  }

  void updateState() {
    if (mounted) setState(() {});

    final payload = _serializeData();
    final encodedData = jsonEncode(payload);

    html.window.localStorage['scoreboard_teams_data'] = encodedData;
    html.window.opener?.postMessage(
      jsonEncode({
        'action': 'update_teams',
        'roundCount': roundCount,
        'teams': payload['teams'],
      }),
      '*',
    );
  }

  void _openGraphView() {
    html.window.localStorage['scoreboard_teams_data'] = jsonEncode(
      _serializeData(),
    );
    html.window.open(html.window.location.href, '_blank');
  }

  void _addNewRound() {
    setState(() {
      roundCount++;
    });
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkCard = currentCardBgIndex == 2;
    Color contentTextColor = isDarkCard ? Colors.white : Colors.black87;

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Scoreboard Studio",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.5),
        elevation: 0,
        foregroundColor: Colors.black87,
        actions: [
          if (isMobile)
            IconButton(
              icon: const Icon(Icons.open_in_new_rounded),
              tooltip: "Open Graph View",
              onPressed: _openGraphView,
            )
          else
            TextButton.icon(
              icon: const Icon(Icons.open_in_new_rounded, size: 18),
              label: const Text("Open Graph View ↗️"),
              onPressed: _openGraphView,
            ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: _buildDrawer(),
      body: Stack(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey<int>(currentMainBgIndex),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(mainBackgrounds[currentMainBgIndex]),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 12 : (isTablet ? 24 : 40),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1500),
                        child: _buildMainContent(
                          isDesktop: isDesktop,
                          textColor: contentTextColor,
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent({required bool isDesktop, required Color textColor}) {
    final currentDecoration = cardDecorations[currentCardBgIndex];

    Widget graphWidget = graph(
      teams: teams,
      decoration: currentDecoration,
      textColor: textColor,
    );

    Widget scoreWidget = score(
      teams: teams,
      roundCount: roundCount,
      decoration: currentDecoration,
      textColor: textColor,
      onUpdate: updateState,
      onAddRound: _addNewRound,
      onDeleteRound: handleRemoveRound,
    );

    switch (selectedIndex) {
      case 1:
        return graphWidget;
      case 2:
        return scoreWidget;
      case 3:
        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: scoreWidget),
              const SizedBox(width: 20),
              Expanded(child: graphWidget),
            ],
          );
        }
        return Column(
          children: [
            scoreWidget,
            const SizedBox(height: 20),
            graphWidget,
          ],
        );
      case 0:
      default:
        return Column(
          children: [
            graphWidget,
            const SizedBox(height: 10),
            scoreWidget,
          ],
        );
    }
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 97, 151, 222),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.live_tv_rounded, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  "Studio Control Screen",
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 5),
            child: Text(
              "VIEW MODES",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard_rounded),
            title: const Text("Default (Dual View)"),
            selected: selectedIndex == 0,
            onTap: () {
              setState(() => selectedIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded, color: Colors.redAccent),
            title: const Text("🔴 Graph View Only (Live)"),
            selected: selectedIndex == 1,
            onTap: () {
              setState(() => selectedIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.table_rows_rounded, color: Colors.blueAccent),
            title: const Text("Score Table Only (Backend)"),
            selected: selectedIndex == 2,
            onTap: () {
              setState(() => selectedIndex = 2);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.splitscreen_rounded, color: Colors.purpleAccent),
            title: const Text("Dual Monitor Mode"),
            selected: selectedIndex == 3,
            onTap: () {
              setState(() => selectedIndex = 3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.leaderboard),
            title: const Text('เปิดหน้า Leaderboard Graph'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LeaderboardPage()),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 8),
            child: Text(
              "WEBSITE BACKGROUND",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(mainBackgrounds.length, (index) {
                bool isSelected = currentMainBgIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => currentMainBgIndex = index),
                  child: Container(
                    width: 78,
                    height: 55,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? const Color.fromARGB(255, 97, 151, 222)
                            : Colors.grey.shade300,
                        width: isSelected ? 3 : 1,
                      ),
                      image: DecorationImage(
                        image: AssetImage(mainBackgrounds[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: isSelected
                        ? const Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 20,
                            ),
                          )
                        : null,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 8),
            child: Text(
              "GRAPH/TABLE CONTAINER THEME",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
            child: Wrap(
              spacing: 12,
              runSpacing: 10,
              children: List.generate(cardDecorations.length, (index) {
                bool isSelected = currentCardBgIndex == index;
                return GestureDetector(
                  onTap: () => setState(() => currentCardBgIndex = index),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: cardDecorations[index],
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color.fromARGB(255, 97, 151, 222)
                              : Colors.grey.shade400,
                          width: isSelected ? 3 : 1,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Icon(
                                Icons.check_circle,
                                color: index == 2 ? Colors.white : Colors.black87,
                                size: 18,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}