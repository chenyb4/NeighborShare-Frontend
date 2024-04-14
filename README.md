# NeighborShare App

The application is built using Flutter and serves as a platform for neighbors of the same apartment to share items with each other.

## Getting Started

In order to run the project, you need to configure your local development machine using this guide:
https://docs.flutter.dev/get-started/install

choose your development machine OS and choose Android as the mobile platform. Then install the development environment following this guide.

## Configuring Backend Access
The backend is already hosted online at 78.141.222.233.

To configure the access, first locate the file in lib/config/backend_address.dart. Open the file and fill in "http://78.141.222.233:3000" as the baseURL.


## Running the App
Navigate to the root directory of the project where you can see the lib directory.

Now you can either plugin an Android device with USB debug enabled, or start an emulator, or simply do nothing(then you will have Chrome to test it).

Run the command:
```bash
flutter run lib/main.dart
```
Follow the on-screen instruction if any(in the case that you don't have an emulator running and you don't have a phone plugged in).
Now you should be able to use the app.

