import 'package:flutter/material.dart';

enum TrendDirection {
  up,
  down,
  stable,
}

class TrendData {
  final String title;
  final String currentValue;
  final String previousValue;
  final double percentageChange;
  final TrendDirection direction;
  final IconData icon;
  final Color color;
  final String? subtitle;

  TrendData({
    required this.title,
    required this.currentValue,
    required this.previousValue,
    required this.percentageChange,
    required this.direction,
    required this.icon,
    required this.color,
    this.subtitle,
  });

  /// Crea un TrendData comparando dos valores numéricos
  factory TrendData.fromValues({
    required String title,
    required double currentValue,
    required double previousValue,
    required IconData icon,
    required Color color,
    String? subtitle,
    String? valuePrefix,
    String? valueSuffix,
    int decimals = 0,
  }) {
    final change = currentValue - previousValue;
    final percentage = previousValue != 0 
        ? (change / previousValue) * 100 
        : (currentValue > 0 ? 100.0 : 0.0);
    
    TrendDirection direction;
    if (percentage > 0.5) {
      direction = TrendDirection.up;
    } else if (percentage < -0.5) {
      direction = TrendDirection.down;
    } else {
      direction = TrendDirection.stable;
    }

    final prefix = valuePrefix ?? '';
    final suffix = valueSuffix ?? '';

    return TrendData(
      title: title,
      currentValue: '$prefix${currentValue.toStringAsFixed(decimals)}$suffix',
      previousValue: '$prefix${previousValue.toStringAsFixed(decimals)}$suffix',
      percentageChange: percentage.abs(),
      direction: direction,
      icon: icon,
      color: color,
      subtitle: subtitle,
    );
  }

  IconData get trendIcon {
    switch (direction) {
      case TrendDirection.up:
        return Icons.trending_up_rounded;
      case TrendDirection.down:
        return Icons.trending_down_rounded;
      case TrendDirection.stable:
        return Icons.trending_flat_rounded;
    }
  }

  Color get trendColor {
    switch (direction) {
      case TrendDirection.up:
        return Colors.green;
      case TrendDirection.down:
        return Colors.red;
      case TrendDirection.stable:
        return Colors.orange;
    }
  }

  String get trendText {
    if (direction == TrendDirection.stable) {
      return 'Sin cambios';
    }
    return '${percentageChange.toStringAsFixed(1)}%';
  }
}
