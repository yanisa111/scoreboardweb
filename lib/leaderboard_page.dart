import 'dart:math';
import 'package:flutter/material.dart';
import 'graph.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: LeaderboardContent());
  }
}

class LeaderboardContent extends StatefulWidget {
  final String? mainBackgroundPath;
  final String? customBackgroundUrl;
  final Decoration? cardDecoration;
  final Color? textColor;
  final String? fontFamily;
  final double fontSizeScale;

  const LeaderboardContent({
    super.key,
    this.mainBackgroundPath,
    this.customBackgroundUrl,
    this.cardDecoration,
    this.textColor,
    this.fontFamily,
    this.fontSizeScale = 1.0,
  });

  @override
  State<LeaderboardContent> createState() => _LeaderboardContentState();
}

class _LeaderboardContentState extends State<LeaderboardContent> {
  String pageTitle = "LEADERBOARD SCOREBOARD";
  final TextEditingController _titleController = TextEditingController();
  bool _isEditingTitle = false;

  final ScrollController _roundsScrollController = ScrollController();

  int roundCount = 5;
  List<TeamData> teams = [
    TeamData(
      id: '1',
      name: 'Team Alpha',
      scores: ['1', '0', '1', '1', '0'],
      color: Colors.blueAccent,
    ),
    TeamData(
      id: '2',
      name: 'Team Beta',
      scores: ['0', '1', '1', '0', '1'],
      color: Colors.orangeAccent,
    ),
    TeamData(
      id: '3',
      name: 'Team Gamma',
      scores: ['1', '1', '1', '1', '1'],
      color: Colors.greenAccent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _titleController.text = pageTitle;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _roundsScrollController.dispose();
    super.dispose();
  }

  double get maxTotalScore {
    if (teams.isEmpty) return 1.0;
    double maxScore = teams.map((t) => t.totalScore).fold(0.0, max);
    return maxScore == 0 ? 1.0 : maxScore;
  }

  void _addTeam() {
    setState(() {
      teams.add(
        TeamData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: 'Team ${teams.length + 1}',
          scores: List.generate(roundCount, (_) => '0'),
          color: pastelColors[teams.length % pastelColors.length],
        ),
      );
    });
  }

  void _removeTeam(String id) {
    setState(() {
      teams.removeWhere((team) => team.id == id);
    });
  }

  void _addRound() {
    setState(() {
      roundCount++;
      for (var team in teams) {
        team.scores.add('0');
      }
    });
  }

