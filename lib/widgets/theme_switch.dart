import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class ThemeSwitch extends StatelessWidget {
  const ThemeSwitch({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return SwitchListTile(
          title: const Text('Dark Theme'),
          value: taskProvider.isDarkTheme,
          onChanged: (value) {
            taskProvider.toggleTheme();
          },
        );
      },
    );
  }
}
