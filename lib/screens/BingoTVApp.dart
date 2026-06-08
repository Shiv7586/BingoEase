import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';

class BingoProTV extends StatefulWidget {
  const BingoProTV({super.key});

  @override
  State<BingoProTV> createState() => _BingoProTVState();
}

class _BingoProTVState extends State<BingoProTV> {
  final FlutterTts flutterTts = FlutterTts();

  int? currentNumber;
  String currentLetter = "";
  List<int> calledNumbers = [];
  List<int> availableNumbers = List.generate(75, (i) => i + 1);
  int historyIndex = -1;

  bool isAutoPlaying = false;
  double autoSpeed = 2.0;
  double voiceSpeed = 0.5;

  bool soundEffects = true;
  bool fullHighlight = true;
  String speedLabel = "Medium";
  String voiceSpeedLabel = "Medium";

  int maxRepeats = 1;
  int spokenCount = 0;
  String repeatLabel = "1 Time";

  final Map<String, Color> rowColors = {
    "B": const Color(0xFF0D47A1),
    "I": const Color(0xFFB71C1C),
    "N": const Color(0xFF1B5E20),
    "G": const Color(0xFFFF8F00),
    "O": const Color(0xFF4A148C),
  };

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(voiceSpeed);

    // यह हैंडलर तब चलता है जब एक बार बोलना पूरी तरह खत्म हो जाता है
    flutterTts.setCompletionHandler(() {
      if (!isAutoPlaying) return;

      if (spokenCount < maxRepeats) {
        // अगर अभी भी लूप बचा है, तो दोबारा बोलो
        Future.delayed(const Duration(milliseconds: 300), () {
          if (isAutoPlaying && currentNumber != null && spokenCount < maxRepeats) {
            setState(() {
              spokenCount++;
            });
            flutterTts.speak("$currentLetter ${currentNumber.toString()}");
          }
        });
      } else {
        Future.delayed(Duration(milliseconds: (autoSpeed * 1000).toInt()), () {
          if (isAutoPlaying) {
            if (availableNumbers.isNotEmpty || historyIndex < calledNumbers.length - 1) {
              nextNumber();
            } else {
              setState(() => isAutoPlaying = false);
            }
          }
        });
      }
    });
  }

  Future<void> _speak(String text) async {
    if (!soundEffects) return;

    await flutterTts.stop();

    setState(() {
      spokenCount = 1;
    });

    await flutterTts.setSpeechRate(voiceSpeed);
    await flutterTts.speak(text);
  }


  String getLetter(int n) {
    if (n <= 15) return "B";
    if (n <= 30) return "I";
    if (n <= 45) return "N";
    if (n <= 60) return "G";
    return "O";
  }

  void nextNumber() {
    if (historyIndex < calledNumbers.length - 1) {
      setState(() {
        historyIndex++;
        currentNumber = calledNumbers[historyIndex];
        currentLetter = getLetter(currentNumber!);
      });
      _speak("$currentLetter ${currentNumber.toString()}");
      return;
    }
    if (availableNumbers.isEmpty) {
      setState(() => isAutoPlaying = false);
      return;
    }
    setState(() {
      int index = Random().nextInt(availableNumbers.length);
      int picked = availableNumbers.removeAt(index);
      calledNumbers.add(picked);
      historyIndex = calledNumbers.length - 1;
      currentNumber = picked;
      currentLetter = getLetter(currentNumber!);
    });
    _speak("$currentLetter ${currentNumber.toString()}");
  }

  void previousNumber() {
    if (historyIndex > 0) {
      setState(() {
        historyIndex--;
        currentNumber = calledNumbers[historyIndex];
        currentLetter = getLetter(currentNumber!);
      });
      _speak("$currentLetter ${currentNumber.toString()}");
    }
  }

  void toggleAutoPlay() {
    setState(() {
      isAutoPlaying = !isAutoPlaying;
      if (isAutoPlaying) {
        if (currentNumber == null || spokenCount >= maxRepeats) {
          nextNumber();
        } else {
          _speak("$currentLetter ${currentNumber.toString()}");
        }
      } else {
        flutterTts.stop();
        spokenCount = 0;
      }
    });
  }

  void resetGame() {
    flutterTts.stop();
    setState(() {
      isAutoPlaying = false;
      availableNumbers = List.generate(75, (i) => i + 1);
      calledNumbers = [];
      historyIndex = -1;
      currentNumber = null;
      currentLetter = "";
      spokenCount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <ShortcutActivator, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.enter): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.space): const ActivateIntent(),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (ActivateIntent intent) {
              return null;
            },
          ),
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0F111A),
          body: Row(
            children: [
              Expanded(
                flex: 3,
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(right: BorderSide(color: Colors.white10)),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        _buildMainBall(),
                        const SizedBox(height: 20),
                        Icon(
                          soundEffects ? Icons.volume_up : Icons.volume_off,
                          color: soundEffects ? Colors.white54 : Colors.redAccent.withOpacity(0.4),
                          size: 40,
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(child: _tvButton("PREVIOUS", Icons.chevron_left, previousNumber, enabled: historyIndex > 0)),
                              const SizedBox(width: 10),
                              Expanded(child: _tvButton("NEXT", Icons.chevron_right, nextNumber, highlight: true, autofocus: true)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Text(
                            "BingoEase Board History",
                            style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8, bottom: 20),
                            height: 2, width: 200,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(colors: [Colors.transparent, Colors.white.withOpacity(0.5), Colors.transparent]),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: rowColors.keys.map((letter) => _buildRow(letter)).toList(),
                            ),
                          ),
                          _buildBottomControls(),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 10, right: 10,
                      child: _iconFocusButton(Icons.settings, _showSettings),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tvButton(String label, IconData icon, VoidCallback onTap, {bool highlight = false, bool enabled = true, bool autofocus = false}) {
    return Focus(
      autofocus: autofocus,
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (enabled && (event is KeyDownEvent || event is KeyRepeatEvent)) {
          if (event.logicalKey == LogicalKeyboardKey.select ||
              event.logicalKey == LogicalKeyboardKey.enter ||
              event.logicalKey == LogicalKeyboardKey.space) {
            onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(
        builder: (context) {
          bool isFocused = Focus.of(context).hasFocus;
          return InkWell(
            onTap: enabled ? onTap : null,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 70,
              decoration: BoxDecoration(
                color: isFocused ? Colors.blueAccent : (highlight ? Colors.blueAccent.withOpacity(0.2) : Colors.white10),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isFocused ? Colors.white38 : (highlight ? Colors.blueAccent : Colors.white24),
                  width: isFocused ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  FittedBox(
                    child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _iconFocusButton(IconData icon, VoidCallback onTap) {
    return Focus(
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
            onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        bool isFocused = Focus.of(context).hasFocus;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isFocused ? Colors.blueAccent : Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isFocused ? Colors.yellowAccent : Colors.white12, width: isFocused ? 2 : 1),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
        );
      }),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _tvIconControl(isAutoPlaying ? Icons.pause_circle : Icons.play_circle, "PLAY/PAUSE", toggleAutoPlay),
          _tvPillButton("ANNOUNCE"),
          _tvIconControl(Icons.refresh, "RESET", resetGame),
          _tvIconControl(Icons.stop_circle_outlined, "START OVER", resetGame),
        ],
      ),
    );
  }

  Widget _tvIconControl(IconData icon, String label, VoidCallback onTap) {
    return Focus(
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
            onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        bool isFocused = Focus.of(context).hasFocus;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(10),
            decoration: isFocused ? BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.yellowAccent),
            ) : null,
            child: Column(
              children: [
                Icon(icon, color: isFocused ? Colors.yellowAccent : Colors.white, size: 40),
                Text(label, style: TextStyle(color: isFocused ? Colors.yellowAccent : Colors.white54, fontSize: 10)),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _tvPillButton(String label) {
    return Focus(
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
            if (currentNumber != null) _speak("$currentLetter $currentNumber");
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        bool isFocused = Focus.of(context).hasFocus;
        return InkWell(
          onTap: () { if (currentNumber != null) _speak("$currentLetter $currentNumber"); },
          borderRadius: BorderRadius.circular(25),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            decoration: BoxDecoration(
              color: isFocused ? Colors.yellowAccent : Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: isFocused ? Border.all(color: Colors.white, width: 2) : null,
            ),
            child: Text(label, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        );
      }),
    );
  }

  Widget _buildMainBall() {
    Color activeColor = currentLetter.isEmpty ? Colors.white24 : rowColors[currentLetter]!;
    return Container(
      constraints: const BoxConstraints(maxHeight: 250, maxWidth: 250),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          margin: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: activeColor, width: 8),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(currentLetter, style: TextStyle(fontSize: 40, color: activeColor, fontWeight: FontWeight.w900)),
                  Text(currentNumber?.toString() ?? "??", style: const TextStyle(fontSize: 70, color: Colors.white, fontWeight: FontWeight.bold, height: 1)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String letter) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2.0),
        child: Row(
          children: [
            SizedBox(
                width: 35,
                child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(letter, style: TextStyle(color: rowColors[letter], fontSize: 38, fontWeight: FontWeight.w900))
                )
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                    color: rowColors[letter]!.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(15, (i) {
                    int num = (rowColors.keys.toList().indexOf(letter) * 15) + (i + 1);
                    bool isCalled = calledNumbers.contains(num);

                    return Flexible(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 45, maxHeight: 45),
                        margin: const EdgeInsets.symmetric(horizontal: 1),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCalled ? (fullHighlight ? rowColors[letter] : Colors.transparent) : Colors.white.withOpacity(0.08),
                          border: isCalled
                              ? Border.all(color: rowColors[letter]!, width: 2)
                              : (currentNumber == num ? Border.all(color: Colors.white, width: 2) : null),
                        ),
                        child: Center(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Text(
                                    "$num",
                                    style: TextStyle(
                                        fontSize: 22,
                                        color: isCalled ? Colors.white : Colors.white24,
                                        fontWeight: FontWeight.w900
                                    )
                                ),
                              ),
                            )
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1D2E),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text("BingoEase Settings", style: TextStyle(color: Colors.white)),
              content: SizedBox(
                width: 450,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _settingTile(
                      title: "Voice Speed",
                      subtitle: voiceSpeedLabel,
                      icon: Icons.record_voice_over,
                      onTap: () {
                        setModalState(() {
                          if (voiceSpeedLabel == "Slow") { voiceSpeedLabel = "Medium"; voiceSpeed = 0.5; }
                          else if (voiceSpeedLabel == "Medium") { voiceSpeedLabel = "Fast"; voiceSpeed = 0.8; }
                          else { voiceSpeedLabel = "Slow"; voiceSpeed = 0.2; }
                        });
                        setState(() {});
                      },
                    ),
                    _settingTile(
                      title: "Auto Play Speed",
                      subtitle: speedLabel,
                      icon: Icons.speed,
                      onTap: () {
                        setModalState(() {
                          // यहाँ autoSpeed का मतलब है: घोषणा पूरी होने के बाद रुकने का समय (Delay)
                          if (speedLabel == "Slow") { speedLabel = "Medium"; autoSpeed = 2.0; }
                          else if (speedLabel == "Medium") { speedLabel = "Fast"; autoSpeed = 0.8; }
                          else { speedLabel = "Slow"; autoSpeed = 4.0; }
                        });
                        setState(() {});
                      },
                    ),
                    _settingTile(
                      title: "Auto Play Announcement Repeat",
                      subtitle: repeatLabel,
                      icon: Icons.repeat,
                      onTap: () {
                        setModalState(() {
                          if (maxRepeats == 1) {
                            maxRepeats = 2;
                            repeatLabel = "2 Times";
                          } else if (maxRepeats == 2) {
                            maxRepeats = 3;
                            repeatLabel = "3 Times";
                          } else {
                            maxRepeats = 1;
                            repeatLabel = "1 Time";
                          }
                        });
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("DONE"))],
            );
          },
        );
      },
    );
  }

  Widget _settingTile({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return Focus(
      onKeyEvent: (FocusNode node, KeyEvent event) {
        if (event is KeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.select || event.logicalKey == LogicalKeyboardKey.enter) {
            onTap();
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Builder(builder: (context) {
        bool isFocused = Focus.of(context).hasFocus;
        return ListTile(
          onTap: onTap,
          tileColor: isFocused ? Colors.blueAccent.withOpacity(0.2) : Colors.transparent,
          shape: RoundedRectangleBorder(side: BorderSide(color: isFocused ? Colors.yellowAccent : Colors.transparent, width: 2), borderRadius: BorderRadius.circular(10)),
          leading: Icon(icon, color: isFocused ? Colors.yellowAccent : Colors.white70),
          title: Text(title, style: const TextStyle(color: Colors.white)),
          subtitle: Text(subtitle, style: const TextStyle(color: Colors.blueAccent)),
        );
      }),
    );
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

}