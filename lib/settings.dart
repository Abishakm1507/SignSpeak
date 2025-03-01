import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3;
  bool _isDarkMode = false;
  bool _isOfflineMode = false;
  bool _isVoiceFeedback = true;
  double _speechSpeed = 0.5;
  double _animationSpeed = 0.5;
  String _selectedLanguage = "ASL";

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Navigate based on bottom nav selection
    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1: // Sign-Speech
        Navigator.pushReplacementNamed(context, '/sign_speech');
        break;
      case 2: // Speech-Sign
        Navigator.pushReplacementNamed(context, '/speech_sign');
        break;
      case 3: // Settings - already here
        break;
    }
  }

  // Show Language Selection Modal
  void _showLanguageSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("American Sign Language (ASL)"),
                onTap: () {
                  setState(() {
                    _selectedLanguage = "ASL";
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("British Sign Language (BSL)"),
                onTap: () {
                  setState(() {
                    _selectedLanguage = "BSL";
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text("Indian Sign Language (ISL)"),
                onTap: () {
                  setState(() {
                    _selectedLanguage = "ISL";
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'SignSpeak',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode, color: Colors.black),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            const SizedBox(height: 10),

            // APP PREFERENCES SECTION
            const SectionTitle(title: "APP PREFERENCES"),

            // Dark Mode
            SettingToggle(
              icon: Icons.dark_mode,
              title: "Dark Mode",
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
              },
            ),

            // Sign Language Selection
            SettingOption(
              icon: Icons.language,
              title: "Sign Language",
              value: _selectedLanguage,
              onTap: () {
                _showLanguageSelection();
              },
            ),

            // Offline Mode
            SettingToggle(
              icon: Icons.wifi_off,
              title: "Offline Mode",
              value: _isOfflineMode,
              subtitle: "Save signs for offline use",
              onChanged: (value) {
                setState(() {
                  _isOfflineMode = value;
                });
              },
            ),

            const SizedBox(height: 10),

            // VOICE & SPEECH SECTION
            const SectionTitle(title: "VOICE & SPEECH"),

            // Voice Feedback
            SettingToggle(
              icon: Icons.volume_up,
              title: "Voice Feedback",
              value: _isVoiceFeedback,
              onChanged: (value) {
                setState(() {
                  _isVoiceFeedback = value;
                });
              },
            ),

            // Speech Speed Slider
            SettingSlider(
              icon: Icons.speed,
              title: "Speech Speed",
              value: _speechSpeed,
              onChanged: (value) {
                setState(() {
                  _speechSpeed = value;
                });
              },
            ),

            // Animation Speed Slider
            SettingSlider(
              icon: Icons.animation,
              title: "Animation Speed",
              value: _animationSpeed,
              onChanged: (value) {
                setState(() {
                  _animationSpeed = value;
                });
              },
            ),

            const SizedBox(height: 10),

            // APP INFORMATION SECTION
            const SectionTitle(title: "APP INFORMATION"),

            // Help & Support
            SettingOption(
              icon: Icons.help_outline,
              title: "Help & Support",
              onTap: () {
                print("Navigate to Help & Support");
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.front_hand), label: 'Sign-Speech'),
          BottomNavigationBarItem(
              icon: Icon(Icons.graphic_eq), label: 'Speech-Sign'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
    );
  }
}

// Section Title
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        title,
        style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[700]),
      ),
    );
  }
}

// Setting Toggle Switch
class SettingToggle extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool value;
  final String? subtitle;
  final Function(bool) onChanged;

  const SettingToggle({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      value: value,
      onChanged: onChanged,
    );
  }
}

// Setting Option with Navigation
class SettingOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? value;
  final Function()? onTap;

  const SettingOption({
    Key? key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: value != null
          ? Text(value!, style: TextStyle(color: Colors.grey[700]))
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}

// Setting Slider
class SettingSlider extends StatelessWidget {
  final IconData icon;
  final String title;
  final double value;
  final Function(double) onChanged;

  const SettingSlider({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Slider(
        value: value,
        onChanged: onChanged,
        min: 0,
        max: 1,
        activeColor: Colors.blue,
        inactiveColor: Colors.grey[300],
      ),
    );
  }
}
