String authHomeRouteForRole(String role) => switch (role) {
  'driver' => '/driver/home',
  _ => '/passenger/home',
};