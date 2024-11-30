import 'package:flutter/material.dart';
import 'joke_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: JokeScreen(),
    );
  }
}

class JokeScreen extends StatefulWidget {
  @override
  _JokeScreenState createState() => _JokeScreenState();
}

class _JokeScreenState extends State<JokeScreen> {
  final JokeService jokeService = JokeService();
  List<Map<String, dynamic>>? jokes;
  bool isLoading = false;
  bool showAnswer = false;

  Future<void> fetchJokes() async {
    setState(() {
      isLoading = true;
      showAnswer = false;
    });
    try {
      final fetchedJokes = await jokeService.fetchJokesRaw(limit: 1);
      setState(() {
        jokes = fetchedJokes;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching jokes: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF568388), // Set AppBar color
        title: Text(
          'LOLz',
          style: TextStyle(
            fontSize: 20.0, // Increase font size
            fontWeight: FontWeight.bold, // Make font bold
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (jokes == null)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Image.asset(
                      'assets/main.png',
                      height: 250.0,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: isLoading ? null : fetchJokes,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF568388),
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                    ),
                    child: isLoading
                        ? CircularProgressIndicator(
                      color: Colors.white,
                    )
                        : Text('Find a Joke'),
                  ),
                ],
              ),
            if (jokes != null && jokes!.isNotEmpty)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: 350.0,
                      height: 70.0,
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        color: Color(0xFFD3D3D3),
                        child: Center(
                          child: Text(
                            jokes![0]['setup'],
                            style: TextStyle(fontSize: 16.0),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (showAnswer)
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 350.0,
                        height: 70.0,
                        child: Container(
                          padding: EdgeInsets.all(16.0),
                          color: Color(0xFFD3D3D3),
                          child: Center(
                            child: Text(
                              jokes![0]['punchline'],
                              style: TextStyle(fontSize: 16.0, color: Colors.grey[700]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        showAnswer = !showAnswer;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        showAnswer ? 'Hide Answer' : 'Show Answer',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Color(0xFF568388),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: isLoading ? null : fetchJokes,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF568388),
                        padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator(
                        color: Colors.white,
                      )
                          : Text('Try another one'),
                    ),
                  ),
                ],
              )
          ],
        ),
      ),
    );
  }
}