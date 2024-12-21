import 'package:flutter/material.dart';
import 'joke_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: Color(0xFF568388),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF568388),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF568388),
            ),
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Color(0xFF568388),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF568388),
              ),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Color(0xFF568388),
            ),
          ),
          themeMode: themeMode,
          home: JokeScreen(
            onThemeToggle: () {
              themeNotifier.value =
              themeNotifier.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
            },
          ),
        );
      },
    );
  }
}

class JokeScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;

  JokeScreen({required this.onThemeToggle});

  @override
  _JokeScreenState createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> with TickerProviderStateMixin {
  final JokeService jokeService = JokeService();
  List<Map<String, dynamic>>? jokes;
  bool isLoading = false;
  String selectedCategory = 'Programming';
  final List<String> categories = ['Programming', 'General', 'Knock-Knock'];
  int selectedJokeCount = 5;
  final List<int> jokeCounts = [1, 3, 5];
  List<bool> showAnswerFlags = [];
  late AnimationController _animationController;
  late Animation<Offset> _animationOffset;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animationOffset = Tween<Offset>(
      begin: Offset(0.0, 1.0),
      end: Offset(0.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  Future<void> fetchJokes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final fetchedJokes = await jokeService.fetchJokesRaw(
        category: selectedCategory.toLowerCase(),
        limit: selectedJokeCount,
      );
      setState(() {
        jokes = fetchedJokes;
        showAnswerFlags = List.filled(fetchedJokes.length, false);
      });

      // Start the animation
      _animationController.forward(from: 0.0);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching jokes: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'LOLz',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Theme.of(context).brightness == Brightness.light
                  ? Icons.dark_mode
                  : Icons.light_mode,
            ),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Center(
        child: jokes == null
            ? _buildInitialUI()
            : _buildJokeList(),
      ),
    );
  }

  Widget _buildInitialUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Image.asset(
            'assets/main.png',
            height: 250.0,
          ),
        ),
        _buildDropdown<String>(
          value: selectedCategory,
          items: categories,
          onChanged: (newValue) {
            setState(() {
              selectedCategory = newValue!;
            });
          },
        ),
        SizedBox(height: 16.0),
        ElevatedButton(
          onPressed: isLoading ? null : fetchJokes,
          child: isLoading
              ? CircularProgressIndicator(color: Colors.white)
              : Text('Find Jokes'),
        ),
      ],
    );
  }

  Widget _buildJokeList() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildControls(),
          ...jokes!.asMap().entries.map((entry) {
            final index = entry.key;
            final joke = entry.value;
            return _buildJokeCard(index, joke);
          }).toList(),
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: IconButton(
              onPressed: isLoading ? null : fetchJokes,
              icon: isLoading
                  ? CircularProgressIndicator(color: Color(0xFF568388))
                  : Icon(Icons.refresh, size: 30.0),
              color: Color(0xFF568388),
              tooltip: 'Refresh Jokes',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDropdown<String>(
          value: selectedCategory,
          items: categories,
          onChanged: (newValue) {
            setState(() {
              selectedCategory = newValue!;
              fetchJokes();
            });
          },
        ),
        SizedBox(width: 16.0),
        _buildDropdown<int>(
          value: selectedJokeCount,
          items: jokeCounts,
          onChanged: (newValue) {
            setState(() {
              selectedJokeCount = newValue!;
              fetchJokes();
            });
          },
        ),
      ],
    );
  }

  Widget _buildJokeCard(int index, Map<String, dynamic> joke) {
    return SlideTransition(
      position: _animationOffset,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 350.0,
          child: Container(
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  joke['setup'],
                  style: TextStyle(fontSize: 16.0),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.0),
                if (showAnswerFlags[index])
                  Text(
                    joke['punchline'],
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[500] 
                          : Colors.grey[700], 
                    ),
                    textAlign: TextAlign.center,
                  ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showAnswerFlags[index] = !showAnswerFlags[index];
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      showAnswerFlags[index] ? 'Hide Answer' : 'Show Answer',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color(0xFF568388),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Theme.of(context).cardColor : Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Color(0xFF568388), width: 1.5),
      ),
      child: DropdownButton<T>(
        value: value,
        underline: SizedBox(),
        dropdownColor: isDarkMode ? Theme.of(context).canvasColor : Colors.white,
        onChanged: onChanged,
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        items: items.map<DropdownMenuItem<T>>((T item) {
          return DropdownMenuItem<T>(
            value: item,
            child: Text(
              item.toString(),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
