import 'package:flutter/material.dart';
import 'dart:math';
import 'graph.dart'; // นำเข้า TeamData และ pastelColors
import 'first.dart'; // นำเข้า First สำหรับสลับหน้า

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  // 📝 หัวข้อใหญ่ด้านบนที่คลิกพิมพ์แก้ไขได้
  String pageTitle = "LEADERBOARD SCOREBOARD";
  final TextEditingController _titleController = TextEditingController();
  bool _isEditingTitle = false;

  // 📜 Controller สำหรับควบคุมการเลื่อน Scroll ตารางคะแนนแนวนอน
  final ScrollController _roundsScrollController = ScrollController();

  // 🎯 ข้อมูลทีมและจำนวนรอบ
  int roundCount = 5;
  List<TeamData> teams = [
    TeamData(id: '1', name: 'Team Alpha', scores: ['1', '0', '1', '1', '0'], color: Colors.blueAccent),
    TeamData(id: '2', name: 'Team Beta', scores: ['0', '1', '1', '0', '1'], color: Colors.orangeAccent),
    TeamData(id: '3', name: 'Team Gamma', scores: ['1', '1', '1', '1', '1'], color: Colors.greenAccent),
  ];

  // 🏞️ รายการภาพพื้นหลังหลัก
  final List<String> mainBackgrounds = List.generate(17, (i) => 'bg/${i + 1}.jpg');
  int currentMainBgIndex = 0;

  // 🎨 รายการตกแต่งกล่องตาราง
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

  // ◀️ ฟังก์ชั่นเลื่อนตารางไปทางซ้าย
  void _scrollLeft() {
    _roundsScrollController.animateTo(
      _roundsScrollController.offset - 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  // ▶️ ฟังก์ชั่นเลื่อนตารางไปทางขวา
  void _scrollRight() {
    _roundsScrollController.animateTo(
      _roundsScrollController.offset + 120,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkCard = currentCardBgIndex == 2;
    Color contentTextColor = isDarkCard ? Colors.white : Colors.black87;

    return Scaffold(
      drawer: _buildAppDrawer(),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              mainBackgrounds[currentMainBgIndex],
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFFF8F5FB)),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // แถบบนเปิด Drawer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.black87, size: 30),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                // หัวข้อเปลี่ยนได้
                _buildEditableHeaderTitle(),

                const SizedBox(height: 10),

                // 📊 ตารางคะแนนและกราฟ
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 60),
                    child: Container(
                      decoration: cardDecorations[currentCardBgIndex],
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 1. คอลัมน์ชื่อทีม
                              _buildTeamColumn(teams, contentTextColor),

                              // 2. คอลัมน์รอบคะแนน
                              // ตรงส่วนที่แสดงผล Row หลักใน Widget build หน้า LeaderboardPage
// ให้เปลี่ยนจากเดิมที่เป็น Row ธรรมดา มาครอบด้วย Scrollbar และ SingleChildScrollView แบบนี้ครับ:

Flexible(
  fit: FlexFit.loose,
  child: Scrollbar(
    controller: _roundsScrollController,
    thumbVisibility: true, // 👈 บังคับให้แถบเลื่อนแสดงขึ้นมาตลอดเวลา
    thickness: 8.0,        // 👈 กำหนดความหนาของแถบเลื่อนให้เห็นชัดเจน
    radius: const Radius.circular(4),
    child: SingleChildScrollView(
      controller: _roundsScrollController,
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(bottom: 16.0), // เผื่อพื้นที่ด้านล่างให้แถบเลื่อนไม่ทับข้อความ
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          // 2. คอลัมน์รอบคะแนน (หัวข้อ + ช่องกรอก)
          _buildRoundsColumn(teams, contentTextColor),


        ],
      ),
    ),
  ),
),

                              // 3. คอลัมน์ Total + กราฟแนวนอน + อันดับ
                              _buildStatsColumn(teams, contentTextColor),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ปุ่มจัดการล่าง
                _buildBottomControls(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableHeaderTitle() {
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
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                decoration: const InputDecoration(border: InputBorder.none, isDense: true),
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
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.edit, color: Colors.white70, size: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildTeamColumn(List<TeamData> displayTeams, Color textColor) {
    return SizedBox(
      width: 180,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 45,
            alignment: Alignment.centerLeft,
            child: Text('Team', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
          ),
          Divider(height: 1, color: textColor.withValues(alpha: 0.3)),
          ...displayTeams.map((team) => Container(
                height: 52,
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _removeTeam(team.id),
                      child: const Icon(Icons.remove_circle, color: Colors.redAccent, size: 18),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextFormField(
                        initialValue: team.name,
                        style: TextStyle(fontWeight: FontWeight.w600, color: textColor),
                        decoration: const InputDecoration(border: InputBorder.none, isDense: true),
                        onChanged: (val) => team.name = val,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

Widget _buildRoundsColumn(List<TeamData> displayTeams, Color textColor) {
    const double columnWidth = 70.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🏷️ แถวหัวข้อ (Round 1, Round 2, ...)
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
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 13),
                ),
              ),
            ),
          ),
        ),
        Divider(height: 1, color: textColor.withValues(alpha: 0.3)),

        // 📝 แถวช่องกรอกคะแนนของแต่ละทีม
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
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  child: TextFormField(
                    key: ValueKey('${team.id}_$rIndex'),
                    initialValue: team.scores[rIndex],
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      contentPadding: EdgeInsets.zero,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textColor.withValues(alpha: 0.3)),
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

  Widget _buildStatsColumn(List<TeamData> displayTeams, Color textColor) {
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
              SizedBox(width: 50, child: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center)),
              SizedBox(width: 180, child: Text('Graph', style: TextStyle(fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center)),
              SizedBox(width: 40, child: Text('Rank', style: TextStyle(fontWeight: FontWeight.bold, color: textColor), textAlign: TextAlign.center)),
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
                    team.totalScore.toStringAsFixed(team.totalScore % 1 == 0 ? 0 : 1),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 16),
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
                        FractionallySizedBox(
                          widthFactor: scoreRatio,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
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
                    backgroundColor: rank == 1 ? Colors.amber : (rank == 2 ? Colors.grey.shade400 : (rank == 3 ? Colors.brown.shade300 : Colors.blueGrey.shade100)),
                    child: Text(
                      '$rank',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black87),
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

Widget _buildAppDrawer() {
  return Drawer(
    backgroundColor: const Color(0xFFF9F5FB),
    child: SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          ListTile(
            leading: const Icon(Icons.grid_view_rounded, color: Color(0xFF6B4EE6)),
            title: const Text('Default (Dual View)', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const First(initialIndex: 0)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_rounded, color: Colors.redAccent),
            title: const Text('Graph View Only (Live)', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const First(initialIndex: 1)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_rounded, color: Colors.blue),
            title: const Text('Score Table Only (Backend)', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const First(initialIndex: 2)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.crop_din_rounded, color: Colors.purpleAccent),
            title: const Text('Dual Monitor Mode', style: TextStyle(fontWeight: FontWeight.w600)),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const First(initialIndex: 3)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.equalizer_rounded, color: Color(0xFF6B4EE6)),
            title: const Text('เปิดหน้า Leaderboard Graph', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6B4EE6))),
            selected: true,
            onTap: () {
              Navigator.pop(context); // อยู่หน้านี้อยู่แล้ว ปิด Drawer อย่างเดียว
            },
          ),

          const Divider(height: 30),

          const Text(
            'WEBSITE BACKGROUND',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.5,
            ),
            itemCount: mainBackgrounds.length,
            itemBuilder: (context, index) {
              bool isSelected = currentMainBgIndex == index;
              return GestureDetector(
                onTap: () => setState(() => currentMainBgIndex = index),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4C84F6) : Colors.transparent,
                      width: isSelected ? 3 : 0,
                    ),
                    image: DecorationImage(
                      image: AssetImage(mainBackgrounds[index]),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check, size: 14, color: Color(0xFF4C84F6)),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),

          const Divider(height: 30),

          const Text(
            'GRAPH/TABLE CONTAINER THEME',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.8),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(cardDecorations.length, (index) {
              bool isSelected = currentCardBgIndex == index;
              return GestureDetector(
                onTap: () => setState(() => currentCardBgIndex = index),
                child: Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF4C84F6) : Colors.transparent,
                      width: isSelected ? 3 : 0,
                    ),
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: cardDecorations[index],
                    child: isSelected
                        ? const Center(
                            child: Icon(Icons.check_circle_rounded, size: 22, color: Colors.black87),
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      color: Colors.black26,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: _addTeam,
            icon: const Icon(Icons.group_add, size: 18),
            label: const Text('Add Team'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo, foregroundColor: Colors.white),
          ),
          ElevatedButton.icon(
            onPressed: _addRound,
            icon: const Icon(Icons.add_circle, size: 18),
            label: const Text('Add Round'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
          ),
          ElevatedButton.icon(
            onPressed: _deleteRound,
            icon: const Icon(Icons.remove_circle, size: 18),
            label: const Text('Delete Round'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
          ),
        ],
      ),
    );
  }
}