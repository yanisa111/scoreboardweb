import 'dart:math';
import 'package:flutter/material.dart';

// --- โครงสร้างข้อมูลแต่ละทีม ---
class TeamData {
  String id;
  String name;
  List<String> scores;
  Color color;

  TeamData({
    required this.id,
    required this.name,
    required this.scores,
    required this.color,
  });

  double get totalScore {
    double sum = 0.0;
    for (var score in scores) {
      final trimmed = score.trim();
      if (trimmed.isNotEmpty) {
        final value = double.tryParse(trimmed);
        if (value != null) sum += value;
      }
    }
    return sum;
  }
}

final List<Color> pastelColors = [
  Colors.pink.shade200,
  Colors.lightBlue.shade200,
  Colors.lightGreen.shade200,
  Colors.orange.shade200,
  Colors.purple.shade200,
  Colors.amber.shade200,
  Colors.cyan.shade200,
  Colors.lime.shade200,
  Colors.indigo.shade200,
  Colors.teal.shade200,
];

// === Widget กราฟแสดงผลคะแนน (ScoreGraphWidget) ===
class ScoreGraphWidget extends StatefulWidget {
  final List<TeamData> teams;
  final Decoration decoration;
  final Color textColor;
  final String? fontFamily;
  final double fontSizeScale; // 👈 เพิ่มการรองรับ Scale ฟอนต์

  const ScoreGraphWidget({
    super.key,
    required this.teams,
    required this.decoration,
    required this.textColor,
    this.fontFamily,
    this.fontSizeScale = 1.0, // 👈 ค่าเริ่มต้น 1.0
  });

  @override
  State<ScoreGraphWidget> createState() => _ScoreGraphWidgetState();
}

class _ScoreGraphWidgetState extends State<ScoreGraphWidget> {
  late final ScrollController _graphScrollController;

  @override
  void initState() {
    super.initState();
    _graphScrollController = ScrollController();
  }

