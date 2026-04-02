import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../services/notification_service.dart';
import 'today_tasks_screen.dart';
import 'completed_tasks_screen.dart';
import 'repeated_tasks_screen.dart';
import 'add_edit_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<TaskProvider>(context, listen: false).fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;
    final totalTasks = tasks.length;
    final completedTasksCount = tasks.where((t) => t.isCompleted).length;
    final progress = totalTasks == 0 ? 0.0 : completedTasksCount / totalTasks;
    
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(taskProvider, isDark),
                const SizedBox(height: 25),
                Text('Dashboard', 
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    shadows: isDark ? [Shadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), blurRadius: 10)] : null,
                  ),
                ),
                const SizedBox(height: 20),
                _buildWorkspaceSelector(taskProvider, isDark),
                const SizedBox(height: 15),
                _buildCategoryTabs(isDark),
                const SizedBox(height: 20),
                if (_selectedIndex == 0) ...[
                  _buildProgressCard(progress, completedTasksCount, totalTasks, isDark),
                  const SizedBox(height: 20),
                  _buildQuickActions(isDark),
                ],
                const SizedBox(height: 20),
                Expanded(
                  child: _buildTaskView(),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildHeader(TaskProvider provider, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
              ),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: isDark ? Colors.white10 : Colors.black12,
                backgroundImage: const AssetImage('assets/profile.jpg'),
                onBackgroundImageError: (exception, stackTrace) {
                  // Fallback if image isn't placed yet
                },
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Good morning,', style: Theme.of(context).textTheme.bodyMedium),
                Text('Bilal Khaliq', style: Theme.of(context).textTheme.titleLarge),
              ],
            ),
          ],
        ),
        Row(
          children: [
            // Test Notification Button
            _buildIconButton(CupertinoIcons.bell, isDark, onTap: () {
              NotificationService().showImmediateNotification(
                0,
                'Test Notification',
                'This is a local notification test!',
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Test notification sent!')),
              );
            }),
            const SizedBox(width: 10),
            // Theme Toggle Button
            _buildIconButton(
                isDark ? CupertinoIcons.sun_max_fill : CupertinoIcons.moon_fill, 
                isDark, 
                onTap: () {
                    provider.toggleTheme();
                }
            ),
            const SizedBox(width: 10),
            _buildIconButton(CupertinoIcons.add, isDark, isGradient: true, onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AddEditTaskScreen()));
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildWorkspaceSelector(TaskProvider provider, bool isDark) {
    return Row(
      children: [
        Icon(CupertinoIcons.briefcase, color: Theme.of(context).unselectedWidgetColor, size: 18),
        const SizedBox(width: 8),
        DropdownButton<String>(
          value: provider.activeWorkspace,
          dropdownColor: Theme.of(context).cardColor,
          icon: Icon(CupertinoIcons.chevron_down, color: Theme.of(context).unselectedWidgetColor, size: 14),
          underline: const SizedBox(),
          items: <String>['Personal', 'Work', 'University'].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
            );
          }).toList(),
          onChanged: (newValue) {
            if (newValue != null) provider.setWorkspace(newValue);
          },
        ),
      ],
    );
  }

  Widget _buildIconButton(IconData icon, bool isDark, {bool isGradient = false, VoidCallback? onTap}) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isGradient ? null : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          gradient: isGradient ? LinearGradient(colors: [primary, secondary]) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? Colors.white12 : Colors.black12),
          boxShadow: isGradient ? [BoxShadow(color: primary.withOpacity(0.4), blurRadius: 8)] : null,
        ),
        child: Icon(icon, color: isGradient ? Colors.white : Theme.of(context).iconTheme.color, size: 22),
      ),
    );
  }

  Widget _buildCategoryTabs(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildTabItem('Today', 0, Theme.of(context).colorScheme.primary, isDark),
          _buildTabItem('Completed', 1, const Color(0xFF4CD964), isDark),
          _buildTabItem('Repeated Tasks', 2, const Color(0xFFBF5AF2), isDark),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index, Color color, bool isDark) {
    bool isActive = _selectedIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.15) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? color : (isDark ? Colors.white12 : Colors.black12), width: isActive ? 2 : 1),
          boxShadow: isActive ? [BoxShadow(color: color.withOpacity(0.2), blurRadius: 5)] : null,
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(
                color: isActive ? (isDark ? Colors.white : Colors.black87) : (isDark ? Colors.white60 : Colors.black54), 
                fontWeight: FontWeight.bold)
            ),
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Text('Active', style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(double progress, int completed, int total, bool isDark) {
    return _GlassCard(
      isDark: isDark,
      child: Row(
        children: [
          _buildCircularProgress(progress, isDark),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Current Progress', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('Tasks left: ${total - completed}/$total', style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(double progress, bool isDark) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 75,
          height: 75,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 10,
            backgroundColor: isDark ? Colors.white10 : Colors.black12,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
        ),
        Text('${(progress * 100).toInt()}%', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildQuickActions(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _GlassCard(
            isDark: isDark,
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                Icon(CupertinoIcons.calendar, color: Theme.of(context).colorScheme.secondary, size: 24),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overview', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                    Text('Today', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _GlassCard(
            isDark: isDark,
            padding: const EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Focus', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                Transform.scale(
                  scale: 0.8,
                  child: CupertinoSwitch(
                      value: true, 
                      onChanged: (v) {}, 
                      activeColor: Theme.of(context).colorScheme.primary
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskView() {
    if (_selectedIndex == 0) return TodayTasksScreen();
    if (_selectedIndex == 1) return CompletedTasksScreen();
    return RepeatedTasksScreen();
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(CupertinoIcons.house_fill, true, isDark),
          _buildNavItem(CupertinoIcons.square_grid_2x2, false, isDark),
          _buildNavItem(CupertinoIcons.calendar, false, isDark),
          _buildNavItem(CupertinoIcons.bell, false, isDark),
          _buildNavItem(CupertinoIcons.person, false, isDark),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isActive, bool isDark) {
    final primary = Theme.of(context).colorScheme.primary;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: isActive ? primary : (isDark ? Colors.white30 : Colors.black38), size: 26),
        if (isActive)
          Container(
            margin: const EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: primary, 
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: primary, blurRadius: 4)],
            ),
          ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final bool isDark;
  
  const _GlassCard({required this.child, this.padding = const EdgeInsets.all(20), required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.08) : Colors.black.withOpacity(0.05)),
          ),
          child: child,
        ),
      ),
    );
  }
}
