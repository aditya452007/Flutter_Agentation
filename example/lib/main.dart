import 'package:flutter/material.dart';
import 'package:flutter_agnetation/agentation.dart';

void main() => runApp(const DemoApp());

class DemoApp extends StatelessWidget {
  const DemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AgentationOverlay.wrap(
      child: MaterialApp(
        title: 'Agenation Demo',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueGrey),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const HomeScreen(),
          '/details': (context) => const DetailsScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agenation Demo')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Account'),
              subtitle: const Text('Manage profile'),
              trailing: Switch(value: true, onChanged: (_) {}),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Quick actions', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(onPressed: () {}, child: const Text('Get Started')),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => Navigator.pushNamed(context, '/details'),
                        child: const Text('Details →'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const TextField(decoration: InputDecoration(hintText: 'Developer note test', border: OutlineInputBorder())),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                CheckboxListTile(value: true, onChanged: (_) {}, title: const Text('Enable sync')),
                const Divider(height: 1),
                const ListTile(leading: Icon(Icons.storage), title: Text('Storage')),
                const ListTile(leading: Icon(Icons.wifi), title: Text('Network')),
                const ListTile(leading: Icon(Icons.palette), title: Text('Appearance')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Details')),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Hierarchy depth showcase', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: () {}, child: const Text('Get Started')),
                const SizedBox(height: 12),
                const Divider(),
                const Text('Tap any widget in Inspect mode — hierarchy shows Scaffold → Card → ElevatedButton'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
