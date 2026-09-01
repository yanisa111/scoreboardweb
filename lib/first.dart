import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'graph.dart';
import 'leaderboard_page.dart';
import 'app_drawer.dart';

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

  StreamSubscription<html.StorageEvent>? _storageSubscription;
  StreamSubscription<html.MessageEvent>? _messageSubscription;

  // --- Background State ---
  final List<String> mainBackgrounds = List.generate(
    17,
    (index) => 'bg/${index + 1}.jpg',
  );
  List<String> customBackgrounds = [];
  int currentMainBgIndex = 0;
  int currentCustomBgIndex = -1;
  bool isCustomBgSelected = false;

  // --- Container Theme State ---
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
  bool isCustomThemeSelected = false;
  Color customContainerColor = Colors.white;
  Color customTextColor = Colors.black87;

  // --- Font Customization State ---
  String selectedFontFamily = 'Default';
  double fontSizeScale = 1.0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialIndex;
    _loadTeamsFromStorage();

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
    _storageSubscription?.cancel();
    _messageSubscription?.cancel();
    super.dispose();
  }

  // ฟังก์ชั่นอัปโหลดรูปภาพพื้นหลัง
  void _uploadBackgroundFile() {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files != null && files.isNotEmpty) {
        final file = files[0];
        final reader = html.FileReader();
        reader.readAsDataUrl(file);
        reader.onLoadEnd.listen((e) {
          if (reader.result != null) {
            setState(() {
              customBackgrounds.add(reader.result as String);
              isCustomBgSelected = true;
              currentCustomBgIndex = customBackgrounds.length - 1;
            });
          }
        });
      }
    });
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
    // การเลือก Theme และ สีตัวอักษร
    Decoration currentDecoration;
    Color contentTextColor;

    if (isCustomThemeSelected) {
      currentDecoration = BoxDecoration(
        color: customContainerColor,
        borderRadius: BorderRadius.circular(20),
      );
      contentTextColor = customTextColor;
    } else {
      currentDecoration = cardDecorations[currentCardBgIndex];
      bool isDarkCard = currentCardBgIndex == 2;
      contentTextColor = isDarkCard ? Colors.white : Colors.black87;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 600;
    final bool isTablet = screenWidth >= 600 && screenWidth < 1024;
    final bool isDesktop = screenWidth >= 1024;

    // เลือกใช้ Font Style ที่กำหนด
    TextStyle baseTextStyle = TextStyle(
      fontFamily: selectedFontFamily == 'Default' ? null : selectedFontFamily,
    );

    // หน้า Leaderboard Page (index 4)
    if (selectedIndex == 4) {
      return Scaffold(
        drawer: _buildAppDrawer(),
        body: LeaderboardContent(
          mainBackgroundPath: !isCustomBgSelected ? mainBackgrounds[currentMainBgIndex] : null,
          customBackgroundUrl: isCustomBgSelected ? customBackgrounds[currentCustomBgIndex] : null,
          cardDecoration: currentDecoration,
          textColor: contentTextColor,
          fontFamily: selectedFontFamily,
          fontSizeScale: fontSizeScale,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Scoreboard Studio",
          style: baseTextStyle.copyWith(fontWeight: FontWeight.bold, fontSize: 18 * fontSizeScale),
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
              label: Text("Open Graph View ↗️", style: baseTextStyle),
              onPressed: _openGraphView,
            ),
          const SizedBox(width: 10),
        ],
      ),
      drawer: _buildAppDrawer(),
      body: Stack(
        children: [
          // พื้นหลัง
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: ValueKey<String>(isCustomBgSelected ? customBackgrounds[currentCustomBgIndex] : mainBackgrounds[currentMainBgIndex]),
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: isCustomBgSelected
                      ? NetworkImage(customBackgrounds[currentCustomBgIndex]) as ImageProvider
                      : AssetImage(mainBackgrounds[currentMainBgIndex]),
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
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            textTheme: Theme.of(context).textTheme.apply(
                                  fontFamily: selectedFontFamily == 'Default' ? null : selectedFontFamily,
                                ),
                          ),
                          child: _buildMainContent(
                            isDesktop: isDesktop,
                            textColor: contentTextColor,
                            decoration: currentDecoration,
                          ),
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

  AppDrawer _buildAppDrawer() {
    return AppDrawer(
      selectedIndex: selectedIndex,
      onSelectIndex: (idx) => setState(() => selectedIndex = idx),
      mainBackgrounds: mainBackgrounds,
      customBackgrounds: customBackgrounds,
      currentMainBgIndex: currentMainBgIndex,
      isCustomBgSelected: isCustomBgSelected,
      currentCustomBgIndex: currentCustomBgIndex,
      onSelectMainBg: (idx) => setState(() {
        isCustomBgSelected = false;
        currentMainBgIndex = idx;
      }),
      onSelectCustomBg: (idx) => setState(() {
        isCustomBgSelected = true;
        currentCustomBgIndex = idx;
      }),
      onUploadBackground: _uploadBackgroundFile,
      cardDecorations: cardDecorations,
      onDeleteCustomBg: (idx) => setState(() {
        if (idx >= 0 && idx < customBackgrounds.length) {
          customBackgrounds.removeAt(idx);
          if (customBackgrounds.isEmpty) {
            isCustomBgSelected = false;
            currentCustomBgIndex = -1;
          } else if (currentCustomBgIndex >= customBackgrounds.length) {
            currentCustomBgIndex = customBackgrounds.length - 1;
          }
        }
      }),
      currentCardBgIndex: currentCardBgIndex,
      onSelectCardBg: (idx) => setState(() {
        isCustomThemeSelected = false;
        currentCardBgIndex = idx;
      }),
      customContainerColor: customContainerColor,
      customTextColor: customTextColor,
      isCustomThemeSelected: isCustomThemeSelected,
      onCustomThemeChanged: (containerCol, textCol) {
        setState(() {
          isCustomThemeSelected = true;
          customContainerColor = containerCol;
          customTextColor = textCol;
        });
      },
      selectedFontFamily: selectedFontFamily,
      fontSizeScale: fontSizeScale,
      onFontFamilyChanged: (font) => setState(() => selectedFontFamily = font),
      onFontSizeScaleChanged: (scale) => setState(() => fontSizeScale = scale),
    );
  }

Widget _buildMainContent({
    required bool isDesktop,
    required Color textColor,
    required Decoration decoration,
  }) {
    // 🟢 แก้ไขจุดที่ 1: เปลี่ยนจาก graph(...) เป็นชื่อ Widget Class ใน graph.dart (เช่น ScoreGraphWidget หรือ ScoreGraph)
    Widget graphWidget = ScoreGraphWidget(
      teams: teams,
      decoration: decoration,
      textColor: textColor,
      fontSizeScale: fontSizeScale
      
    );

    // 🟢 แก้ไขจุดที่ 2: เปลี่ยนจาก score(...) เป็นชื่อ Widget Class ใน graph.dart (เช่น ScoreTableWidget หรือ ScoreTable)
    Widget scoreWidget = ScoreTableWidget(
      teams: teams,
      roundCount: roundCount,
      decoration: decoration,
      textColor: textColor,
      onUpdate: updateState,
      onAddRound: _addNewRound,
      onDeleteRound: handleRemoveRound,
      fontSizeScale: fontSizeScale
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
}