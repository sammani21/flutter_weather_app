import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';

class HourlyForecastItem extends StatelessWidget {
  final Weather weather;
  final IconData Function(String?) getWeatherIcon;

  const HourlyForecastItem({
    super.key,
    required this.weather,
    required this.getWeatherIcon,
  });

  @override
  Widget build(BuildContext context) {
    final time = DateFormat('HH:00').format(weather.date!);
    return Container(
      width: 60,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Icon(
            getWeatherIcon(weather.weatherMain),
            color: Colors.amber[600],
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            weather.temperature != null
                ? '${weather.temperature!.celsius!.round()}°'
                : '--',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}