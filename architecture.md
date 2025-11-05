# EthioRide - E-Hailing App Architecture

## Overview
EthioRide is a production-ready e-hailing application for Ethiopia with three main user roles: Passenger, Driver, and Admin.

## Technical Stack
- **Framework**: Flutter/Dart
- **Maps**: Google Maps API (simulated with custom map UI)
- **Storage**: Local Storage (SharedPreferences)
- **Architecture**: MVVM pattern with service layer
- **Design**: Modern, minimal UI with Ethiopian-inspired colors (green, yellow, red)

## Color Palette
- Primary Green: #25A556 (Ethiopian flag green)
- Accent Yellow: #FCD116 (Ethiopian flag yellow)
- Accent Red: #EF2B2D (Ethiopian flag red)
- Background: White (#FFFFFF) / Dark (#0F1419)
- Text: Dark Gray / Light Gray

## Data Models (lib/models)
1. **User** - Base user model with role (passenger/driver/admin)
2. **Ride** - Ride request with status, locations, fare
3. **Driver** - Driver profile with vehicle details, status, earnings
4. **Location** - Location data with lat/long, address
5. **Payment** - Payment details with method and amount
6. **Message** - Chat messages between passenger and driver

## Services (lib/services)
1. **UserService** - User authentication and profile management with sample data
2. **RideService** - Ride requests, matching, tracking with fare calculation
3. **DriverService** - Driver availability, earnings, nearby driver detection

## Screen Structure

### Passenger App
1. **SplashScreen** - EthioRide logo with loading animation
2. **AuthScreen** - Login/Signup with email/phone
3. **PassengerHomeScreen** - Map view, request ride, nearby drivers
4. **RideRequestScreen** - Pickup/destination selection, fare estimation
5. **ActiveRideScreen** - Live tracking, driver info, chat/call
6. **PaymentScreen** - Payment method selection
7. **RideHistoryScreen** - Past rides list
8. **PassengerProfileScreen** - Profile management

### Driver App
1. **DriverAuthScreen** - Driver registration and verification
2. **DriverHomeScreen** - Online/offline toggle, earnings dashboard
3. **RideRequestsScreen** - Incoming ride requests
4. **ActiveTripScreen** - Navigation, start/end trip
5. **EarningsScreen** - Earnings breakdown, ride history
6. **DriverProfileScreen** - Driver profile and vehicle info

### Admin Dashboard
1. **AdminLoginScreen** - Admin authentication
2. **AdminHomeScreen** - Overview statistics
3. **ManageUsersScreen** - Passenger and driver management
4. **ManageRidesScreen** - All rides view, live map
5. **RevenueReportsScreen** - Revenue analytics
6. **DisputesScreen** - Handle feedback and disputes

## Widget Components (lib/widgets)
1. **CustomButton** - Reusable button with Ethiopian styling
2. **CustomTextField** - Input field with validation
3. **RideCard** - Ride information card
4. **DriverCard** - Driver profile card
5. **MapView** - Custom map interface
6. **StatusBadge** - Status indicators
7. **EthiopianFlag** - Decorative flag element
8. **ChatBubble** - Message bubble for chat
9. **EarningsCard** - Earnings display card
10. **UserAvatar** - Circular avatar with placeholder

## Implementation Steps
1. ✅ Update theme with Ethiopian-inspired colors
2. ✅ Create all data models with proper methods
3. ✅ Implement service layer with local storage
4. ✅ Build splash screen with logo
5. ✅ Create authentication screens
6. ✅ Build passenger app screens
7. ✅ Build driver app screens
8. ✅ Build admin dashboard screens
9. ✅ Create reusable widget components
10. ✅ Add sample data for testing
11. ✅ Test and debug with compile_project

## Sample Test Data
- **Locations**: Addis Ababa (Bole, Piassa, Merkato, CMC, Megenagna, Hayahulet, Arat Kilo, Lideta)
- **Users**: 5 passengers, 10 drivers, 1 admin (all with Ethiopian names)
- **Rides**: 5 sample completed rides with various fares
- **Drivers**: Mix of online/offline, different ratings, vehicle details

## Test Credentials
- **Passenger**: Any email with role "passenger" selected
- **Driver**: Any email with role "driver" selected  
- **Admin**: admin@ethioride.com with role "admin" selected
- **Password**: Any password works (demo mode)

## Key Features Implemented
✅ Role-based authentication (Passenger/Driver/Admin)
✅ Passenger: Request rides, track active trips, payment simulation, ride history
✅ Driver: Online/offline status, accept ride requests, active trip management, earnings dashboard
✅ Admin: User management, ride monitoring, revenue statistics
✅ Real-time ride status updates with polling
✅ Phone call integration with url_launcher
✅ Ethiopian-inspired UI with green/yellow/red color accents
✅ Local storage with SharedPreferences for all data
✅ Fare calculation based on distance
✅ Sample data with realistic Ethiopian locations and names