  void _deleteRound() {
    if (roundCount > 1) {
      setState(() {
        roundCount--;
        for (var team in teams) {
          if (team.scores.isNotEmpty) {
            team.scores.removeLast();
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Color contentTextColor = widget.textColor ?? Colors.black87;
    Decoration activeDecoration =
        widget.cardDecoration ??
        BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        );

    String? font = (widget.fontFamily == null || widget.fontFamily == 'Default')
        ? null
        : widget.fontFamily;

    return Stack(
      children: [
        Positioned.fill(
          child: widget.customBackgroundUrl != null
              ? Image.network(widget.customBackgroundUrl!, fit: BoxFit.cover)
              : (widget.mainBackgroundPath != null
                    ? Image.asset(widget.mainBackgroundPath!, fit: BoxFit.cover)
                    : Container(color: const Color(0xFFF8F5FB))),
        ),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => IconButton(
                        icon: const Icon(
                          Icons.menu,
                          color: Colors.black87,
                          size: 30,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              _buildEditableHeaderTitle(font),
              const SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: activeDecoration,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildTeamColumn(teams, contentTextColor, font),
                            Flexible(
                              fit: FlexFit.loose,
                              child: Scrollbar(
                                controller: _roundsScrollController,
                                thumbVisibility: true,
                                thickness: 8.0,
                                radius: const Radius.circular(4),
                                child: SingleChildScrollView(
                                  controller: _roundsScrollController,
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      _buildRoundsColumn(
                                        teams,
                                        contentTextColor,
                                        font,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _buildStatsColumn(teams, contentTextColor, font),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditableHeaderTitle(String? font) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black45,
        borderRadius: BorderRadius.circular(30),
      ),
      child: _isEditingTitle
          ? IntrinsicWidth(
              child: TextField(
                controller: _titleController,
                autofocus: true,
                style: TextStyle(
                  fontSize: 20 * widget.fontSizeScale,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontFamily: font,
                ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (val) {
                  setState(() {
                    pageTitle = val;
                    _isEditingTitle = false;
                  });
                },
              ),
            )
          : InkWell(
              onTap: () => setState(() => _isEditingTitle = true),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    pageTitle,
                    style: TextStyle(
                      fontSize: 20 * widget.fontSizeScale,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: font,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, color: Colors.white70, size: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildTeamColumn(
    List<TeamData> displayTeams,
    Color textColor,
    String? font,
  ) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45,
            alignment: Alignment.centerLeft,
            child: Text(
              'Team',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16 * widget.fontSizeScale,
                color: textColor,
                fontFamily: font,
              ),
            ),
          ),
          Divider(height: 1, color: textColor.withValues(alpha: 0.3)),
          ...displayTeams.map(
            (team) => Container(
              height: 52,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  InkWell(
                    onTap: () => _removeTeam(team.id),
                    child: const Icon(
                      Icons.remove_circle,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: TextFormField(
                      initialValue: team.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14 * widget.fontSizeScale,
                        color: textColor,
                        fontFamily: font,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        isDense: true,
                      ),
                      onChanged: (val) => team.name = val,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundsColumn(
    List<TeamData> displayTeams,
    Color textColor,
    String? font,
  ) {
    const double columnWidth = 70.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 45,
          child: Row(
            children: List.generate(
              roundCount,
              (index) => Container(
                width: columnWidth,
                alignment: Alignment.center,
                child: Text(
                  'Round ${index + 1}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontSize: 13 * widget.fontSizeScale,
                    fontFamily: font,
                  ),
                ),
              ),
            ),
          ),
        ),
        Divider(height: 1, color: textColor.withValues(alpha: 0.3)),
        ...displayTeams.map((team) {
          while (team.scores.length < roundCount) {
            team.scores.add('0');
          }
          return SizedBox(
            height: 52,
            child: Row(
              children: List.generate(roundCount, (rIndex) {
                return Container(
                  width: columnWidth,
                  height: 52,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 3,
                  ),
                  child: TextFormField(
                    key: ValueKey('${team.id}_$rIndex'),
                    initialValue: team.scores[rIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14 * widget.fontSizeScale,
                      fontFamily: font,
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: textColor.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.indigo),
                      ),
                    ),
                    onChanged: (val) {
                      setState(() {
                        team.scores[rIndex] = val;
                      });
                    },
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsColumn(
    List<TeamData> displayTeams,
    Color textColor,
    String? font,
  ) {
    List<TeamData> sortedForRank = List.from(displayTeams);
    sortedForRank.sort((a, b) => b.totalScore.compareTo(a.totalScore));

    return Column(
      children: [
        Container(
          height: 45,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          alignment: Alignment.center,
          child: Row(
            children: [
              SizedBox(
                width: 50,
                child: Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: font,
                    fontSize: 13 * widget.fontSizeScale,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 180,
                child: Text(
                  'Graph',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: font,
                    fontSize: 13 * widget.fontSizeScale,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  'Rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: font,
                    fontSize: 13 * widget.fontSizeScale,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: textColor.withValues(alpha: 0.3)),
        ...displayTeams.map((team) {
          int rank = sortedForRank.indexOf(team) + 1;
          double scoreRatio = (team.totalScore / maxTotalScore).clamp(0.0, 1.0);

          return Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 45,
                  child: Text(
                    team.totalScore.toStringAsFixed(
                      team.totalScore % 1 == 0 ? 0 : 1,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      fontSize: 16 * widget.fontSizeScale,
                      fontFamily: font,
                    ),
                  ),
                ),
                SizedBox(
                  width: 160,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Stack(
                      children: [
                        Container(
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.centerLeft,
                          widthFactor: scoreRatio,
                          child: Container(
                            height: 16,
                            decoration: BoxDecoration(
                              color: team.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: rank == 1
                        ? Colors.amber
                        : (rank == 2
                              ? Colors.grey.shade400
                              : (rank == 3
                                    ? Colors.brown.shade300
                                    : Colors.blueGrey.shade100)),
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 11 * widget.fontSizeScale,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: font,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceEvenly, // แก้จาก mainSpaceEvenly เป็น mainAxisAlignment
        children: [
          ElevatedButton.icon(
            onPressed: _addTeam,
            icon: const Icon(Icons.group_add, size: 18),
            label: const Text('Add Team'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _addRound,
            icon: const Icon(Icons.add_circle, size: 18),
            label: const Text('Add Round'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
          ),
          ElevatedButton.icon(
            onPressed: _deleteRound,
            icon: const Icon(Icons.remove_circle, size: 18),
            label: const Text('Delete Round'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
