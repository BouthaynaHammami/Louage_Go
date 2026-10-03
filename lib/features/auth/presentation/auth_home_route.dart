String authHomeRouteForRole(String role) => switch (role) {
  'driver' => '/driver/home',
  'admin' => '/admin/dashboard',
  _ => '/passenger/home',
};