import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _selectedIndex = 3;
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[800] : Colors.white,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text(
                  "American Sign Language (ASL)",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedLanguage = "ASL";
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  "British Sign Language (BSL)",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedLanguage = "BSL";
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: Text(
                  "Indian Sign Language (ISL)",
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'SignSpeak',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () {
              themeProvider.toggleTheme();
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
            SectionTitle(title: "APP PREFERENCES"),

            // Dark Mode
            SettingToggle(
              icon: isDark ? Icons.light_mode : Icons.dark_mode,
              title: "Dark Mode",
              value: isDark,
              onChanged: (value) {
                themeProvider.toggleTheme();
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
            SectionTitle(title: "VOICE & SPEECH"),

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
            SectionTitle(title: "APP INFORMATION"),

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
        unselectedItemColor: isDark ? Colors.grey[400] : Colors.grey,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.grey[300] : Colors.grey[700],
        ),
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: value != null
          ? Text(
              value!,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            )
          : Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: isDark ? Colors.grey[400] : Colors.grey,
            ),
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      subtitle: Slider(
        value: value,
        onChanged: onChanged,
        min: 0,
        max: 1,
        activeColor: Colors.blue,
        inactiveColor: isDark ? Colors.grey[700] : Colors.grey[300],
      ),
    );
  }
}
