
enum AppRoute {
  splash('/splash', 'splash'),
  login('/login', 'login'),
  register('/register', 'register'),
  heartRate('/heart-rate', 'heartRate'), 
  measuring('/measuring', 'measuring'), 
  statistics('/statistics', 'statistics'), 
  profile('/profile', 'profile'), 
  settings('/profile/settings', 'settings'), 
  myHomePage('/', 'myHomePage'); 

  const AppRoute(this.path, this.name);
  final String path;
  final String name;
}

const String heartRateMeasurementRoute = '/heart-rate-measurement';
const String statisticsRoute = '/statistics';
const String homeRoute = '/home'; 
