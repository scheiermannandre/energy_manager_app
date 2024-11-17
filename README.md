# Instructions for Running the Flutter Application

## Prerequisites

Before you can run the Flutter application, ensure you have the following steps taken:

- installed Flutter SDK and set the PATH environment variable
- installed suitable IDE/Code Editor 
- a simulator/emulator/physical device connected
- Docker is installed


## Run the Flutter Application

1. **Open Your Flutter Project**:
   - Open the folder containing your Flutter project.

3. **Run the API**:
    - Download the resources here https://enpalcorepgtechiv.blob.core.windows.net/tech-interview/flutter/20241029_4a832b05/Take_Home_Challenge_Resources.zip. 
    - In the solar-monitor-api/ directory, build and run the API with Docker using the following commands:
    ```sh
     cd solar-monitor-api/
     docker build -t solar-monitor-api .
     docker run -p 3000:3000 solar-monitor-api
     ```

2. **Run the Application**:
   - Open the terminal
   - make sure you are in the projects directory
   - Run the following command to get the required dependencies:
     ```sh
     flutter pub get
     ```
   - Run the following command to start the application:
     ```sh
     flutter run
     ```

   Alternatively, you can use the "Run" button in your IDE/Code Editor  to start the application.

## Additional Information

- **Testing**: To run unit and widget tests, use the following command:
  ```sh
  flutter test