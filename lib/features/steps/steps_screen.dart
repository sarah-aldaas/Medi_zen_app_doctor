import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:medi_zen_app_doctor/base/extensions/localization_extensions.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepsScreen extends StatefulWidget {
  const StepsScreen({super.key});

  @override
  State<StepsScreen> createState() => _StepsScreenState();
}

class _StepsScreenState extends State<StepsScreen> with WidgetsBindingObserver {
  // State variables
  StreamSubscription<PedestrianStatus>? pedestrianSubscription;
  Timer? stepTimer;
  Timer? sessionTimer;
  Random random = Random();

  // App state
  String status = "stopped";
  int _steps = 0;
  int todaySteps = 0;
  bool isWalking = false;
  bool _isPermissionGranted = false;
  bool _isLoading = false;
  DateTime? _walkingStartTime;
  int currentWalkingSession = 0;
  double walkingPace = 1.0;
  int consecutiveSteps = 0;
  double calories = 0;
  double distance = 0;
  int dailyGoal = 1000;
  List<Map<String, dynamic>> weeklyData = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
    testSensors();
  }

  void testSensors() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      print('Accelerometer: $event');
    });
  }

  @override
  void dispose() {
    pedestrianSubscription?.cancel();
    stepCountSubscription?.cancel();
    stepTimer?.cancel();
    sessionTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _isPermissionGranted) {
      _setupMovementDetection();
    }
  }

  Future<void> _checkPermissions() async {
    setState(() => _isLoading = true);

    final status = await Permission.activityRecognition.request();
    final isGranted = status == PermissionStatus.granted;

    setState(() {
      _isPermissionGranted = isGranted;
      _isLoading = false;
    });

    if (isGranted) {
      await _initializeApp();
      _setupMovementDetection();
    }
  }

  Future<void> _initializeApp() async {
    await _loadDailyData();
    await _loadTodaySteps();
  }

  late StreamSubscription<StepCount> stepCountSubscription;

  void _setupMovementDetection() {
    // Listen for walking/stopped status
    pedestrianSubscription?.cancel();
    pedestrianSubscription = Pedometer.pedestrianStatusStream.listen(
          (PedestrianStatus event) {
        _handleMovementChange(event.status);
      },
      onError: (error) {
        print("Pedestrian Status Error: $error");
      },
    );

    stepCountSubscription = Pedometer.stepCountStream.listen(
          (StepCount event) {
        setState(() {
          _steps = event.steps;
          todaySteps = event.steps;
          _calculateMetrics();
        });
        _saveSteps();
      },
      onError: (error) {
        print("Step Count Error: $error");
      },
    );
  }

  void _handleMovementChange(String newStatus) async {
    if (newStatus != status) {
      setState(() => status = newStatus);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('status', newStatus);

      if (newStatus == "walking" && !isWalking) {
        _startWalkingSession();
      } else if (newStatus == "stopped" && isWalking) {
        _stopWalkingSession();
      }
    }
  }

  void _startWalkingSession() {
    setState(() {
      isWalking = true;
      _walkingStartTime = DateTime.now();
      currentWalkingSession++;
      walkingPace = 0.85 + (random.nextDouble() * 0.3);
      consecutiveSteps = 0;
    });
    _startStepCounting();
  }

  void _stopWalkingSession() {
    setState(() {
      isWalking = false;
      _walkingStartTime = null;
    });
    stepTimer?.cancel();
    sessionTimer?.cancel();
  }

  void _startStepCounting() {
    stepTimer?.cancel();
    int baseInterval = (600 / walkingPace).round();

    stepTimer = Timer.periodic(Duration(milliseconds: baseInterval), (timer) {
      if (!isWalking) {
        timer.cancel();
        return;
      }

      double stepChance = _calculateStepProbability();
      if (random.nextDouble() < stepChance) {
        setState(() {
          _steps++;
          consecutiveSteps++;
          _calculateMetrics();
        });
        _saveSteps();
      }

      if (consecutiveSteps > 0 && consecutiveSteps % 20 == 0) {
        double adjustment = 0.95 + (random.nextDouble() * 0.1);
        walkingPace = (walkingPace * adjustment).clamp(0.7, 1.3);
        _startStepCounting();
      }
    });

    _startSessionPatterns();
  }

  double _calculateStepProbability() {
    double baseProbability = consecutiveSteps < 5 ? 0.8 : 0.92;
    double randomVariation = 0.95 + (random.nextDouble() * 0.1);
    return (baseProbability * randomVariation).clamp(0.0, 1.0);
  }

  void _startSessionPatterns() {
    sessionTimer = Timer.periodic(Duration(seconds: 15 + random.nextInt(30)), (timer) {
      if (!isWalking) {
        timer.cancel();
        return;
      }

      if (random.nextDouble() < 0.2) {
        stepTimer?.cancel();
      }

      Timer(Duration(seconds: 1 + random.nextInt(3)), () {
        if (isWalking) _startStepCounting();
      });
    });
  }

  void _calculateMetrics() {
    setState(() {
      calories = _steps * 0.04;
      distance = (_steps * 0.762) / 1000;
    });
  }

  String _getDateKey() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  Future<void> _loadTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey();
    final lastDate = prefs.getString('lastDate') ?? '';

    if (lastDate == today) {
      setState(() {
        todaySteps = prefs.getInt('steps_$today') ?? 0;
        _steps = todaySteps;
      });
    } else {
      setState(() {
        todaySteps = 0;
        _steps = 0;
      });
      await prefs.setString('lastDate', today);
      await prefs.setInt('steps_$today', 0);
    }
    _calculateMetrics();
  }

  Future<void> _saveSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _getDateKey();
    await prefs.setInt('steps_$today', _steps);
    await prefs.setString('lastDate', today);
  }

  Future<void> _loadDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dailyGoal = prefs.getInt('dailyGoal') ?? 1000;
    });
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    final prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> weekData = [];

    for (int i = 6; i >= 0; i--) {
      final date = DateTime.now().subtract(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      final steps = prefs.getInt('steps_$dateStr') ?? 0;

      weekData.add({
        'date': date,
        'steps': steps,
        'day': DateFormat('E').format(date),
      });
    }

    setState(() => weeklyData = weekData);
  }

  void _showGoalDialog() {
    final controller = TextEditingController(text: dailyGoal.toString());
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text("step_counter.set_daily_goal".tr(context), style: TextStyle(color: theme.textTheme.titleLarge?.color)),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: "step_counter.daily_steps_goal".tr(context),
            labelStyle: TextStyle(color: theme.textTheme.bodyLarge?.color),
          ),
          style: TextStyle(color: theme.textTheme.bodyLarge?.color),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("step_counter.cancel".tr(context), style: TextStyle(color: theme.textTheme.bodyLarge?.color)),
          ),
          ElevatedButton(
            onPressed: () async {
              final newGoal = int.tryParse(controller.text) ?? dailyGoal;
              final prefs = await SharedPreferences.getInstance();
              await prefs.setInt('dailyGoal', newGoal);
              setState(() => dailyGoal = newGoal);
              Navigator.pop(context);
            },
            child: Text("step_counter.save".tr(context)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progress = dailyGoal > 0 ? (_steps / dailyGoal).clamp(0.0, 1.0) : 0.0;
    final primaryColor = theme.primaryColor;
    final onPrimary = theme.colorScheme.onPrimary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: Text("step_counter.title".tr(context), style: TextStyle(color: onSurface)),
        actions: _isPermissionGranted
            ? [IconButton(
            icon: Icon(Icons.settings, color: onSurface),
            onPressed: _showGoalDialog)]
            : [],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : !_isPermissionGranted
          ? _buildPermissionRequest(theme)
          : _buildMainContent(progress, theme, primaryColor, onPrimary, surface, onSurface),
    );
  }

  Widget _buildPermissionRequest(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_walk, size: 100, color: theme.colorScheme.primary),
          SizedBox(height: 20),
          Text(
            "step_counter.permission_required".tr(context),
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "step_counter.permission_message".tr(context),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
          ),
          SizedBox(height: 30),
          ElevatedButton(
            onPressed: _checkPermissions,
            child: Text("step_counter.grant_permission".tr(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(
      double progress,
      ThemeData theme,
      Color primaryColor,
      Color onPrimary,
      Color surface,
      Color onSurface,
      ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        children: [
          // Progress circle
          Container(
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.8),
                    primaryColor.withOpacity(1.0)
                  ]
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: primaryColor.withOpacity(0.2), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 12,
                        backgroundColor: onPrimary.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation(onPrimary),
                      ),
                    ),
                    Column(
                      children: [
                        Icon(
                          status == "walking" ? Icons.directions_walk : Icons.accessibility_new,
                          size: 50,
                          color: onPrimary,
                        ),
                        SizedBox(height: 10),
                        Text(
                          "$_steps",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: onPrimary,
                          ),
                        ),
                        Text(
                          "of $dailyGoal steps",
                          style: TextStyle(
                            fontSize: 14,
                            color: onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                  decoration: BoxDecoration(
                    color: status == 'walking'
                        ? Colors.green
                        : onPrimary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status == 'walking' ?  "step_counter.walking".tr(context)
                        : "step_counter.stopped".tr(context),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20),

          // Stats cards
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                icon: Icons.local_fire_department,
                value: calories.toStringAsFixed(1),
                unit: "step_counter.stats.calories".tr(context),
                color: Colors.orange,
                theme: theme,
              ),
              _buildStatCard(
                icon: Icons.straighten,
                value: distance.toStringAsFixed(2),
                unit: "step_counter.stats.distance".tr(context),
                color: Colors.purple,
                theme: theme,
              ),
              _buildStatCard(
                icon: Icons.timer,
                value: (_steps * 0.008).toStringAsFixed(0),
                unit: "step_counter.stats.time".tr(context),
                color: Colors.teal,
                theme: theme,
              ),
            ],
          ),

          SizedBox(height: 30),

          // Weekly chart
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "step_counter.weekly_activity".tr(context),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: weeklyData.map((data) {
                      final height = (data['steps'] / dailyGoal * 100).clamp(10.0, 100.0);
                      final isToday = DateFormat('yyyy-MM-dd').format(data['date']) ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now());

                      return Column(
                        children: [
                          Container(
                            width: 30,
                            height: height,
                            decoration: BoxDecoration(
                              gradient: isToday
                                  ? LinearGradient(
                                  colors: [
                                    primaryColor.withOpacity(0.8),
                                    primaryColor.withOpacity(1.0)
                                  ])
                                  : null,
                              color: !isToday
                                  ? theme.dividerColor
                                  : null,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            data['day'],
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontWeight: isToday ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String unit,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width * 0.25,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: theme.shadowColor.withOpacity(0.1), blurRadius: 5)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 30),
          SizedBox(height: 10),
          Text(
            value,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            unit,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}