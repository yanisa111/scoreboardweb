import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelectIndex;

  // Background State
  final List<String> mainBackgrounds;
  final List<String> customBackgrounds;
  final int currentMainBgIndex;
  final bool isCustomBgSelected;
  final int currentCustomBgIndex;
  final ValueChanged<int> onSelectMainBg;
  final ValueChanged<int> onSelectCustomBg;
  final ValueChanged<int> onDeleteCustomBg; // 👈 เพิ่ม Callback สำหรับลบ BG
  final VoidCallback onUploadBackground;

  // Theme & Colors State
  final List<Decoration> cardDecorations;
  final int currentCardBgIndex;
  final ValueChanged<int> onSelectCardBg;
  final Color customContainerColor;
  final Color customTextColor;
  final bool isCustomThemeSelected;
  final Function(Color containerColor, Color textColor) onCustomThemeChanged;

  // Font Customization State
  final String selectedFontFamily;
  final double fontSizeScale;
  final ValueChanged<String> onFontFamilyChanged;
  final ValueChanged<double> onFontSizeScaleChanged;

  const AppDrawer({
    super.key,
    required this.selectedIndex,
    required this.onSelectIndex,
    required this.mainBackgrounds,
    required this.customBackgrounds,
    required this.currentMainBgIndex,
    required this.isCustomBgSelected,
    required this.currentCustomBgIndex,
    required this.onSelectMainBg,
    required this.onSelectCustomBg,
    required this.onDeleteCustomBg, // 👈
    required this.onUploadBackground,
    required this.cardDecorations,
    required this.currentCardBgIndex,
    required this.onSelectCardBg,
    required this.customContainerColor,
    required this.customTextColor,
    required this.isCustomThemeSelected,
    required this.onCustomThemeChanged,
    required this.selectedFontFamily,
    required this.fontSizeScale,
    required this.onFontFamilyChanged,
    required this.onFontSizeScaleChanged,
  });

  @override
  Widget build(BuildContext context) {
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

          // --- VIEW MODES ---
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
          _buildTile(context, icon: Icons.dashboard_rounded, title: "Default (Dual View)", index: 0),
          _buildTile(context, icon: Icons.bar_chart_rounded, title: "🔴 Graph View Only (Live)", index: 1, color: Colors.redAccent),
          _buildTile(context, icon: Icons.table_rows_rounded, title: "Score Table Only (Backend)", index: 2, color: Colors.blueAccent),
          _buildTile(context, icon: Icons.splitscreen_rounded, title: "Dual Monitor Mode", index: 3, color: Colors.purpleAccent),
          _buildTile(context, icon: Icons.leaderboard, title: "Leaderboard Scoreboard Page", index: 4, color: const Color(0xFF6B4EE6)),

          const Divider(),

          // --- WEBSITE BACKGROUND ---
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
              children: [
                // แสดงรูปเริ่มต้น
                ...List.generate(mainBackgrounds.length, (index) {
                  bool isSelected = !isCustomBgSelected && currentMainBgIndex == index;
                  return GestureDetector(
                    onTap: () => onSelectMainBg(index),
                    child: Container(
                      width: 78,
                      height: 55,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color.fromARGB(255, 97, 151, 222) : Colors.grey.shade300,
                          width: isSelected ? 3 : 1,
                        ),
                        image: DecorationImage(
                          image: AssetImage(mainBackgrounds[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: isSelected
                          ? const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 20))
                          : null,
                    ),
                  );
                }),

                // แสดงรูปที่ผู้ใช้อัปโหลด (พร้อมปุ่มกดลบ 🗑️)
                ...List.generate(customBackgrounds.length, (index) {
                  bool isSelected = isCustomBgSelected && currentCustomBgIndex == index;
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      GestureDetector(
                        onTap: () => onSelectCustomBg(index),
                        child: Container(
                          width: 78,
                          height: 55,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? const Color.fromARGB(255, 97, 151, 222) : Colors.grey.shade300,
                              width: isSelected ? 3 : 1,
                            ),
                            image: DecorationImage(
                              image: NetworkImage(customBackgrounds[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                          child: isSelected
                              ? const Center(child: Icon(Icons.check_circle, color: Colors.white, size: 20))
                              : null,
                        ),
                      ),
                      // ปุ่มลบ BG สีแดงมุมขวาบน 🔴
                      Positioned(
                        top: -5,
                        right: -5,
                        child: GestureDetector(
                          onTap: () => onDeleteCustomBg(index),
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.redAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.black26, blurRadius: 3),
                              ],
                            ),
                            child: const Icon(Icons.close, size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  );
                }),

                // ปุ่มสี่เหลี่ยมสีเทาสำหรับกด + เพิ่มรูปภาพ
                GestureDetector(
                  onTap: onUploadBackground,
                  child: Container(
                    width: 78,
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey.shade400, width: 1.5),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add, color: Colors.black54, size: 26),
                        Text("Add BG", style: TextStyle(fontSize: 10, color: Colors.black54, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(),

          // --- GRAPH/TABLE CONTAINER THEME ---
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
              children: [
                ...List.generate(cardDecorations.length, (index) {
                  bool isSelected = !isCustomThemeSelected && currentCardBgIndex == index;
                  return GestureDetector(
                    onTap: () => onSelectCardBg(index),
                    child: Container(
                      width: 58,
                      height: 58,
                      decoration: cardDecorations[index],
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? const Color.fromARGB(255, 97, 151, 222) : Colors.grey.shade400,
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

                // ปุ่มพรีวิวแบบแบ่งครึ่งสองสี + ปุ่มเปิด Spectrum Color Picker
                GestureDetector(
                  onTap: () => _showColorPickerModal(context),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isCustomThemeSelected ? const Color.fromARGB(255, 97, 151, 222) : Colors.grey.shade400,
                        width: isCustomThemeSelected ? 3 : 1,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: const [0.5, 0.5],
                        colors: [customContainerColor, customTextColor],
                      ),
                    ),
                    child: Stack(
                      children: [
                        if (isCustomThemeSelected)
                          const Center(
                            child: Icon(Icons.check_circle, color: Colors.white, size: 20),
                          ),
                        const Positioned(
                          right: 2,
                          bottom: 2,
                          child: CircleAvatar(
                            radius: 9,
                            backgroundColor: Colors.black54,
                            child: Icon(Icons.palette, size: 10, color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),
          const Divider(),

          // --- FONT STYLE & SIZE SETTINGS ---
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 10, bottom: 8),
            child: Text(
              "FONT & TYPOGRAPHY STYLE",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // เลือก Font Family
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Font Style", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedFontFamily,
                      isExpanded: true,
                      items: const [
                        DropdownMenuItem(value: 'Default', child: Text('Default (System)')),
                        DropdownMenuItem(value: 'Kanit', child: Text('Kanit (ไทย/Eng)')),
                        DropdownMenuItem(value: 'Prompt', child: Text('Prompt')),
                        DropdownMenuItem(value: 'Sarabun', child: Text('Sarabun')),
                        DropdownMenuItem(value: 'Roboto', child: Text('Roboto')),
                        DropdownMenuItem(value: 'Courier', child: Text('Monospace')),
                      ],
                      onChanged: (val) {
                        if (val != null) onFontFamilyChanged(val);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),

          // เลือกขนาด Font Size
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Font Size Scale", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    Text("${(fontSizeScale * 100).toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                  ],
                ),
                Slider(
                  value: fontSizeScale,
                  min: 0.8,
                  max: 1.5,
                  divisions: 7,
                  label: "${(fontSizeScale * 100).toInt()}%",
                  onChanged: onFontSizeScaleChanged,
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required int index,
    Color? color,
  }) {
    bool isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? (color ?? Colors.blue) : Colors.black87,
        ),
      ),
      selected: isSelected,
      onTap: () {
        onSelectIndex(index);
        Navigator.pop(context);
      },
    );
  }

  // หน้าต่างเลือกสีทรง Spectrum HSV แบบในรูปตัวอย่างที่ส่งมา 🎨
  void _showColorPickerModal(BuildContext context) {
    Color tempContainerColor = customContainerColor;
    Color tempTextColor = customTextColor;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return DefaultTabController(
              length: 2,
              child: AlertDialog(
                title: const Text("Custom Container & Font Colors", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                content: SizedBox(
                  width: 320,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const TabBar(
                        labelColor: Colors.blue,
                        unselectedLabelColor: Colors.black54,
                        indicatorColor: Colors.blue,
                        tabs: [
                          Tab(text: "1. Table/Graph BG"),
                          Tab(text: "2. Text Color"),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 180,
                        child: TabBarView(
                          children: [
                            // Tab 1: สีตาราง/กราฟ
                            HsvSpectrumColorPicker(
                              currentColor: tempContainerColor,
                              onColorChanged: (newColor) {
                                setModalState(() => tempContainerColor = newColor);
                              },
                            ),
                            // Tab 2: สีฟอนต์
                            HsvSpectrumColorPicker(
                              currentColor: tempTextColor,
                              onColorChanged: (newColor) {
                                setModalState(() => tempTextColor = newColor);
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text("Preview Result:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: tempContainerColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.black12),
                          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                        ),
                        child: Center(
                          child: Text(
                            "Sample Scoreboard Text",
                            style: TextStyle(
                              color: tempTextColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: selectedFontFamily == 'Default' ? null : selectedFontFamily,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancel"),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      onCustomThemeChanged(tempContainerColor, tempTextColor);
                      Navigator.pop(ctx);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                    child: const Text("Apply Theme", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ==========================================
// 🎨 Custom HSV Spectrum Color Picker Widget
// (ถอดแบบการทำงานมาจากภาพ image_e198a9.png)
// ==========================================
class HsvSpectrumColorPicker extends StatefulWidget {
  final Color currentColor;
  final ValueChanged<Color> onColorChanged;

  const HsvSpectrumColorPicker({
    super.key,
    required this.currentColor,
    required this.onColorChanged,
  });

  @override
  State<HsvSpectrumColorPicker> createState() => _HsvSpectrumColorPickerState();
}

class _HsvSpectrumColorPickerState extends State<HsvSpectrumColorPicker> {
  late double _hue;
  late double _saturation;
  late double _value;

  @override
  void initState() {
    super.initState();
    final hsv = HSVColor.fromColor(widget.currentColor);
    _hue = hsv.hue;
    _saturation = hsv.saturation;
    _value = hsv.value;
  }

  void _updateColor() {
    final color = HSVColor.fromAHSV(1.0, _hue, _saturation, _value).toColor();
    widget.onColorChanged(color);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // 1. กล่องเลือก Saturation & Value (ทางซ้าย)
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double width = constraints.maxWidth;
              double height = constraints.maxHeight;

              return GestureDetector(
                onPanUpdate: (details) => _handleTouch(details.localPosition, width, height),
                onPanDown: (details) => _handleTouch(details.localPosition, width, height),
                child: Stack(
                  children: [
                    // พื้นหลังไล่สี Spectrum ตาม Hue/Saturation/Value
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: HSVColor.fromAHSV(1.0, _hue, 1.0, 1.0).toColor(),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          gradient: const LinearGradient(
                            colors: [Colors.white, Colors.transparent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            gradient: const LinearGradient(
                              colors: [Colors.transparent, Colors.black],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // วงแหวนสีขาวชี้ตำแหน่งที่เลือก
                    Positioned(
                      left: (_saturation * width) - 8,
                      top: ((1.0 - _value) * height) - 8,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 2)],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 12),

        // 2. แถบรุ้งเลือก Hue (ทางขวา เหมือนในรูป)
        LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight;
            return GestureDetector(
              onPanUpdate: (details) => _handleHueTouch(details.localPosition.dy, height),
              onPanDown: (details) => _handleHueTouch(details.localPosition.dy, height),
              child: Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 20,
                    height: height,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF0000),
                          Color(0xFFFFFF00),
                          Color(0xFF00FF00),
                          Color(0xFF00FFFF),
                          Color(0xFF0000FF),
                          Color(0xFFFF00FF),
                          Color(0xFFFF0000),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  // ลูกศรบอกตำแหน่ง Hue
                  Positioned(
                    top: (_hue / 360.0 * height) - 6,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.arrow_right, size: 16, color: Colors.grey),
                        const SizedBox(width: 14),
                        const Icon(Icons.arrow_left, size: 16, color: Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  void _handleTouch(Offset pos, double width, double height) {
    setState(() {
      _saturation = (pos.dx / width).clamp(0.0, 1.0);
      _value = (1.0 - (pos.dy / height)).clamp(0.0, 1.0);
    });
    _updateColor();
  }

  void _handleHueTouch(double dy, double height) {
    setState(() {
      _hue = ((dy / height).clamp(0.0, 1.0)) * 360.0;
    });
    _updateColor();
  }
}