  @override
  void dispose() {
    _graphScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? effectiveFont = widget.fontFamily == 'Default' ? null : widget.fontFamily;

    return DefaultTextStyle(
      style: TextStyle(
        fontFamily: effectiveFont,
        color: widget.textColor,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isMobile = constraints.maxWidth < 768;

          double dynamicPadding = isMobile ? 12.0 : 20.0;
          double dynamicMargin = isMobile ? 8.0 : 15.0;
          double graphHeight = isMobile ? 300.0 : 540.0;
          double barMaxHeight = isMobile ? 200.0 : 420.0;
          double barWidth = isMobile ? 25.0 : 40.0;

          double labelBoxWidth = barWidth + (isMobile ? 24.0 : 30.0);

          return Container(
            padding: EdgeInsets.only(
              top: dynamicPadding,
              left: dynamicPadding,
              right: dynamicPadding,
              bottom: 5,
            ),
            margin: EdgeInsets.all(dynamicMargin),
            decoration: widget.decoration,
            child: Column(
              children: [
                SizedBox(height: isMobile ? 15 : 30),
                LayoutBuilder(
                  builder: (context, innerConstraints) {
                    double availableWidth = innerConstraints.maxWidth - (dynamicPadding * 2);
                    double minSpacing = 70.0;

                    double minRequiredWidth = (labelBoxWidth * widget.teams.length) + (minSpacing * widget.teams.length);
                    double contentWidth = max(availableWidth, minRequiredWidth);

                    double maxScore = 0.0;
                    if (widget.teams.isNotEmpty) {
                      try {
                        maxScore = widget.teams.map((t) => t.totalScore).reduce(max);
                      } catch (_) {
                        maxScore = 0.0;
                      }
                    }
                    if (maxScore <= 0) maxScore = 1.0;

                    return SizedBox(
                      height: graphHeight,
                      child: widget.teams.isEmpty
                          ? Center(
                              child: Text(
                                "There is no information.",
                                style: TextStyle(
                                  color: widget.textColor.withValues(alpha: 0.5),
                                  fontSize: (isMobile ? 12 : 14) * widget.fontSizeScale,
                                  fontFamily: effectiveFont,
                                ),
                              ),
                            )
                          : Scrollbar(
                              controller: _graphScrollController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              thickness: isMobile ? 4.0 : 8.0,
                              radius: const Radius.circular(10),
                              child: SingleChildScrollView(
                                controller: _graphScrollController,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  width: contentWidth,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: widget.teams.map((team) {
                                      double currentScore = team.totalScore;
                                      if (currentScore < 0) currentScore = 0;

                                      double heightFactor = currentScore / maxScore;
                                      double targetHeight = max(heightFactor * barMaxHeight, 15.0);

                                      return SizedBox(
                                        width: labelBoxWidth,
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              team.totalScore.toStringAsFixed(0),
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: team.color.withValues(alpha: 0.8),
                                                fontSize: (isMobile ? 11 : 14) * widget.fontSizeScale,
                                                fontFamily: effectiveFont,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            AnimatedContainer(
                                              duration: const Duration(milliseconds: 900),
                                              curve: Curves.easeInOutBack,
                                              width: barWidth,
                                              height: targetHeight,
                                              decoration: BoxDecoration(
                                                color: team.color,
                                                borderRadius: BorderRadius.circular(isMobile ? 6 : 10),
                                              ),
                                            ),
                                            SizedBox(height: isMobile ? 6 : 12),
                                            Text(
                                              team.name,
                                              style: TextStyle(
                                                fontSize: (isMobile ? 12 : 15) * widget.fontSizeScale,
                                                fontWeight: FontWeight.w500,
                                                color: widget.textColor,
                                                fontFamily: effectiveFont,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// === Widget ตารางคะแนน (ScoreTableWidget) ===
class ScoreTableWidget extends StatefulWidget {
  final List<TeamData> teams;
  final int roundCount;
  final Decoration decoration;
  final Color textColor;
  final String? fontFamily;
  final double fontSizeScale; // 👈 เพิ่มการรองรับ Scale ฟอนต์
  final VoidCallback onUpdate;
  final VoidCallback onAddRound;
  final VoidCallback onDeleteRound;

  const ScoreTableWidget({
    super.key,
    required this.teams,
    required this.roundCount,
    required this.decoration,
    required this.textColor,
    this.fontFamily,
    this.fontSizeScale = 1.0, // 👈
    required this.onUpdate,
    required this.onAddRound,
    required this.onDeleteRound,
  });

  @override
  State<ScoreTableWidget> createState() => _ScoreTableWidgetState();
}

class _ScoreTableWidgetState extends State<ScoreTableWidget> {
  late final ScrollController _tableScrollController;

  @override
  void initState() {
    super.initState();
    _tableScrollController = ScrollController();
  }

  @override
  void dispose() {
    _tableScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? effectiveFont = widget.fontFamily == 'Default' ? null : widget.fontFamily;

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isMobile = constraints.maxWidth < 768;

        double dynamicPadding = isMobile ? 15.0 : 40.0;
        double dynamicMargin = isMobile ? 10.0 : 40.0;

        double availableTableWidth = constraints.maxWidth - (dynamicPadding * 2) - 100;
        double nameFieldWidth = isMobile ? max(availableTableWidth * 0.35, 90.0) : 200.0;
        double roundScoreWidth = isMobile ? 50.0 : 80.0;

        return Container(
          padding: EdgeInsets.all(dynamicPadding),
          margin: EdgeInsets.all(dynamicMargin),
          width: double.infinity,
          decoration: widget.decoration,
          child: Column(
            children: [
              widget.teams.isEmpty
                  ? Padding(
                      padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_rounded,
                            size: isMobile ? 35 : 50,
                            color: widget.textColor.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "There is no information about the team.",
                            style: TextStyle(
                              color: widget.textColor.withValues(alpha: 0.7),
                              fontSize: (isMobile ? 14 : 16) * widget.fontSizeScale,
                              fontWeight: FontWeight.w500,
                              fontFamily: effectiveFont,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Please click on the button below!",
                            style: TextStyle(
                              color: widget.textColor.withValues(alpha: 0.5),
                              fontSize: (isMobile ? 11 : 13) * widget.fontSizeScale,
                              fontFamily: effectiveFont,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Scrollbar(
                      controller: _tableScrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      thickness: isMobile ? 4.0 : 8.0,
                      radius: const Radius.circular(10),
                      child: SingleChildScrollView(
                        controller: _tableScrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Theme(
                            data: Theme.of(context).copyWith(
                              textTheme: Theme.of(context).textTheme.apply(
                                    fontFamily: effectiveFont,
                                    bodyColor: widget.textColor,
                                    displayColor: widget.textColor,
                                  ),
                            ),
                            child: DataTable(
                              columnSpacing: isMobile ? 12 : 20,
                              horizontalMargin: isMobile ? 5 : 24,
                              headingTextStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: widget.textColor,
                                fontSize: (isMobile ? 13 : 14) * widget.fontSizeScale,
                                fontFamily: effectiveFont,
                              ),
                              columns: [
                                const DataColumn(label: Text('Color')),
                                const DataColumn(label: Text('Team')),
                                for (int i = 0; i < widget.roundCount; i++)
                                  DataColumn(label: Text('Round ${i + 1}')),
                                const DataColumn(label: Text('Total')),
                                const DataColumn(label: Text('Action')),
                              ],
                              rows: List<DataRow>.generate(widget.teams.length, (index) {
                                final team = widget.teams[index];

                                return DataRow(
                                  key: ValueKey(team.id),
                                  cells: [
                                    DataCell(
                                      GestureDetector(
                                        onTap: () {
                                          int currentIndex = pastelColors.indexOf(team.color);
                                          int nextIndex = (currentIndex + 1) % pastelColors.length;
                                          team.color = pastelColors[nextIndex];
                                          widget.onUpdate();
                                        },
                                        child: Container(
                                          width: isMobile ? 20 : 25,
                                          height: isMobile ? 20 : 25,
                                          decoration: BoxDecoration(
                                            color: team.color,
                                            shape: BoxShape.circle,
                                            border: Border.all(color: Colors.white, width: 2),
                                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 2)],
                                          ),
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: nameFieldWidth,
                                        child: TextFormField(
                                          key: ValueKey('${team.id}_name'),
                                          initialValue: team.name,
                                          style: TextStyle(
                                            fontSize: (isMobile ? 13 : 14) * widget.fontSizeScale,
                                            color: widget.textColor,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: effectiveFont,
                                          ),
                                          decoration: const InputDecoration(
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                          onChanged: (value) {
                                            team.name = value;
                                            widget.onUpdate();
                                          },
                                        ),
                                      ),
                                    ),
                                    for (int i = 0; i < widget.roundCount; i++)
                                      DataCell(
                                        SizedBox(
                                          width: roundScoreWidth,
                                          child: TextFormField(
                                            key: ValueKey('${team.id}_score_$i'),
                                            initialValue: team.scores.length > i ? team.scores[i] : '',
                                            keyboardType: TextInputType.number,
                                            style: TextStyle(
                                              fontSize: (isMobile ? 13 : 14) * widget.fontSizeScale,
                                              color: widget.textColor,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: effectiveFont,
                                            ),
                                            decoration: InputDecoration(
                                              hintText: '0',
                                              hintStyle: TextStyle(
                                                color: widget.textColor.withValues(alpha: 0.3),
                                                fontFamily: effectiveFont,
                                              ),
                                              border: InputBorder.none,
                                              isDense: true,
                                            ),
                                            onChanged: (value) {
                                              while (team.scores.length <= i) {
                                                team.scores.add('');
                                              }
                                              team.scores[i] = value;
                                              widget.onUpdate();
                                            },
                                          ),
                                        ),
                                      ),
                                    DataCell(
                                      Text(
                                        team.totalScore % 1 == 0
                                            ? team.totalScore.toInt().toString()
                                            : team.totalScore.toStringAsFixed(1),
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: (isMobile ? 13 : 15) * widget.fontSizeScale,
                                          color: widget.textColor,
                                          fontFamily: effectiveFont,
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      SizedBox(
                                        width: isMobile ? 35 : 50,
                                        child: IconButton(
                                          icon: Icon(
                                            Icons.remove_circle,
                                            color: Colors.redAccent,
                                            size: isMobile ? 20 : 24,
                                          ),
                                          padding: EdgeInsets.zero,
                                          onPressed: () {
                                            widget.teams.removeAt(index);
                                            widget.onUpdate();
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                      ),
                    ),
              SizedBox(height: isMobile ? 15 : 25),
              Wrap(
                spacing: 15,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      final randomColor = pastelColors[Random().nextInt(pastelColors.length)];
                      widget.teams.add(
                        TeamData(
                          id: DateTime.now().microsecondsSinceEpoch.toString(),
                          name: 'Team ${widget.teams.length + 1}',
                          scores: List.filled(widget.roundCount, ''),
                          color: randomColor,
                        ),
                      );
                      widget.onUpdate();
                    },
                    icon: Icon(Icons.add, color: Colors.white, size: isMobile ? 18 : 24),
                    label: Text(
                      "Add New Team",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: (isMobile ? 13 : 14) * widget.fontSizeScale,
                        fontFamily: effectiveFont,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 144, 192, 255),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isMobile ? 10 : 15),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: isMobile ? 10 : 15,
                      ),
                      elevation: 0,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: widget.onAddRound,
                    icon: Icon(Icons.add_chart, color: Colors.white, size: isMobile ? 18 : 24),
                    label: Text(
                      "Add Round",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: (isMobile ? 13 : 14) * widget.fontSizeScale,
                        fontFamily: effectiveFont,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isMobile ? 10 : 15),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: isMobile ? 10 : 15,
                      ),
                      elevation: 0,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: widget.roundCount > 0 ? widget.onDeleteRound : null,
                    icon: Icon(Icons.delete_sweep, color: Colors.white, size: isMobile ? 18 : 24),
                    label: Text(
                      "Remove Round",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: (isMobile ? 13 : 14) * widget.fontSizeScale,
                        fontFamily: effectiveFont,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade300,
                      disabledBackgroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(isMobile ? 10 : 15),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 16 : 24,
                        vertical: isMobile ? 10 : 15,
                      ),
                      elevation: 0,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}