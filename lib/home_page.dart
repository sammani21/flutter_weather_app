import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather/weather.dart';
import 'consts.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Import the reusable components
import 'components/today_info.dart';
import 'components/hourly_forecast_item.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _locationName = 'Getting location...';
  bool _isLoading = true;
  Weather? _weather;
  List<Weather> _hourlyForecast = [];
  final WeatherFactory _wf = WeatherFactory(OPEN_WEATHER_API_KEY);
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchSuggestions = [];
  bool _isSearchingSuggestions = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocationSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _isSearchingSuggestions = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse(
          'http://api.openweathermap.org/geo/1.0/direct?q=$query&limit=5&appid=$OPEN_WEATHER_API_KEY',
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _searchSuggestions =
              data
                  .map(
                    (item) => {
                      'name': item['name'],
                      'country': item['country'],
                      'state': item['state'],
                      'lat': item['lat'],
                      'lon': item['lon'],
                    },
                  )
                  .toList();
          _isSearchingSuggestions = true;
        });
      }
    } catch (e) {
      print('Error fetching suggestions: $e');
      setState(() {
        _searchSuggestions = [];
        _isSearchingSuggestions = false;
      });
    }
  }

  void _onSearchChanged() {
    _fetchLocationSuggestions(_searchController.text);
  }

  Future<void> _fetchHourlyForecast(double lat, double lon) async {
    try {
      List<Weather> forecast = await _wf.fiveDayForecastByLocation(lat, lon);

      // Sort and filter the forecast for next 24 hours
      final now = DateTime.now();
      final next24Hours = now.add(const Duration(hours: 24));

      setState(() {
        _hourlyForecast =
            forecast
                .where(
                  (weather) =>
                      weather.date!.isAfter(now) &&
                      weather.date!.isBefore(next24Hours),
                )
                .toList()
              ..sort((a, b) => a.date!.compareTo(b.date!));
      });
    } catch (e) {
      print('Error fetching hourly forecast: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      var status = await Permission.location.request();

      if (status.isDenied) {
        setState(() {
          _locationName = 'Location permission denied';
          _isLoading = false;
        });
        return;
      }

      if (status.isPermanentlyDenied) {
        setState(() {
          _locationName = 'Location permission permanently denied';
          _isLoading = false;
        });
        if (mounted) {
          showDialog(
            context: context,
            builder:
                (context) => AlertDialog(
                  title: const Text('Location Permission Required'),
                  content: const Text(
                    'Please enable location permission in app settings to continue.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        openAppSettings();
                        Navigator.pop(context);
                      },
                      child: const Text('Open Settings'),
                    ),
                  ],
                ),
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get weather data
      Weather weather = await _wf.currentWeatherByLocation(
        position.latitude,
        position.longitude,
      );

      // Get hourly forecast
      await _fetchHourlyForecast(position.latitude, position.longitude);

      setState(() {
        _weather = weather;
        _locationName = weather.areaName ?? 'Unknown Location';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationName = 'Error getting location: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _searchLocation(Map<String, dynamic> location) async {
    setState(() {
      _isLoading = true;
      _isSearching = false;
      _searchSuggestions = [];
    });

    try {
      Weather weather = await _wf.currentWeatherByLocation(
        location['lat'],
        location['lon'],
      );

      // Get hourly forecast for searched location
      await _fetchHourlyForecast(location['lat'], location['lon']);

      setState(() {
        _weather = weather;
        _locationName = '${location['name']}, ${location['country']}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _locationName = 'Location not found';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF4A148C).withOpacity(0.8),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [const Color(0xFF4A148C), const Color(0xFF6A1B9A)],
            ),
          ),
        ),
        title:
            _isSearching
                ? Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search location...',
                      hintStyle: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _isSearching = false;
                            _searchSuggestions = [];
                          });
                        },
                      ),
                    ),
                    onSubmitted: (value) {
                      if (_searchSuggestions.isNotEmpty) {
                        _searchLocation(_searchSuggestions[0]);
                      }
                    },
                    autofocus: true,
                  ),
                )
                : const Text(
                  'Weather App',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
        actions: [
          if (!_isSearching)
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.search, size: 24, color: Colors.white),
                onPressed: () {
                  setState(() {
                    _isSearching = true;
                  });
                },
                tooltip: 'Search',
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [const Color(0xFF4A148C), const Color(0xFF6A1B9A)],
              ),
            ),
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                    : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            margin: const EdgeInsets.only(top: 110, bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(32),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Location and Time
                                Text(
                                  _locationName,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _weather != null && _weather!.date != null
                                      ? DateFormat(
                                        'EEEE, h a',
                                      ).format(_weather!.date!.toLocal())
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                // Weather Icon, Temp, Desc
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _getWeatherIcon(_weather?.weatherMain),
                                      size: 64,
                                      color: Colors.amber[600],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: Text(
                                    _weather != null &&
                                            _weather!.temperature != null
                                        ? '${_weather!.temperature!.celsius!.round()}°'
                                        : '--',
                                    style: const TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Center(
                                  child: Text(
                                    _weather?.weatherDescription ?? '',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Today Card
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Today',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    TodayInfo(
                                      label: 'Pressure',
                                      value: _weather?.pressure != null
                                          ? '${_weather!.pressure}mb'
                                          : '--',
                                    ),
                                    TodayInfo(
                                      label: 'Humidity',
                                      value: _weather?.humidity != null
                                          ? '${_weather!.humidity}%'
                                          : '--',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),
                                // Hourly Forecast
                                _hourlyForecast.isNotEmpty
                                    ? SizedBox(
                                        height: 80,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: _hourlyForecast.length,
                                          itemBuilder: (context, index) {
                                            final weather =
                                                _hourlyForecast[index];
                                            return HourlyForecastItem(
                                              weather: weather,
                                              getWeatherIcon: _getWeatherIcon,
                                            );
                                          },
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                          // More Weather Details Card
                          if (_weather != null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              margin: const EdgeInsets.only(bottom: 24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'More Details',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TodayInfo(
                                        label: 'Wind',
                                        value: _weather!.windSpeed != null
                                            ? '${_weather!.windSpeed} m/s'
                                            : '--',
                                      ),
                                      TodayInfo(
                                        label: 'Wind Dir',
                                        value: _weather!.windDegree != null
                                            ? '${_weather!.windDegree}°'
                                            : '--',
                                      ),
                                      TodayInfo(
                                        label: 'Feels Like',
                                        value: _weather!.tempFeelsLike?.celsius != null
                                            ? '${_weather!.tempFeelsLike!.celsius!.round()}°'
                                            : '--',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TodayInfo(
                                        label: 'Min Temp',
                                        value: _weather!.tempMin?.celsius != null
                                            ? '${_weather!.tempMin!.celsius!.round()}°'
                                            : '--',
                                      ),
                                      TodayInfo(
                                        label: 'Max Temp',
                                        value: _weather!.tempMax?.celsius != null
                                            ? '${_weather!.tempMax!.celsius!.round()}°'
                                            : '--',
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      TodayInfo(
                                        label: 'Sunrise',
                                        value: _weather!.sunrise != null
                                            ? DateFormat('h:mm a').format(
                                                _weather!.sunrise!.toLocal(),
                                              )
                                            : '--',
                                      ),
                                      TodayInfo(
                                        label: 'Sunset',
                                        value: _weather!.sunset != null
                                            ? DateFormat('h:mm a').format(
                                                _weather!.sunset!.toLocal(),
                                              )
                                            : '--',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
          ),
          // Search overlay
          if (_isSearching)
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Colors.black),
                        decoration: InputDecoration(
                          hintText: 'Search location...',
                          hintStyle: TextStyle(
                            color: Colors.black.withOpacity(0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.clear, color: Colors.black),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _isSearching = false;
                                _searchSuggestions = [];
                              });
                            },
                          ),
                        ),
                        onSubmitted: (value) {
                          if (_searchSuggestions.isNotEmpty) {
                            _searchLocation(_searchSuggestions[0]);
                          }
                        },
                        autofocus: true,
                      ),
                    ),
                  ),
                  Expanded(
                    child:
                        _isSearchingSuggestions && _searchSuggestions.isNotEmpty
                            ? ListView.builder(
                                itemCount: _searchSuggestions.length,
                                itemBuilder: (context, index) {
                                  final location = _searchSuggestions[index];
                                  final state =
                                      location['state'] != null
                                          ? ', ${location['state']}'
                                          : '';
                                  return ListTile(
                                    leading: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.blue.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    title: Text(
                                      '${location['name']}$state',
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    subtitle: Text(
                                      location['country'],
                                      style: TextStyle(
                                        color: Colors.black.withOpacity(0.6),
                                      ),
                                    ),
                                    onTap: () => _searchLocation(location),
                                  );
                                },
                              )
                            : _searchController.text.isNotEmpty
                                ? const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'No locations found',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(16.0),
                                      child: Text(
                                        'Start typing to search locations',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // No longer needed:
  // Widget _buildTodayInfo(String label, String value) { ... }

  IconData _getWeatherIcon(String? weatherMain) {
    switch (weatherMain?.toLowerCase()) {
      case 'clear':
        return Icons.wb_sunny;
      case 'clouds':
        return Icons.cloud;
      case 'rain':
        return Icons.grain;
      case 'snow':
        return Icons.ac_unit;
      case 'thunderstorm':
        return Icons.flash_on;
      case 'drizzle':
        return Icons.grain;
      case 'mist':
      case 'smoke':
      case 'haze':
      case 'dust':
      case 'fog':
        return Icons.cloud;
      default:
        return Icons.wb_sunny;
    }
  }
}