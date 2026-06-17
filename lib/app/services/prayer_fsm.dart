import '../data/models/analysis_report.dart';

class PrayerFSM {
  final String prayerName;
  final int expectedRakahs;

  // State variables
  int _rakahCount = 0;
  final List<PrayerMistake> _mistakes = [];
  final List<PrayerStep> _steps = [];
  Pose _lastPose = Pose.unknown;

  // Track poses in the current Rak'ah (no consecutive duplicates)
  List<Pose> _currentRakahPoses = [];

  // Track sitting duration for Jalsa/Tashahhud distinction
  Duration _sittingStartTime = Duration.zero;
  bool _isRakahCompletedForCurrentSitting = false;

  PrayerFSM({required this.prayerName})
      : expectedRakahs = _getExpectedRakahs(prayerName);

  static int _getExpectedRakahs(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return 2;
      case 'maghrib':
        return 3;
      case 'dhuhr':
      case 'asr':
      case 'isha':
      default:
        return 4;
    }
  }

  void update(Pose pose, Duration timestamp, double confidence) {
    if (pose == Pose.unknown) {
      return;
    }

    // Handle duplicate poses
    if (pose == _lastPose) {
      // Time-based promotion for Jalsa -> Tashahhud
      if (pose == Pose.tashahhud && !_isRakahCompletedForCurrentSitting) {
        final sittingDuration = timestamp - _sittingStartTime;
        if (sittingDuration.inSeconds >= 5) {
          _completeRakah(Pose.tashahhud, timestamp);
          _isRakahCompletedForCurrentSitting = true;
        }
      }
      return;
    }

    // Log the step
    _steps.add(
      PrayerStep(pose: pose, timestamp: timestamp, confidence: confidence),
    );

    // Initial setup if we start the session
    if (_lastPose == Pose.unknown) {
      _lastPose = pose;
      _currentRakahPoses.add(pose);
      if (pose != Pose.qayyam) {
        _mistakes.add(
          PrayerMistake(
            description: "Started prayer in unexpected posture: ${_getPoseName(pose)}",
            timestamp: timestamp,
          ),
        );
      }
      return;
    }

    // Validate transition
    _validateTransition(_lastPose, pose, timestamp);

    // Track sitting start time for Tashahhud
    if (pose == Pose.tashahhud) {
      _sittingStartTime = timestamp;
      _isRakahCompletedForCurrentSitting = false;
    }

    // Check if the transition completes a Rak'ah
    bool completed = false;

    // Condition 1: Transitioning from Sujud to Qayyam (Standing up)
    if (_lastPose == Pose.sujud && pose == Pose.qayyam) {
      completed = true;
    }
    // Condition 2: Transitioning from Sujud to Tashahhud (Sitting) after 2+ Sujuds
    else if (_lastPose == Pose.sujud && pose == Pose.tashahhud) {
      int sujudCount = _currentRakahPoses.where((p) => p == Pose.sujud).length;
      if (sujudCount >= 2) {
        completed = true;
      }
    }
    // Condition 3: Transitioning from Tashahhud (Jalsa) to Qayyam when we had a Sujud
    else if (_lastPose == Pose.tashahhud && pose == Pose.qayyam) {
      if (_currentRakahPoses.contains(Pose.sujud)) {
        completed = true;
      }
    }

    if (completed) {
      _completeRakah(pose, timestamp);
      if (pose == Pose.tashahhud) {
        _isRakahCompletedForCurrentSitting = true;
      }
    } else {
      // Add to current Rak'ah poses if it's not a duplicate of the last recorded pose
      if (_currentRakahPoses.isEmpty || _currentRakahPoses.last != pose) {
        _currentRakahPoses.add(pose);
      }
    }

    _lastPose = pose;
  }

  void _validateTransition(Pose from, Pose to, Duration timestamp) {
    if (from == Pose.qayyam && to == Pose.tashahhud) {
      _mistakes.add(
        PrayerMistake(
          description: "Unexpected sitting (Tashahhud) directly from standing (Qiyam)",
          timestamp: timestamp,
        ),
      );
    } else if (from == Pose.ruku && to == Pose.sujud) {
      _mistakes.add(
        PrayerMistake(
          description: "Went directly to prostration (Sujud) from bowing (Ruku) without standing upright",
          timestamp: timestamp,
        ),
      );
    } else if (from == Pose.ruku && to == Pose.tashahhud) {
      _mistakes.add(
        PrayerMistake(
          description: "Unexpected sitting (Tashahhud) directly from bowing (Ruku)",
          timestamp: timestamp,
        ),
      );
    } else if (from == Pose.sujud && to == Pose.ruku) {
      _mistakes.add(
        PrayerMistake(
          description: "Unexpected bowing (Ruku) directly from prostration (Sujud)",
          timestamp: timestamp,
        ),
      );
    } else if (from == Pose.tashahhud && to == Pose.ruku) {
      _mistakes.add(
        PrayerMistake(
          description: "Unexpected bowing (Ruku) directly from sitting (Tashahhud)",
          timestamp: timestamp,
        ),
      );
    }
  }

  void _completeRakah(Pose endPose, Duration timestamp) {
    int currentRakahNum = _rakahCount + 1;

    // 1. Analyze mistakes in the current Rak'ah
    bool hasRuku = _currentRakahPoses.contains(Pose.ruku);
    bool hasSujud = _currentRakahPoses.contains(Pose.sujud);
    int countSujud = _currentRakahPoses.where((p) => p == Pose.sujud).length;

    if (!hasRuku) {
      _mistakes.add(
        PrayerMistake(
          description: "Missed bowing (Ruku) in Rak'ah $currentRakahNum",
          timestamp: timestamp,
        ),
      );
    } else if (hasSujud) {
      // Check if they stood up after Ruku before going to Sujud
      bool hasStandingAfterRuku = false;
      int rukuIdx = _currentRakahPoses.indexOf(Pose.ruku);
      if (rukuIdx != -1) {
        int qayyamIdx = _currentRakahPoses.indexOf(Pose.qayyam, rukuIdx);
        if (qayyamIdx != -1) {
          int sujudIdx = _currentRakahPoses.indexOf(Pose.sujud, qayyamIdx);
          if (sujudIdx != -1) {
            hasStandingAfterRuku = true;
          }
        }
      }
      if (!hasStandingAfterRuku) {
        _mistakes.add(
          PrayerMistake(
            description: "Missed standing upright after bowing (Ruku) in Rak'ah $currentRakahNum",
            timestamp: timestamp,
          ),
        );
      }
    }

    if (countSujud == 0) {
      _mistakes.add(
        PrayerMistake(
          description: "No prostrations (Sujud) detected in Rak'ah $currentRakahNum",
          timestamp: timestamp,
        ),
      );
    } else if (countSujud == 1) {
      _mistakes.add(
        PrayerMistake(
          description: "Only 1 prostration detected in Rak'ah $currentRakahNum (Jalsa or second prostration was missed)",
          timestamp: timestamp,
        ),
      );
    } else if (countSujud > 2) {
      _mistakes.add(
        PrayerMistake(
          description: "More than 2 prostrations detected in Rak'ah $currentRakahNum",
          timestamp: timestamp,
        ),
      );
    }

    // Verify structure based on expected prayer transitions
    // If it's the last Rak'ah of the selected prayer:
    if (currentRakahNum == expectedRakahs) {
      if (endPose != Pose.tashahhud) {
        _mistakes.add(
          PrayerMistake(
            description: "Stood up after the final Rak'ah instead of sitting for Final Tashahhud",
            timestamp: timestamp,
          ),
        );
      }
    }
    // If it's Rak'ah 2 in a 3 or 4 Rak'ah prayer:
    else if (currentRakahNum == 2 && expectedRakahs > 2) {
      if (endPose != Pose.tashahhud) {
        _mistakes.add(
          PrayerMistake(
            description: "Stood up after Rak'ah 2 instead of sitting for the First Tashahhud",
            timestamp: timestamp,
          ),
        );
      }
    }
    // For other Rak'ahs (Rak'ah 1 in all prayers, Rak'ah 3 in 4-Rak'ah prayer):
    else {
      if (endPose == Pose.tashahhud) {
        _mistakes.add(
          PrayerMistake(
            description: "Sat down in Tashahhud after Rak'ah $currentRakahNum instead of standing up",
            timestamp: timestamp,
          ),
        );
      }
    }

    // 2. Increment Rak'ah count
    _rakahCount++;

    // 3. Reset Rak'ah poses starting with the new state
    _currentRakahPoses = [endPose];
  }

  void completeSessionIfPending(Duration timestamp) {
    // If the session is ended and there is a pending Rak'ah that had some activity but was not completed
    if (_currentRakahPoses.contains(Pose.sujud) || _currentRakahPoses.contains(Pose.ruku)) {
      _completeRakah(_lastPose, timestamp);
    }
  }

  String _getPoseName(Pose pose) {
    switch (pose) {
      case Pose.qayyam:
        return "Qiyam";
      case Pose.ruku:
        return "Ruku";
      case Pose.sujud:
        return "Sujud";
      case Pose.tashahhud:
        return "Tashahhud";
      default:
        return "Unknown";
    }
  }

  AnalysisReport generateReport() {
    return AnalysisReport(
      totalRakahs: _rakahCount,
      isComplete: true,
      mistakes: _mistakes,
      steps: _steps,
    );
  }
}
