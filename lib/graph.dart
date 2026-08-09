import 'package:flutter/material.dart';
import 'dart:math';

// --- โครงสร้างข้อมูลสำหรับแต่ละทีม ---
class TeamData {
  String id;
  String name;
  List<String> scores; // 🎯 ปรับให้ตรงกับฟังก์ชัน score ที่ใช้งานแบบ List
  Color color;

  TeamData({
    required this.id,
    required this.name,
    required this.scores,
    required this.color,
  });

  // คำนวณผลรวมคะแนนจาก List<String> scores
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

// === ฟังก์ชันแยก: ส่วนแสดงกราฟอนิเมชั่น ===
Widget graph({
  required List<TeamData> teams,
  required Decoration decoration,
  required Color textColor,
}) {
  final ScrollController graphScrollController = ScrollController();

  return LayoutBuilder(
    builder: (context, constraints) {
      bool isMobile = constraints.maxWidth < 768;
      
      double dynamicPadding = isMobile ? 12.0 : 20.0;
      double dynamicMargin = isMobile ? 8.0 : 15.0;
      double graphHeight = isMobile ? 300.0 : 540.0;
      double barMaxHeight = isMobile ? 200.0 : 420.0;
      double barWidth = isMobile ? 25.0 : 40.0;

      // 🎯 ความกว้างของบล็อกข้อความ/ชื่อทีม
      double labelBoxWidth = barWidth + (isMobile ? 24.0 : 30.0);

      return Container(
        padding: EdgeInsets.only(top: dynamicPadding, left: dynamicPadding, right: dynamicPadding, bottom: 5),
        margin: EdgeInsets.all(dynamicMargin),
        decoration: decoration,
        child: Column(
          children: [
            Text(
              "📊 Scoreboard",
              style: TextStyle(
                fontSize: isMobile ? 16 : 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            SizedBox(height: isMobile ? 15 : 30),

            LayoutBuilder(
              builder: (context, innerConstraints) {
                double availableWidth = innerConstraints.maxWidth - (dynamicPadding * 2);
                
                double minSpacing = 70.0; 
                
                double minRequiredWidth = (labelBoxWidth * teams.length) + (minSpacing * teams.length);
                double contentWidth = max(availableWidth, minRequiredWidth);

                double maxScore = 0.0;
                if (teams.isNotEmpty) {
                  try {
                    maxScore = teams.map((t) => t.totalScore).reduce(max);
                  } catch (_) {
                    maxScore = 0.0;
                  }
                }
                if (maxScore <= 0) maxScore = 1.0;

                return SizedBox(
                  height: graphHeight,
                  child: teams.isEmpty
                      ? Center(
                          child: Text(
                            "There is no information.",
                            style: TextStyle(
                              color: textColor.withValues(alpha: 0.5),
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        )
                      : Scrollbar(
                          controller: graphScrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: isMobile ? 4.0 : 8.0,
                          radius: const Radius.circular(10),
                          child: SingleChildScrollView(
                            controller: graphScrollController,
                            scrollDirection: Axis.horizontal,
                            physics: const BouncingScrollPhysics(),
                            child: Container(
                              padding: const EdgeInsets.only(bottom: 20),
                              width: contentWidth, 
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: teams.map((team) {
                                  double currentScore = team.totalScore;
                                  if (currentScore < 0) currentScore = 0;

                                  double heightFactor = currentScore / maxScore;
                                  double targetHeight = max(
                                    heightFactor * barMaxHeight,
                                    15.0,
                                  );

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
                                            fontSize: isMobile ? 11 : 14,
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
                                            fontSize: isMobile ? 12 : 15,
                                            fontWeight: FontWeight.w500,
                                            color: textColor,
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
  );
}

// === ฟังก์ชันแยก: ส่วนกรอกตารางคะแนน ===
// === ฟังก์ชันแยก: ส่วนกรอกตารางคะแนน ===
Widget score({
  required List<TeamData> teams,
  required int roundCount,
  required Decoration decoration,
  required Color textColor,
  required VoidCallback onUpdate,
  required VoidCallback onAddRound,
}) {
  // 🎯 สร้าง ScrollController สำหรับตาราง
  final ScrollController tableScrollController = ScrollController();

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
        decoration: decoration,
        child: Column(
          children: [
            teams.isEmpty
                ? Padding(
                    padding: EdgeInsets.symmetric(vertical: isMobile ? 20 : 40),
                    child: Column(
                      children: [
                        Icon(
                          Icons.group_rounded,
                          size: isMobile ? 35 : 50,
                          color: textColor.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "There is no information about the team.",
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.7),
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Please click on the button below!",
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.5),
                            fontSize: isMobile ? 11 : 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : Scrollbar(
                    // 🎯 ใส่ Scrollbar ครอบ SingleChildScrollView
                    controller: tableScrollController,
                    thumbVisibility: true,
                    trackVisibility: true,
                    thickness: isMobile ? 4.0 : 8.0,
                    radius: const Radius.circular(10),
                    child: SingleChildScrollView(
                      controller: tableScrollController,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12.0), // เว้นระยะห่างด้านล่างไม่ให้แถบ Scrollbar ทับตาราง
                        child: Theme(
                          data: ThemeData(
                            textTheme: TextTheme(
                              bodyMedium: TextStyle(color: textColor),
                            ),
                          ),
                          child: DataTable(
                            columnSpacing: isMobile ? 12 : 20,
                            horizontalMargin: isMobile ? 5 : 24,
                            headingTextStyle: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              fontSize: isMobile ? 13 : 14,
                            ),
                            columns: [
                              const DataColumn(label: Text('Color')),
                              const DataColumn(label: Text('Team')),
                              for (int i = 0; i < roundCount; i++)
                                DataColumn(label: Text('Round ${i + 1}')),
                              const DataColumn(label: Text('Delete')),
                            ],
                            rows: List<DataRow>.generate(teams.length, (index) {
                              final team = teams[index];
                              return DataRow(
                                key: ValueKey(team.id),
                                cells: [
                                  DataCell(
                                    GestureDetector(
                                      onTap: () {
                                        int currentIndex = pastelColors.indexOf(team.color);
                                        int nextIndex = (currentIndex + 1) % pastelColors.length;
                                        team.color = pastelColors[nextIndex];
                                        onUpdate();
                                      },
                                      child: Container(
                                        width: isMobile ? 20 : 25,
                                        height: isMobile ? 20 : 25,
                                        decoration: BoxDecoration(
                                          color: team.color,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 2,
                                            ),
                                          ],
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
                                          fontSize: isMobile ? 13 : 14,
                                          color: textColor,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          isDense: true,
                                        ),
                                        onChanged: (value) {
                                          team.name = value;
                                          onUpdate();
                                        },
                                      ),
                                    ),
                                  ),
                                  for (int i = 0; i < roundCount; i++)
                                    DataCell(
                                      SizedBox(
                                        width: roundScoreWidth,
                                        child: TextFormField(
                                          key: ValueKey('${team.id}_score_$i'),
                                          initialValue: team.scores.length > i ? team.scores[i] : '',
                                          keyboardType: TextInputType.number,
                                          style: TextStyle(
                                            fontSize: isMobile ? 13 : 14,
                                            color: textColor,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: '0',
                                            hintStyle: TextStyle(
                                              color: textColor.withValues(alpha: 0.3),
                                            ),
                                            border: InputBorder.none,
                                            isDense: true,
                                          ),
                                          onChanged: (value) {
                                            while (team.scores.length <= i) {
                                              team.scores.add('');
                                            }
                                            team.scores[i] = value;
                                            onUpdate();
                                          },
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
                                          teams.removeAt(index);
                                          onUpdate();
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
                    teams.add(
                      TeamData(
                        id: DateTime.now().microsecondsSinceEpoch.toString(),
                        name: 'Team ${teams.length + 1}',
                        scores: List.filled(roundCount, ''),
                        color: randomColor,
                      ),
                    );
                    onUpdate();
                  },
                  icon: Icon(Icons.add, color: Colors.white, size: isMobile ? 18 : 24),
                  label: Text(
                    "Add New Team",
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 13 : 14,
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
                  onPressed: onAddRound,
                  icon: Icon(Icons.add_chart, color: Colors.white, size: isMobile ? 18 : 24),
                  label: Text(
                    "Add Round",
                    style: TextStyle(
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                      fontSize: isMobile ? 13 : 14,
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
              ],
            ),
          ],
        ),
      );
    },
  );
}