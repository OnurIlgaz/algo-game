import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent).copyWith(
          primary: Colors.deepOrangeAccent,
          background: Colors.orange.shade100,
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _gameCount = 0;

  void _nextGame() {
    setState(() {
      Navigator.of(context).push(MaterialPageRoute(builder: (context) => const NextGamePage()));
      if(_gameCount < games.length - 1) _gameCount++;
    });
  }

  late List <Widget> games = [
    _GridGame(iterator: _nextGame, dataLoaded: false,),
  ];

  List <String> game_names = [
    'Grid Game',
  ];

  List <String> gameInfo = [
    'You have to turn on all the lights to win the game. Tap on a light to _toggle_ all lights which is below and leftside of it. Try to win the game in at most goal amount of moves!',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(game_names[_gameCount], style: const TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RestartPage()));
                games[_gameCount] = _GridGame(iterator: _nextGame, dataLoaded: false,);
              });
            },
            icon: const Icon(Icons.replay_outlined),
          )
        ],
      ),
      body: games[_gameCount],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(backgroundColor: Theme.of(context).colorScheme.secondaryContainer, context: context, builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(gameInfo[_gameCount], style: goodStyle,),
                  ],
                ),
              ),
            );
          });
        },
        child: const Icon(Icons.question_mark_sharp),
      ),
    );
  }
}

class _GridGame extends StatefulWidget {
  _GridGame({super.key, required this.iterator, required this.dataLoaded});

  final void Function() iterator;
  bool dataLoaded = false;

  @override
  State<_GridGame> createState() => _GridGameState();
}

class _GridGameState extends State<_GridGame> {
  final int K = 8;
  List<List<bool>> grid = [];
  int answer = 0, movesMade = 0;

  void _move(int x, int y) {
    setState(() {
      for(int i = x; i < K; i++) {
        for(int j = 0; j <= y; j++) {
          grid[i][j] = !grid[i][j];
        }
      }
      movesMade++;
      bool check = true;
      for(int i = 0; i < K; i++) {
        for(int j = 0; j < K; j++) {
          check = check && !grid[i][j];
        }
      }
      if(check) {
        _endGame();
      }
    });
  }

  void _move_basic(int x, int y) {
    for(int i = x; i < K; i++) {
      for(int j = 0; j <= y; j++) {
        grid[i][j] = !grid[i][j];
      }
    }
  }

  void _endGame() {
    setState(() {
      if(movesMade == answer) widget.iterator();
      else {
        Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RestartPage()));
        _loadData();
      }
    });
  }

  int calculateAnswer() {
    int answer = 0;
    var temp = List<List<bool>>.from(grid.map((row) => List<bool>.from(row)));
    for(int i = 0; i < K; i++) {
      for(int j = K - 1; j >= 0; j--) {
        if(grid[i][j]) {
          answer++; 
          _move_basic(i, j);
        }
      }
    }
    grid = temp;
    return answer;
  }

  void _loadData() {
    grid = List<List<bool>>.generate(K, (i) => List<bool>.generate(K, (j) => Random().nextBool()));
    answer = calculateAnswer();
    movesMade = 0;
  }

  @override
  Widget build(BuildContext context) {
    if(widget.dataLoaded == false) {
      _loadData();
      widget.dataLoaded = true;
    }
    double width = MediaQuery.of(context).size.width, height = MediaQuery.of(context).size.height;
    double space = min(width, height) / (K + 1);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Moves made: $movesMade"),
        const SizedBox(height: 10,),
        Text("Goal: $answer"),
        const SizedBox(height: 10,),
        Padding(
          padding: EdgeInsets.all(space / 2),
          child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(K, (i) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,  
                    children: List.generate(K, (j) => SingleBlock(size: space, isAlive: grid[i][j], x: i, y: j, onTap: _move)),
                  )),
                ),
          ),
        ),
      ],
    );
  }
}

class SingleBlock extends StatelessWidget {
  final bool isAlive;
  final int x;
  final int y;
  final double size;
  final Function(int, int) onTap;

  const SingleBlock({super.key, required this.size, required this.isAlive, required this.x, required this.y, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(isAlive) { 
          onTap(x, y);
        }
      },
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isAlive ? Colors.grey.shade900 : Colors.white,
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
        ),
      )
    );
  }
}

const goodStyle = TextStyle(fontSize: 20,fontWeight: FontWeight.bold,color: Color.fromARGB(255, 8, 61, 105),);
final goodStyle2 = goodStyle.copyWith(fontSize: 14);

class RestartPage extends StatelessWidget {
  const RestartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Navigator.of(context).pop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game Over'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You Lost!', style: goodStyle,),
              const SizedBox(height: 10,),
              Text('Tap anywhere to try again!', style: goodStyle2),
            ],
          ),
        ),
      ),
    );
  }
}

class NextGamePage extends StatelessWidget {
  const NextGamePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: Navigator.of(context).pop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Game Over'),
          backgroundColor: Theme.of(context).colorScheme.secondary,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text('You have completed the game!', style: goodStyle,),
              const SizedBox(height: 10,),
              Text('Tap anywhere to play the next game!', style: goodStyle2,),
            ],
          ),
        ),
      ),
    );
  }
}