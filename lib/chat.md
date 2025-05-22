mjorgecruz: I am getting an error here

GitHub Copilot: It looks like you're getting an error with the HTTP package import. This is likely because you haven't added the HTTP package to your project dependencies.

To fix this:

1. Open your pubspec.yaml file and add the HTTP package under dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0  # Add this line (use the latest version)
  # ...other dependencies
```

2. Run the following command in your terminal to fetch the dependencies:

```
flutter pub get
```

This will install the HTTP package, which is needed for making REST API calls to your Zenoh router.

If you're still encountering errors after this, please share the specific error message so I can help further.

mjorgecruz: why do I use there keyword final here?

GitHub Copilot: The `final` keyword in Dart is used to create a variable that can only be set once. After you initialize a `final` variable, its value cannot be changed. In your code:

```dart
final String newValue = 'tcp/10.21.221.9:7447';
```

Using `final` here provides several benefits:

1. **Immutability** - It prevents accidental reassignment of the value later in the code
2. **Intent signaling** - It communicates to other developers that this value isn't meant to change
3. **Performance** - In some cases, the Dart compiler can optimize code with `final` variables

Since your REST endpoint URL, key expression, and new value are constants that shouldn't change during the lifecycle of your widget state, marking them as `final` is a good practice.

If you needed to change this value based on user input or other runtime conditions, you would use a regular (non-final) variable instead.

mjorgecruz: what is wrong here ,I want to pass an argument to updateZenohState

GitHub Copilot: The issue is with how you're passing the argument to `updateZenohState`. In Flutter's `onPressed` property, you need to provide a function reference (callback), not a function call.

Currently, `updateZenohState("SAE_1_LKAS")` is immediately executing when the UI builds (not when the button is pressed), and trying to assign its result to `onPressed`.

To fix this, wrap your function call in an anonymous function:

```dart
// ...existing code...
ElevatedButton(
  onPressed: () => updateZenohState("SAE_1_LKAS"),
  child: Text('SAE_1 LKAS'),
),
// ...existing code...
```

Alternatively, you can use the curly brace syntax:

```dart
onPressed: () {
  updateZenohState("SAE_1_LKAS");
},
```

This way, the function is only called when the button is actually pressed, not during widget building.

mjorgecruz: the current status should be obtained with a get request, I would receive a JSOn array and I should get the value atributed to the object "value"

GitHub Copilot: You need to add a method to fetch the current status using a GET request. Here's how you can implement this:

```dart
// ...existing code...
String _status = 'Idle';
String _currentValue = 'Unknown';  // Add this to track the current value

// Zenoh router REST endpoint base URL.
final String baseUrl = 'http://10.21.221.9:7447';
  
// The key expression for the stored info
final String keyExpr = 'Vehicle/1/ADAS/ActiveAutonomyLevel';

@override
void initState() {
  super.initState();
  // Fetch the current status when the widget initializes
  getCurrentStatus();
}

Future<void> getCurrentStatus() async {
  setState(() {
    _status = 'Fetching current status...';
  });
  
  final String url = '$baseUrl/$keyExpr';
  
  try {
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      // Parse the JSON response
      final List<dynamic> jsonArray = json.decode(response.body);
      if (jsonArray.isNotEmpty && jsonArray[0] is Map<String, dynamic>) {
        final Map<String, dynamic> data = jsonArray[0];
        final String value = data['value'] ?? 'N/A';
        
        setState(() {
          _currentValue = value;
          _status = 'Current status retrieved successfully';
        });
      } else {
        setState(() {
          _status = 'Invalid response format';
        });
      }
    } else {
      setState(() {
        _status = 'Failed to get status: ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      _status = 'Error fetching status: $e';
    });
  }
}
// ...existing code...
```

Then update your UI to include a display for the current value and a refresh button:

```dart
// ...existing code...
body: Center(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Status: $_status'),
        SizedBox(height: 10),
        Text('Current Autonomy Level: $_currentValue', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => getCurrentStatus(),
          child: Text('Refresh Status'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => updateZenohState("SAE_1_LKAS"),
          child: Text('SAE_1 LKAS'),
        ),
      ],
    ),
  ),
),
// ...existing code...
```

Don't forget to import the dart:convert package at the top of your file:

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
```

This will:
1. Add a GET request function to fetch the current status
2. Parse the JSON response and extract the "value" field
3. Display the current value in the UI
4. Add a refresh button to update the status

mjorgecruz: I need to get the current status everytime it is changed

GitHub Copilot: To ensure the current status is refreshed whenever it changes, you need to:

1. Add a refresh after each update operation
2. Implement periodic polling (optional)

Here's how to modify your code:

```dart
// ...existing code...

Future<void> updateZenohState(String autonomyLevel) async {
  setState(() {
    _status = 'Updating...';
  });
  
  final String url = '$baseUrl/$keyExpr';
  
  try {
    final response = await http.put(
      Uri.parse(url),
      headers: {
        'Content-Type': 'text/plain',
      },
      body: autonomyLevel,
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        _status = 'Update successful: ${response.body}';
      });
      
      // Get the current status after successful update
      await getCurrentStatus();
    } else {
      setState(() {
        _status = 'Failed with status code: ${response.statusCode}';
      });
    }
  } catch (e) {
    setState(() {
      _status = 'Error: $e';
    });
  }
}
```

For the UI, add a refresh button and potentially more control buttons:

```dart
// ...existing code...
body: Center(
  child: Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('Status: $_status'),
        SizedBox(height: 10),
        Text('Current Autonomy Level: $_currentValue', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => getCurrentStatus(),
          child: Text('Refresh Status'),
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => updateZenohState("SAE_1_LKAS"),
          child: Text('SAE_1 LKAS'),
        ),
        // Add more buttons for other autonomy levels if needed
      ],
    ),
  ),
),
```

If you want automatic periodic updates, you can implement a timer in `initState()`:

```dart
import 'dart:async'; // Add this import

// ...existing code...
Timer? _statusTimer;

@override
void initState() {
  super.initState();
  // Fetch initial status
  getCurrentStatus();
  
  // Set up periodic polling every 5 seconds
  _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
    getCurrentStatus();
  });
}

@override
void dispose() {
  // Cancel timer when widget is disposed
  _statusTimer?.cancel();
  super.dispose();
}
```

This ensures your app stays updated with the latest status from the server.

mjorgecruz: why do I use ? here
Timer? _statusTimer;

and does dispose function work as a destructor?
why do I need to use @override?

GitHub Copilot: Your questions cover important Dart and Flutter concepts:

### 1. Why use `?` in `Timer? _statusTimer;`

The `?` indicates that `_statusTimer` is a nullable type. This means:
- It can either hold a Timer object or be null
- This is part of Dart's null safety feature
- You're declaring that this variable might not have a value initially
- This allows you to initialize it later in `initState()` without compiler errors

### 2. Does `dispose` function work as a destructor?

Yes, `dispose()` is essentially Flutter's equivalent of a destructor:
- It's called when the State object is permanently removed from the widget tree
- It's where you should clean up any resources to prevent memory leaks
- Common cleanup tasks include canceling timers, closing streams, and disposing controllers
- In your case, you're properly canceling the timer to prevent it from continuing after the widget is gone

### 3. Why do I need to use `@override`?

The `@override` annotation serves several purposes:
- It explicitly indicates that you're overriding a method from a parent class
- It helps catch errors - if you misspell the method name, the compiler will warn you
- It makes your code more readable for other developers
- In your case, you're overriding methods from the `State` class (`initState()` and `dispose()`)

While technically optional in Dart, using `@override` is considered a best practice for these reasons.

mjorgecruz: I want all buttons to be the same size and be spaced 

GitHub Copilot: To make all buttons the same size and properly spaced, you need to modify your button layout. Here's how you can do it:

```dart
// ...existing code...
SizedBox(height: 20),
// Create a consistent button style
final buttonStyle = ElevatedButton.styleFrom(
  minimumSize: Size(200, 50), // fixed width and height
  padding: EdgeInsets.symmetric(horizontal: 16),
);

// Create a list of buttons with consistent spacing
Column(
  children: [
    ElevatedButton(
      style: buttonStyle,
      onPressed: () => updateZenohState("SAE_1_LKAS"),
      child: Text('SAE_1 LKAS'),
    ),
    SizedBox(height: 10), // consistent spacing
    ElevatedButton(
      style: buttonStyle,
      onPressed: () => updateZenohState("SAE_1_ACC"),
      child: Text('SAE_1 ACC'),
    ),
    SizedBox(height: 10),
    ElevatedButton(
      style: buttonStyle,
      onPressed: () => updateZenohState("SAE_2"),
      child: Text('SAE_2'),
    ),
    SizedBox(height: 10),
    ElevatedButton(
      style: buttonStyle,
      onPressed: () => updateZenohState("SAE_3"),
      child: Text('SAE_3'),
    ),
  ],
),
```

Alternatively, for a cleaner implementation, you could define a reusable button:

```dart
// ...existing code...
// Add this to your widget build method
Widget _buildControlButton(String label, String value) {
  return Container(
    width: 200, // fixed width
    margin: EdgeInsets.only(bottom: 10), // bottom margin for spacing
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: () => updateZenohState(value),
      child: Text(label),
    ),
  );
}

// Then in your widget list:
Column(
  children: [
    _buildControlButton('SAE_1 LKAS', 'SAE_1_LKAS'),
    _buildControlButton('SAE_1 ACC', 'SAE_1_ACC'),
    _buildControlButton('SAE_2', 'SAE_2'),
    _buildControlButton('SAE_3', 'SAE_3'),
  ],
),
```

This creates uniform buttons with consistent sizing and spacing.

mjorgecruz: why is this function future_

GitHub Copilot: The function is declared as `Future<void>` because it performs asynchronous operations. Here's why:

1. **Asynchronous Nature**: The function makes HTTP requests which don't complete immediately. When you call `http.put()`, your app needs to wait for the server to respond.

2. **The `async` Keyword**: This marks the function as asynchronous, allowing you to use `await` inside it.

3. **The `Future` Return Type**: A `Future` represents a value that will be available at some point in the future. It's Dart's way of handling asynchronous operations.

4. **`<void>` Part**: This indicates the function doesn't return a meaningful value, but it does complete at some point.

5. **Usage in Callers**: When other parts of your code call this function, they can use `await` on it to wait for the network operations to complete.

For example, in your code when a button is pressed, the UI doesn't freeze while waiting for the server response. Instead, the function returns a `Future` immediately, allowing the UI to remain responsive while the network operation happens in the background.

When the network operation completes, the `Future` completes and any code waiting on it (with `await`) continues execution.

mjorgecruz: I am not in the current network so II am naturally getting an error on getting the current status, but I noticed that the error mentions address 10.21.221.9 but the port mentioned is changing around 58734, 58740 etc

GitHub Copilot: The behavior you're seeing is normal and related to how TCP/IP networking works. Let me explain:

- `10.21.221.9:7447` in your code is the **destination address and port** (server)
- The changing ports (58734, 58740, etc.) you see in error messages are **source ports** (client)

### What's happening:

1. When your app makes an HTTP request, your device needs to use a port on your side too
2. Your operating system automatically assigns a random source port (like 58734) for outgoing connections
3. These source ports change with each connection attempt, which is why you see different numbers

### The actual error:

You're getting a connection error because you're not on the network where this server is available. Since `10.21.221.9` is a private IP address (internal network), you need to be:
- Connected to the same network
- Using a VPN to access that network
- Have the server running and accessible

### Possible solutions:

1. **Connect to the correct network** where the server is available
2. **Make the URL configurable** so you can change it at runtime:

```dart
// Replace hardcoded baseUrl with:
String baseUrl = 'http://10.21.221.9:7447';  // Default value

// Add a text field to allow changing the URL:
TextField(
  decoration: InputDecoration(labelText: 'Server URL'),
  onChanged: (value) {
    setState(() {
      baseUrl = value;
    });
  },
)
```

This way you can test your app with different server addresses without rebuilding.

mjorgecruz: the thing is that the port number seems to be going up is that normal_

GitHub Copilot: Yes, seeing increasing port numbers is completely normal. This behavior relates to how TCP/IP connections work:

### What's happening:

1. Your app is trying to connect to the **destination** at 10.21.221.9 port 7447 (your server)
2. For each connection attempt, your operating system assigns a **source port** from the ephemeral port range (typically 49152-65535)
3. These source ports often increment sequentially with each new connection attempt
4. Your timer is making a new connection every 5 seconds, so you see the port numbers increasing

### Technical explanation:

- **Destination port**: 7447 - fixed, where your server listens
- **Source ports**: 58734, 58740, etc. - automatically assigned by your OS for outgoing connections
- These ports help your computer track different network connections
- After a connection closes (or fails), that port remains in TIME_WAIT state briefly before being reused

This is standard TCP/IP behavior and not an issue with your application. The increasing port numbers simply indicate that your app is making multiple connection attempts as expected.

mjorgecruz: Now I want to be able to run this app on my phone... how can I do it_

GitHub Copilot: # Running Your Flutter App on a Physical Phone

You can run your Flutter app on a physical phone by following these steps:

## For Android Devices:

1. **Enable Developer Options on your phone**:
   - Go to Settings > About phone
   - Tap "Build number" 7 times until you see "You are now a developer!"
   - Return to Settings > System > Developer options
   - Enable "USB debugging"

2. **Connect your phone to your computer with a USB cable**
   - When prompted on your phone, allow USB debugging

3. **Check if your device is recognized**:
   ```
   flutter devices
   ```

4. **Run the app on your device**:
   ```
   flutter run
   ```

## For iOS Devices (requires a Mac):

1. **Set up your Apple Developer account**
2. **Open the iOS part of your project in Xcode**:
   ```
   open ios/Runner.xcworkspace
   ```
3. **Sign the app with your developer account**
4. **Connect your iPhone and run from Xcode**

## Build an APK to install directly:

If you just want to create an installable file:

```
flutter build apk --release
```

The APK will be located at: `build/app/outputs/flutter-apk/app-release.apk`

Transfer this file to your phone and install it manually.

For more advanced deployment, you may want to consider setting up a configurable server URL so you can easily point the app to the correct Zenoh router when you're on different networks.

mjorgecruz: is it possible to get a stream running as well?

this is teh code that I use in a linux machine to access the stream
#include <opencv2/opencv.hpp>
#include <zenoh.hxx>
#include <iostream>
#include <vector>
#include <csignal>
#include <thread>

bool running = true;
std::mutex frame_mutex;
std::condition_variable frame_cv;
std::queue<cv::Mat> frame_queue;
bool new_frame = false;

void signalHandler(int signum) {
    std::cout << "Interrupt received, shutting down..." << std::endl;
    running = false;
    frame_cv.notify_all(); // Wake up display thread if it's waiting
}

// This function will be executed in a worker thread, NOT the main thread
void subscriber_thread_function(zenoh::Session session) {
    auto subscriber = session.declare_subscriber(
        "video/stream",
        [](const zenoh::Sample& sample)
        {
            std::cout << "Received video frame" << std::endl;
            std::vector<uchar> buffer(sample.get_payload().as_vector());

            if (buffer.empty()) {
                std::cerr << "Received empty buffer" << std::endl;
                return;
            }

            // Try to decode using various methods
            cv::Mat frame;
            
            // First try standard JPEG/PNG decoding
            frame = cv::imdecode(buffer, cv::IMREAD_COLOR);
            
            if (!frame.empty()) {
                // Queue the frame for display on main thread
                {
                    std::lock_guard<std::mutex> lock(frame_mutex);
                    // Limit queue size to avoid memory issues
                    if (frame_queue.size() > 5) {
                        frame_queue.pop(); // Remove oldest frame if queue is too long
                    }
                    frame_queue.push(frame.clone()); // Clone to ensure data ownership
                    new_frame = true;
                }
                frame_cv.notify_one(); // Notify main thread
                
                std::cout << "Frame queued for display: " << frame.cols << "x" << frame.rows << std::endl;
            }
        }, zenoh::closures::none);
    
    std::cout << "Subscription active, waiting for frames..." << std::endl;
    
    // Keep the subscriber thread running until program terminates
    while (running) {
        std::this_thread::sleep_for(std::chrono::milliseconds(100));
    }
    
    std::cout << "Subscriber thread shutting down" << std::endl;
}

int main() {
    // Register signal handler
    signal(SIGINT, signalHandler);

    // Initialize Zenoh session
    auto config = zenoh::Config::create_default();
    auto session = zenoh::Session::open(std::move(config));

    // Start subscriber in a background thread, leaving main thread for UI
    std::thread zenoh_thread(subscriber_thread_function, std::move(session));

    std::cout << "Subscribing to video/stream..." << std::endl;

    // Create window in the main thread
    cv::namedWindow("Video Stream", cv::WINDOW_AUTOSIZE);
    
    // Main thread loop for displaying frames
    while (running) {
        cv::Mat frame_to_show;
        bool got_frame = false;
        
        {
            std::unique_lock<std::mutex> lock(frame_mutex);
            if (new_frame) {
                if (!frame_queue.empty()) {
                    frame_to_show = frame_queue.front();
                    frame_queue.pop();
                    got_frame = true;
                    
                    // Reset the flag if the queue is now empty
                    new_frame = !frame_queue.empty();
                }
            } else {
                // Wait for a short time or until a new frame arrives
                frame_cv.wait_for(lock, std::chrono::milliseconds(100), 
                                 [&]{ return new_frame || !running; });
            }
        }
        
        // Display the frame outside the lock (in the main thread)
        if (got_frame && !frame_to_show.empty()) {
            cv::imshow("Video Stream", frame_to_show);
        }
        
        // Process UI events with a short timeout - MUST be called in the main thread
        int key = cv::waitKey(10);
        if (key == 27) { // ESC key
            running = false;
        }
    }
    
    // Clean up
    cv::destroyAllWindows();
    
    // Wait for the Zenoh thread to finish
    if (zenoh_thread.joinable()) {
        zenoh_thread.join();
    }
    
    std::cout << "Program terminated gracefully" << std::endl;
    return 0;
}

GitHub Copilot: # Adding Video Stream to Your Flutter App

Yes, it's possible to add video streaming! Based on your C++ code, you're using Zenoh for streaming. While there isn't an official Zenoh package for Flutter/Dart, we can implement something similar using WebSockets or MQTT.

Here's how to add video streaming to your app:

## Option 1: Using WebSockets (Recommended)

```dart
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';

class _ZenohRestPageState extends State<ZenohRestPage> {
  // Existing code...
  
  // WebSocket connection
  WebSocketChannel? _channel;
  Uint8List? _currentFrame;
  bool _streamActive = false;
  
  // Add to initState
  @override
  void initState() {
    super.initState();
    getCurrentStatus();
    _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      getCurrentStatus();
    });
  }
  
  void startVideoStream() {
    setState(() {
      _status = 'Connecting to video stream...';
      _streamActive = true;
    });
    
    // Connect to WebSocket server (replace with your WebSocket endpoint)
    _channel = WebSocketChannel.connect(
      Uri.parse('ws://10.21.221.9:8080/video/stream'),
    );
    
    _channel!.stream.listen(
      (dynamic message) {
        // Process incoming video frames
        if (message is List<int>) {
          setState(() {
            _currentFrame = Uint8List.fromList(message);
          });
        }
      },
      onError: (error) {
        setState(() {
          _status = 'Stream error: $error';
          _streamActive = false;
        });
      },
      onDone: () {
        setState(() {
          _status = 'Stream closed';
          _streamActive = false;
        });
      },
    );
  }
  
  void stopVideoStream() {
    _channel?.sink.close();
    setState(() {
      _streamActive = false;
      _status = 'Stream stopped';
    });
  }
  
  // Add UI elements to your build method
  Widget _buildVideoArea() {
    if (_currentFrame != null) {
      return Container(
        height: 240,
        width: 320,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Image.memory(_currentFrame!, fit: BoxFit.contain),
      );
    } else {
      return Container(
        height: 240,
        width: 320,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
        ),
        child: Center(child: Text('No video stream')),
      );
    }
  }
}
```

And add these to your UI:

```dart
// Add in the children list of your Column in the build method
_buildVideoArea(),
SizedBox(height: 10),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: _streamActive ? null : startVideoStream,
      child: Text('Start Stream'),
    ),
    SizedBox(width: 10),
    ElevatedButton(
      onPressed: _streamActive ? stopVideoStream : null,
      child: Text('Stop Stream'),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
      ),
    ),
  ],
),
```

## Required Dependencies

Add to your pubspec.yaml:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  web_socket_channel: ^2.4.0
```

## Server-Side Considerations

Your C++ code is using Zenoh directly, but for Flutter you'll need:

1. A WebSocket bridge server that:
   - Subscribes to the Zenoh "video/stream" topic
   - Forwards the frames to WebSocket clients

This could be implemented in Python, Node.js, or any server language with both Zenoh and WebSocket support.

Would you like me to provide an example of such a bridge server as well?

mjorgecruz: I am basically publishing images to a publisher, do I really need a bridge server, cant I just read the image and print? I am not getting why I would need additional things

GitHub Copilot: You're right to question this. Let me clarify:

## The Challenge

The issue is that there's currently no native Zenoh client library for Flutter/Dart. Your C++ code works because it's using the Zenoh C++ library directly, but that's not available in Flutter.

## Options Without a Bridge Server

1. **REST API Approach** - If your Zenoh router has REST capabilities (like you're using for the control commands):

```dart
// Add these imports
import 'dart:typed_data';

// Add to your state class
Uint8List? _currentFrame;
Timer? _videoTimer;

@override
void initState() {
  super.initState();
  getCurrentStatus();
  _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
    getCurrentStatus();
  });
  
  // Start video polling
  _videoTimer = Timer.periodic(Duration(milliseconds: 200), (timer) {
    getLatestFrame();
  });
}

@override
void dispose() {
  _statusTimer?.cancel();
  _videoTimer?.cancel();
  super.dispose();
}

Future<void> getLatestFrame() async {
  final String url = '$baseUrl/video/stream';
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      setState(() {
        _currentFrame = response.bodyBytes;
      });
    }
  } catch (e) {
    // Handle error silently for video
  }
}
```

2. **MQTT Alternative** - If you can modify the publisher side to use MQTT instead of Zenoh:

```dart
// Use mqtt_client package instead
```

## Display the Image

Add this to your UI:

```dart
// Add to your Column in the build method
if (_currentFrame != null)
  Container(
    width: double.infinity,
    height: 240,
    child: Image.memory(_currentFrame!, fit: BoxFit.contain),
  )
else
  Container(
    width: double.infinity,
    height: 240, 
    color: Colors.black,
    child: Center(child: Text('No video available', style: TextStyle(color: Colors.white))),
  ),
```

## Why a Bridge Server Might Still Be Best

A bridge server gives you:
1. More efficient streaming (WebSockets vs. HTTP polling)
2. Rate limiting and transcoding if needed
3. Separation of concerns

But if your Zenoh router provides a REST API to access the latest frame, you can certainly use the direct approach I outlined above.

mjorgecruz: it seems that relying on rest requests is a slow approach, can you help me create a bridge server

GitHub Copilot: # Building a Zenoh to WebSocket Bridge Server

You're right that REST polling is inefficient for video streaming. Let's create a WebSocket bridge server that connects your Zenoh system to your Flutter app:

## 1. Python Bridge Server

Create a new file `zenoh_ws_bridge.py`:

```python
#!/usr/bin/env python3
import asyncio
import zenoh
import websockets
import logging
import argparse
import signal
import sys

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)
logger = logging.getLogger(__name__)

# Global variables
connected_clients = set()
running = True

async def zenoh_subscriber(ws_server):
    """Subscribe to Zenoh topic and forward frames to WebSocket clients"""
    # Initialize Zenoh session
    session = zenoh.open()
    logger.info("Zenoh session opened")
    
    # Define Zenoh callback
    def on_sample(sample):
        # Get the raw bytes of the image
        image_data = sample.payload
        
        # Forward to all connected WebSocket clients
        if connected_clients:
            websockets.broadcast(connected_clients, image_data)
            logger.debug(f"Image frame forwarded to {len(connected_clients)} clients")
    
    # Subscribe to Zenoh video topic
    sub = session.declare_subscriber("video/stream", on_sample)
    logger.info("Subscribed to Zenoh video/stream")
    
    # Keep running until shutdown
    while running:
        await asyncio.sleep(1)
    
    # Clean up
    sub.undeclare()
    session.close()
    logger.info("Zenoh session closed")

async def handle_websocket(websocket):
    """Handle WebSocket client connections"""
    # Add new client to the set
    connected_clients.add(websocket)
    client_id = id(websocket)
    logger.info(f"New client connected: {client_id}. Total clients: {len(connected_clients)}")
    
    try:
        # Keep connection open
        await websocket.wait_closed()
    finally:
        # Remove client when disconnected
        connected_clients.remove(websocket)
        logger.info(f"Client disconnected: {client_id}. Remaining clients: {len(connected_clients)}")

async def main():
    # Parse command line arguments
    parser = argparse.ArgumentParser(description="Zenoh to WebSocket bridge for video streaming")
    parser.add_argument("--host", default="0.0.0.0", help="WebSocket host")
    parser.add_argument("--port", type=int, default=8080, help="WebSocket port")
    args = parser.parse_args()
    
    # Start WebSocket server
    logger.info(f"Starting WebSocket server on {args.host}:{args.port}")
    ws_server = await websockets.serve(handle_websocket, args.host, args.port)
    
    # Start Zenoh subscriber task
    zenoh_task = asyncio.create_task(zenoh_subscriber(ws_server))
    
    # Handle graceful shutdown
    def signal_handler(sig, frame):
        global running
        logger.info("Shutdown signal received")
        running = False
        
    signal.signal(signal.SIGINT, signal_handler)
    signal.signal(signal.SIGTERM, signal_handler)
    
    # Keep server running
    while running:
        await asyncio.sleep(1)
    
    # Clean up
    ws_server.close()
    await ws_server.wait_closed()
    await zenoh_task
    logger.info("Bridge server shutdown complete")

if __name__ == "__main__":
    asyncio.run(main())
```

## 2. Install Required Python Packages

```bash
pip install zenoh websockets
```

## 3. Update Your Flutter App to Use WebSockets

Add the WebSocket package to your pubspec.yaml:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  web_socket_channel: ^2.4.0
```

Run `flutter pub get` to install it.

## 4. Add Video Streaming to Your Flutter App

```dart
import 'dart:typed_data';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as ws_status;

class _ZenohRestPageState extends State<ZenohRestPage> {
  // Existing fields...
  
  // Add these new fields
  WebSocketChannel? _channel;
  Uint8List? _currentFrame;
  bool _streamActive = false;
  String _streamStatus = 'Inactive';
  
  @override
  void dispose() {
    _statusTimer?.cancel();
    _channel?.sink.close(ws_status.goingAway);
    super.dispose();
  }
  
  void startVideoStream() {
    setState(() {
      _streamStatus = 'Connecting...';
    });
    
    try {
      // Replace with your bridge server URL - use the machine's IP where the bridge runs
      final wsUrl = 'ws://10.21.221.9:8080';
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      _channel!.stream.listen(
        (dynamic message) {
          if (message is List<int>) {
            setState(() {
              _currentFrame = Uint8List.fromList(message);
              _streamActive = true;
              _streamStatus = 'Connected';
            });
          }
        },
        onError: (error) {
          setState(() {
            _streamStatus = 'Error: $error';
            _streamActive = false;
          });
        },
        onDone: () {
          setState(() {
            _streamStatus = 'Disconnected';
            _streamActive = false;
          });
        },
      );
    } catch (e) {
      setState(() {
        _streamStatus = 'Connection failed: $e';
        _streamActive = false;
      });
    }
  }
  
  void stopVideoStream() {
    _channel?.sink.close(ws_status.normalClosure);
    setState(() {
      _streamActive = false;
      _streamStatus = 'Stopped';
    });
  }
  
  Widget _buildVideoArea() {
    return Column(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            color: Colors.black,
          ),
          child: _currentFrame != null
              ? Image.memory(_currentFrame!, fit: BoxFit.contain)
              : Center(child: Text('No video stream', style: TextStyle(color: Colors.white))),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Stream: $_streamStatus'),
            Spacer(),
            ElevatedButton(
              onPressed: _streamActive ? null : startVideoStream,
              child: Text('Start Stream'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _streamActive ? stopVideoStream : null,
              child: Text('Stop Stream'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ...existing code...
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add the video area before the other controls
              _buildVideoArea(),
              SizedBox(height: 20),
              // ...existing widgets...
              Text('Status: $_status'),
              SizedBox(height: 10),
              Text('Current Autonomy Level: $_currentValue', 
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              SizedBox(height: 20),
              _buildControlButton('SAE_1 LKAS', 'SAE_1_LKAS'),
              _buildControlButton('SAE_1 ACC', 'SAE_1_ACC'),
              _buildControlButton('SAE_2', 'SAE_2'),
              _buildControlButton('SAE_3', 'SAE_3'),
            ],
          ),
        ),
      ),
    );
  }
}
```

## 5. Running the Bridge Server

1. Save the Python script to your server or development machine
2. Make it executable: `chmod +x zenoh_ws_bridge.py`
3. Run it: `./zenoh_ws_bridge.py`
4. The bridge will listen on port 8080 by default

## 6. Make Sure Your Flutter App and Bridge Server Can Communicate

Ensure your phone and the bridge server are on the same network, or that the server is accessible through your network configuration.

This WebSocket approach is much more efficient than REST polling for video streams and will provide a better user experience with lower latency.

mjorgecruz: I also want to use the app as a controller for the throttle and direction, here is the code I use in the current controller
float speed = -this->axes[axis]->y * 100 / 32767;
float direction = 90 + this->axes[axis]->x * 90 / 32767;

these are the publishers 
    throttle_pub.emplace(session_->declare_publisher(
        zenoh::KeyExpr("Vehicle/1/Powertrain/ElectricMotor/Speed")));
    steering_pub.emplace(session_->declare_publisher(
        zenoh::KeyExpr("Vehicle/1/Chassis/SteeringWheel/Angle")));


GitHub Copilot: # Adding Vehicle Controls to Your App

Let's implement throttle and steering controls in your Flutter app by using both sliders and a virtual joystick:

## 1. Add Dependencies to pubspec.yaml

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  flutter_joystick: ^0.0.3  # For joystick control
```

Run `flutter pub get` to install.

## 2. Add Controls to Your App

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_joystick/flutter_joystick.dart';

// ...existing code...

class _ZenohRestPageState extends State<ZenohRestPage> {
  // ...existing variables...
  
  // Add these new variables
  double _throttle = 0.0;  // -100 to 100
  double _steering = 90.0;  // 0 to 180
  bool _useJoystick = false;  // Toggle between joystick and sliders
  Timer? _controlTimer;
  
  @override
  void initState() {
    super.initState();
    getCurrentStatus();
    
    _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      getCurrentStatus();
    });
    
    // Send control values at regular intervals
    _controlTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_throttle != 0.0 || _steering != 90.0) {
        sendControlValues();
      }
    });
  }
  
  @override
  void dispose() {
    _statusTimer?.cancel();
    _controlTimer?.cancel();
    super.dispose();
  }
  
  // Send throttle and steering values to the server
  Future<void> sendControlValues() async {
    try {
      // Send throttle
      final throttleUrl = '$baseUrl/Vehicle/1/Powertrain/ElectricMotor/Speed';
      await http.put(
        Uri.parse(throttleUrl),
        headers: {'Content-Type': 'text/plain'},
        body: _throttle.toStringAsFixed(2),
      );
      
      // Send steering
      final steeringUrl = '$baseUrl/Vehicle/1/Chassis/SteeringWheel/Angle';
      await http.put(
        Uri.parse(steeringUrl),
        headers: {'Content-Type': 'text/plain'},
        body: _steering.toStringAsFixed(2),
      );
    } catch (e) {
      setState(() {
        _status = 'Control error: $e';
      });
    }
  }
  
  // Reset controls to neutral
  void resetControls() {
    setState(() {
      _throttle = 0.0;
      _steering = 90.0;
    });
    sendControlValues();
  }
  
  // Build slider controls
  Widget _buildSliderControls() {
    return Column(
      children: [
        Text('Throttle: ${_throttle.toStringAsFixed(0)}%', 
            style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _throttle,
          min: -100,
          max: 100,
          divisions: 40,
          label: _throttle.toStringAsFixed(0),
          onChanged: (value) {
            setState(() {
              _throttle = value;
            });
          },
        ),
        Text('Steering: ${_steering.toStringAsFixed(0)}°', 
            style: TextStyle(fontWeight: FontWeight.bold)),
        Slider(
          value: _steering,
          min: 0,
          max: 180,
          divisions: 36,
          label: _steering.toStringAsFixed(0),
          onChanged: (value) {
            setState(() {
              _steering = value;
            });
          },
        ),
        ElevatedButton(
          onPressed: resetControls,
          child: Text('Reset Controls'),
        ),
      ],
    );
  }
  
  // Build joystick control
  Widget _buildJoystickControl() {
    return Container(
      height: 200,
      child: Column(
        children: [
          Text('Throttle: ${_throttle.toStringAsFixed(0)}% | Steering: ${_steering.toStringAsFixed(0)}°', 
              style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              child: Joystick(
                size: 150,
                isDraggable: false,
                listener: (details) {
                  setState(() {
                    // Convert joystick Y to throttle (-100 to 100)
                    _throttle = -details.y * 100;
                    
                    // Convert joystick X to steering (0 to 180, with 90 as center)
                    _steering = 90 + details.x * 90;
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Add a tab for controls in your UI
  Widget _buildControlsTab() {
    return Column(
      children: [
        // Control type toggle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Control type: '),
            ToggleButtons(
              isSelected: [!_useJoystick, _useJoystick],
              onPressed: (index) {
                setState(() {
                  _useJoystick = index == 1;
                  resetControls();
                });
              },
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Sliders'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Joystick'),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
        // Display appropriate control type
        _useJoystick ? _buildJoystickControl() : _buildSliderControls(),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Vehicle Control'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Autonomy', icon: Icon(Icons.auto_awesome)),
              Tab(text: 'Manual Control', icon: Icon(Icons.videogame_asset)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Autonomy tab (your existing UI)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Status: $_status'),
                    SizedBox(height: 10),
                    Text('Current Autonomy Level: $_currentValue', 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    SizedBox(height: 20),
                    _buildControlButton('SAE_1 LKAS', 'SAE_1_LKAS'),
                    _buildControlButton('SAE_1 ACC', 'SAE_1_ACC'),
                    _buildControlButton('SAE_2', 'SAE_2'),
                    _buildControlButton('SAE_3', 'SAE_3'),
                  ],
                ),
              ),
            ),
            // Manual control tab
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildControlsTab(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

This implementation:

1. Creates a tabbed interface with "Autonomy" and "Manual Control" tabs
2. Offers both slider controls and a joystick option
3. Sends control values to your Zenoh router using the same REST API approach
4. Periodically sends control values (100ms interval) when they're not at neutral
5. Provides a reset button to return to neutral position
6. Displays current throttle and steering values

The joystick's y-axis controls throttle (-100 to 100) and x-axis controls steering (0 to 180), matching your existing controller implementation.

mjorgecruz: I just need the joysticks and I also want to send requests whenever possible, or even on every change

GitHub Copilot: # Adding Joystick Controls with Immediate Updates

Here's how to implement joystick controls that send requests on every change:

```dart
// ...existing code...

class _ZenohRestPageState extends State<ZenohRestPage> with SingleTickerProviderStateMixin {
  // ...existing fields...
  
  // Add these new fields
  Timer? _controlTimer;
  Timer? _throttleDebounce;
  Timer? _steeringDebounce;
  TabController? _tabController;
  bool _isSendingControls = false;
  String _controlStatus = 'Ready';
  
  @override
  void initState() {
    super.initState();
    getCurrentStatus();
    _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      getCurrentStatus();
    });
    
    // Tab controller for switching between autonomy and manual control
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _statusTimer?.cancel();
    _throttleDebounce?.cancel();
    _steeringDebounce?.cancel();
    _tabController?.dispose();
    super.dispose();
  }
  
  // Send throttle value to server
  Future<void> sendThrottle() async {
    if (_isSendingControls) return;
    
    setState(() {
      _isSendingControls = true;
      _controlStatus = 'Sending throttle...';
    });
    
    try {
      final throttleUrl = '$baseUrl/Vehicle/1/Powertrain/ElectricMotor/Speed';
      final response = await http.put(
        Uri.parse(throttleUrl),
        headers: {'Content-Type': 'text/plain'},
        body: _throttle.toStringAsFixed(2),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _controlStatus = 'Throttle sent: ${_throttle.toStringAsFixed(1)}%';
        });
      } else {
        setState(() {
          _controlStatus = 'Throttle error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _controlStatus = 'Throttle error: $e';
      });
    } finally {
      setState(() {
        _isSendingControls = false;
      });
    }
  }
  
  // Send steering value to server
  Future<void> sendSteering() async {
    if (_isSendingControls) return;
    
    setState(() {
      _isSendingControls = true;
      _controlStatus = 'Sending steering...';
    });
    
    try {
      final steeringUrl = '$baseUrl/Vehicle/1/Chassis/SteeringWheel/Angle';
      final response = await http.put(
        Uri.parse(steeringUrl),
        headers: {'Content-Type': 'text/plain'},
        body: _steering.toStringAsFixed(2),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _controlStatus = 'Steering sent: ${_steering.toStringAsFixed(1)}°';
        });
      } else {
        setState(() {
          _controlStatus = 'Steering error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _controlStatus = 'Steering error: $e';
      });
    } finally {
      setState(() {
        _isSendingControls = false;
      });
    }
  }
  
  // Update throttle with debounce
  void updateThrottle(double value) {
    setState(() {
      _throttle = value;
    });
    
    // Cancel previous timer
    _throttleDebounce?.cancel();
    
    // Set new timer to send value after short delay to avoid flooding the server
    _throttleDebounce = Timer(Duration(milliseconds: 50), () {
      sendThrottle();
    });
  }
  
  // Update steering with debounce
  void updateSteering(double value) {
    setState(() {
      _steering = value;
    });
    
    // Cancel previous timer
    _steeringDebounce?.cancel();
    
    // Set new timer to send value after short delay
    _steeringDebounce = Timer(Duration(milliseconds: 50), () {
      sendSteering();
    });
  }
  
  // Reset controls to neutral
  void resetControls() {
    setState(() {
      _throttle = 0.0;
      _steering = 90.0;
    });
    sendThrottle();
    sendSteering();
  }
  
  // Build joystick control UI
  Widget _buildJoystickControl() {
    return Container(
      height: 300,
      child: Column(
        children: [
          // Status and value indicators
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Text('Control Status: $_controlStatus', 
                    style: TextStyle(fontStyle: FontStyle.italic)),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text('Throttle: ${_throttle.toStringAsFixed(1)}%', 
                        style: TextStyle(fontWeight: FontWeight.bold, 
                            color: _throttle != 0 ? Colors.blue : Colors.black)),
                    Text('Steering: ${_steering.toStringAsFixed(1)}°', 
                        style: TextStyle(fontWeight: FontWeight.bold, 
                            color: _steering != 90 ? Colors.blue : Colors.black)),
                  ],
                ),
              ],
            ),
          ),
          
          // Joystick
          Expanded(
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Joystick(
                  mode: JoystickMode.all,
                  listener: (details) {
                    // Update throttle (-100 to 100, reversed Y axis)
                    double newThrottle = -details.y * 100;
                    if (newThrottle != _throttle) {
                      updateThrottle(newThrottle);
                    }
                    
                    // Update steering (0 to 180, with 90 as center)
                    double newSteering = 90 + details.x * 90;
                    if (newSteering != _steering) {
                      updateSteering(newSteering);
                    }
                  },
                ),
              ),
            ),
          ),
          
          // Reset button
          ElevatedButton.icon(
            onPressed: resetControls,
            icon: Icon(Icons.refresh),
            label: Text('Reset Controls'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Vehicle Control'),
          bottom: TabBar(
            controller: _tabController,
            tabs: [
              Tab(icon: Icon(Icons.auto_awesome), text: 'Autonomy'),
              Tab(icon: Icon(Icons.gamepad), text: 'Manual Control'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Autonomy controls (existing UI)
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Status: $_status'),
                      SizedBox(height: 10),
                      Text('Current Autonomy Level: $_currentValue', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 20),
                      _buildControlButton('SAE_1 LKAS', 'SAE_1_LKAS'),
                      _buildControlButton('SAE_1 ACC', 'SAE_1_ACC'),
                      _buildControlButton('SAE_2', 'SAE_2'),
                      _buildControlButton('SAE_3', 'SAE_3'),
                    ],
                  ),
                ),
              ),
            ),
            
            // Tab 2: Manual joystick controls
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: _buildJoystickControl(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Key Features of This Implementation:

1. **Immediate Updates**: Sends updates whenever joystick values change, with a small 50ms debounce to prevent overwhelming the server
2. **Simple UI**: Clear display of current throttle and steering values
3. **Tabbed Interface**: Switches between autonomy and manual control modes
4. **Status Feedback**: Shows the current status of control operations
5. **Reset Button**: Quickly returns to neutral position (0% throttle, 90° steering)

The joystick is designed to be intuitive:
- Up/down controls throttle (-100% to 100%)
- Left/right controls steering (0° to 180°, with 90° center)

This implementation maintains all your existing functionality while adding the manual control capability.

mjorgecruz: I want a throtle changer separated from direction, does it make sense to use something other than two joysticks?

GitHub Copilot: # Creating Separate Throttle and Direction Controls

Instead of using joysticks, let's implement more intuitive controls for a vehicle:

1. A throttle slider (vertical)
2. A steering wheel or horizontal slider for direction

Here's how to implement these controls:

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_joystick/flutter_joystick.dart';

// ...existing code...

class _ZenohRestPageState extends State<ZenohRestPage> with SingleTickerProviderStateMixin {
  // ...existing fields...
  
  // Add these new fields
  Timer? _throttleDebounce;
  Timer? _steeringDebounce;
  TabController? _tabController;
  bool _isSendingThrottle = false;
  bool _isSendingSteering = false;
  String _controlStatus = 'Ready';
  
  @override
  void initState() {
    super.initState();
    getCurrentStatus();
    _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      getCurrentStatus();
    });
    
    // Tab controller for switching between autonomy and manual control
    _tabController = TabController(length: 2, vsync: this);
  }
  
  @override
  void dispose() {
    _statusTimer?.cancel();
    _throttleDebounce?.cancel();
    _steeringDebounce?.cancel();
    _tabController?.dispose();
    super.dispose();
  }
  
  // Send throttle value to server
  Future<void> sendThrottle() async {
    if (_isSendingThrottle) return;
    
    setState(() {
      _isSendingThrottle = true;
      _controlStatus = 'Sending throttle...';
    });
    
    try {
      final throttleUrl = '$baseUrl/Vehicle/1/Powertrain/ElectricMotor/Speed';
      final response = await http.put(
        Uri.parse(throttleUrl),
        headers: {'Content-Type': 'text/plain'},
        body: _throttle.toStringAsFixed(2),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _controlStatus = 'Throttle: ${_throttle.toStringAsFixed(1)}%';
        });
      } else {
        setState(() {
          _controlStatus = 'Throttle error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _controlStatus = 'Throttle error: $e';
      });
    } finally {
      setState(() {
        _isSendingThrottle = false;
      });
    }
  }
  
  // Send steering value to server
  Future<void> sendSteering() async {
    if (_isSendingSteering) return;
    
    setState(() {
      _isSendingSteering = true;
      _controlStatus = 'Sending steering...';
    });
    
    try {
      final steeringUrl = '$baseUrl/Vehicle/1/Chassis/SteeringWheel/Angle';
      final response = await http.put(
        Uri.parse(steeringUrl),
        headers: {'Content-Type': 'text/plain'},
        body: _steering.toStringAsFixed(2),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _controlStatus = 'Steering: ${_steering.toStringAsFixed(1)}°';
        });
      } else {
        setState(() {
          _controlStatus = 'Steering error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _controlStatus = 'Steering error: $e';
      });
    } finally {
      setState(() {
        _isSendingSteering = false;
      });
    }
  }
  
  // Update throttle with debounce
  void updateThrottle(double value) {
    setState(() {
      _throttle = value;
    });
    
    // Cancel previous timer
    _throttleDebounce?.cancel();
    
    // Set new timer to send value after short delay
    _throttleDebounce = Timer(Duration(milliseconds: 50), () {
      sendThrottle();
    });
  }
  
  // Update steering with debounce
  void updateSteering(double value) {
    setState(() {
      _steering = value;
    });
    
    // Cancel previous timer
    _steeringDebounce?.cancel();
    
    // Set new timer to send value after short delay
    _steeringDebounce = Timer(Duration(milliseconds: 50), () {
      sendSteering();
    });
  }
  
  // Reset controls to neutral
  void resetControls() {
    setState(() {
      _throttle = 0.0;
      _steering = 90.0;
    });
    sendThrottle();
    sendSteering();
  }
  
  // Build separate controls for throttle and steering
  Widget _buildManualControls() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // Status indicator
          Container(
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Status: $_controlStatus', 
                style: TextStyle(fontStyle: FontStyle.italic)),
          ),
          
          // Main controls
          Expanded(
            child: Row(
              children: [
                // Throttle control (vertical slider)
                Column(
                  children: [
                    Text('Throttle', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_throttle.toStringAsFixed(0)}%', 
                        style: TextStyle(
                          color: _throttle > 0 ? Colors.green : _throttle < 0 ? Colors.red : Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        )),
                    Expanded(
                      child: Container(
                        width: 80,
                        margin: EdgeInsets.symmetric(vertical: 8),
                        child: RotatedBox(
                          quarterTurns: 3, // Rotate to make vertical
                          child: Slider(
                            value: _throttle,
                            min: -100,
                            max: 100,
                            divisions: 40,
                            activeColor: _throttle >= 0 ? Colors.green : Colors.red,
                            thumbColor: Colors.blue,
                            onChanged: (value) => updateThrottle(value),
                          ),
                        ),
                      ),
                    ),
                    // Throttle indicator
                    Container(
                      margin: EdgeInsets.only(top: 8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _throttle == 0 ? Colors.grey[300] : 
                               _throttle > 0 ? Colors.green[100] : Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        _throttle > 0 ? Icons.arrow_upward : 
                        _throttle < 0 ? Icons.arrow_downward : Icons.remove,
                        color: _throttle > 0 ? Colors.green : 
                               _throttle < 0 ? Colors.red : Colors.grey,
                      ),
                    ),
                  ],
                ),
                
                // Spacer
                SizedBox(width: 24),
                
                // Steering control (horizontal slider)
                Expanded(
                  child: Column(
                    children: [
                      Text('Steering', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${_steering.toStringAsFixed(0)}°', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      
                      // Steering wheel visualization
                      Expanded(
                        child: Center(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Outer circle
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey, width: 2),
                                ),
                              ),
                              // Steering wheel
                              Transform.rotate(
                                angle: (_steering - 90) * 0.03, // Convert to radians with limited rotation
                                child: Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: Container(
                                      width: 120,
                                      height: 120,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[100],
                                      ),
                                      child: Stack(
                                        children: [
                                          // Vertical line
                                          Center(
                                            child: Container(
                                              height: 80,
                                              width: 8,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          // Horizontal line
                                          Center(
                                            child: Container(
                                              width: 80,
                                              height: 8,
                                              color: Colors.black54,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      // Steering slider
                      Slider(
                        value: _steering,
                        min: 0,
                        max: 180,
                        divisions: 36,
                        label: "${_steering.toStringAsFixed(0)}°",
                        activeColor: _steering == 90 ? Colors.grey : Colors.blue,
                        onChanged: (value) => updateSteering(value),
                      ),
                      
                      // Steering indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.arrow_back, 
                               color: _steering < 90 ? Colors.blue : Colors.grey),
                          SizedBox(width: 24),
                          Icon(Icons.arrow_forward, 
                               color: _steering > 90 ? Colors.blue : Colors.grey),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Reset button
          ElevatedButton.icon(
            onPressed: resetControls,
            icon: Icon(Icons.refresh),
            label: Text('Reset Controls'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 24),
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Vehicle Control'),
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.auto_awesome), text: 'Autonomy'),
              Tab(icon: Icon(Icons.drive_eta), text: 'Manual Drive'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Autonomy controls (existing UI)
            SingleChildScrollView(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Status: $_status'),
                      SizedBox(height: 10),
                      Text('Current Autonomy Level: $_currentValue', 
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      SizedBox(height: 20),
                      _buildControlButton('SAE_1 LKAS', 'SAE_1_LKAS'),
                      _buildControlButton('SAE_1 ACC', 'SAE_1_ACC'),
                      _buildControlButton('SAE_2', 'SAE_2'),
                      _buildControlButton('SAE_3', 'SAE_3'),
                    ],
                  ),
                ),
              ),
            ),
            
            // Tab 2: Manual drive controls
            _buildManualControls(),
          ],
        ),
      ),
    );
  }
}
```

## Key Features:

1. **Intuitive Controls**:
   - A vertical slider for throttle (-100% to 100%)
   - A steering wheel visualization with slider for direction (0° to 180°)

2. **Real-time Updates**:
   - Sends values to the server immediately when changed (with minimal debounce)
   - Visual feedback with colors and icons

3. **Realistic Interface**:
   - The throttle control shows green for forward, red for reverse
   - The steering wheel rotates as you turn the slider
   
4. **User Experience**:
   - Clear visual indicators for current values
   - Reset button to quickly return to neutral position
   - Status updates when communicating with the server

This design provides a more intuitive driving experience than joysticks while maintaining the immediate responsiveness you requested.

mjorgecruz: I want a single UI, the manual control should always be available to the user

GitHub Copilot: # Combined UI with Both Autonomy and Manual Controls

Let's modify your app to have a single UI where both autonomy controls and manual controls are always available:

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_joystick/flutter_joystick.dart';

// ...existing code...

class _ZenohRestPageState extends State<ZenohRestPage> {
  // ...existing fields...
  
  // Add these new fields
  Timer? _throttleDebounce;
  Timer? _steeringDebounce;
  bool _isSendingThrottle = false;
  bool _isSendingSteering = false;
  String _controlStatus = 'Ready';

  // Send throttle value to server
  Future<void> sendThrottle() async {
    if (_isSendingThrottle) return;
    
    setState(() {
      _isSendingThrottle = true;
    });
    
    try {
      final throttleUrl = '$baseUrl/Vehicle/1/Powertrain/ElectricMotor/Speed';
      final response = await http.put(
        Uri.parse(throttleUrl),
        headers: {'Content-Type': 'text/plain'},
        body: _throttle.toStringAsFixed(2),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _controlStatus = 'Throttle: ${_throttle.toStringAsFixed(1)}%';
        });
      } else {
        setState(() {
          _controlStatus = 'Throttle error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _controlStatus = 'Throttle error: $e';
      });
    } finally {
      setState(() {
        _isSendingThrottle = false;
      });
    }
  }
  
  // Send steering value to server
  Future<void> sendSteering() async {
    if (_isSendingSteering) return;
    
    setState(() {
      _isSendingSteering = true;
    });
    
    try {
      final steeringUrl = '$baseUrl/Vehicle/1/Chassis/SteeringWheel/Angle';
      final response = await http.put(
        Uri.parse(steeringUrl),
        headers: {'Content-Type': 'text/plain'},
        body: _steering.toStringAsFixed(2),
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        setState(() {
          _controlStatus = 'Steering: ${_steering.toStringAsFixed(1)}°';
        });
      } else {
        setState(() {
          _controlStatus = 'Steering error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _controlStatus = 'Steering error: $e';
      });
    } finally {
      setState(() {
        _isSendingSteering = false;
      });
    }
  }
  
  // Update throttle with debounce
  void updateThrottle(double value) {
    setState(() {
      _throttle = value;
    });
    
    // Cancel previous timer
    _throttleDebounce?.cancel();
    
    // Set new timer to send value after short delay
    _throttleDebounce = Timer(Duration(milliseconds: 50), () {
      sendThrottle();
    });
  }
  
  // Update steering with debounce
  void updateSteering(double value) {
    setState(() {
      _steering = value;
    });
    
    // Cancel previous timer
    _steeringDebounce?.cancel();
    
    // Set new timer to send value after short delay
    _steeringDebounce = Timer(Duration(milliseconds: 50), () {
      sendSteering();
    });
  }
  
  // Reset controls to neutral
  void resetControls() {
    setState(() {
      _throttle = 0.0;
      _steering = 90.0;
    });
    sendThrottle();
    sendSteering();
  }
  
  // Build throttle control
  Widget _buildThrottleControl() {
    return Column(
      children: [
        Text('Throttle: ${_throttle.toStringAsFixed(0)}%', 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _throttle > 0 ? Colors.green : _throttle < 0 ? Colors.red : Colors.black,
            )),
        SizedBox(height: 8),
        Container(
          height: 200,
          width: 60,
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: _throttle,
              min: -100,
              max: 100,
              divisions: 40,
              activeColor: _throttle >= 0 ? Colors.green : Colors.red,
              onChanged: updateThrottle,
            ),
          ),
        ),
        Icon(
          _throttle > 0 ? Icons.arrow_upward : 
          _throttle < 0 ? Icons.arrow_downward : Icons.remove,
          color: _throttle > 0 ? Colors.green : 
                _throttle < 0 ? Colors.red : Colors.grey,
        ),
      ],
    );
  }
  
  // Build steering control
  Widget _buildSteeringControl() {
    return Column(
      children: [
        Text('Steering: ${_steering.toStringAsFixed(0)}°', 
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Slider(
          value: _steering,
          min: 0,
          max: 180,
          divisions: 36,
          label: "${_steering.toStringAsFixed(0)}°",
          onChanged: updateSteering,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back, 
                color: _steering < 90 ? Colors.blue : Colors.grey),
            SizedBox(width: 24),
            Icon(Icons.arrow_forward, 
                color: _steering > 90 ? Colors.blue : Colors.grey),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Control'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Autonomy controls section
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Autonomy Controls', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text('Status: $_status'),
                      SizedBox(height: 5),
                      Text('Current Autonomy Level: $_currentValue', 
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _buildControlButton('SAE_1 LKAS', 'SAE_1_LKAS')),
                          SizedBox(width: 8),
                          Expanded(child: _buildControlButton('SAE_1 ACC', 'SAE_1_ACC')),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(child: _buildControlButton('SAE_2', 'SAE_2')),
                          SizedBox(width: 8),
                          Expanded(child: _buildControlButton('SAE_3', 'SAE_3')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Manual controls section
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Text('Manual Controls', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text('Status: $_controlStatus', 
                          style: TextStyle(fontStyle: FontStyle.italic)),
                      SizedBox(height: 15),
                      
                      // Controls layout - throttle on left, steering on right
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildThrottleControl(),
                          SizedBox(width: 10),
                          Expanded(child: _buildSteeringControl()),
                        ],
                      ),
                      
                      SizedBox(height: 10),
                      
                      // Reset controls button
                      ElevatedButton.icon(
                        onPressed: resetControls,
                        icon: Icon(Icons.refresh),
                        label: Text('Reset Controls'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Update your button builder to fit in the new layout
  Widget _buildControlButton(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => updateZenohState(value),
        child: Text(label),
      ),
    );
  }
}
```

## Key Features of This Design:

1. **Single Unified UI** 
   - Both autonomy and manual controls are visible at the same time
   - Organized in separate card sections for clarity

2. **Space-Efficient Layout**
   - Autonomy controls in a compact grid layout
   - Throttle and steering controls arranged side-by-side
   - Scrollable view to handle different screen sizes

3. **Intuitive Manual Controls**
   - Vertical throttle slider (-100% to 100%)
   - Horizontal steering slider (0° to 180°)
   - Color indicators (green forward, red reverse)
   - Direction arrows

4. **Status Information**
   - Separate status displays for autonomy and manual controls
   - Clear visual feedback on control values

5. **Real-Time Updates**
   - Sends control values immediately with minimal debounce
   - Reset button for quickly returning to neutral

This design provides a comprehensive interface where users can both monitor/change the autonomy level and manually control the vehicle at any time.

mjorgecruz: does it make sense to separate the file a bit more instead of having a very big file like this?

GitHub Copilot: # Refactoring Your App into Multiple Files

You're absolutely right! Separating your code into multiple files would make it much more maintainable. Here's how you could organize it:

## Suggested File Structure

```
lib/
├── main.dart                     # App entry point
├── screens/
│   └── vehicle_control_page.dart # Main vehicle control screen
├── widgets/
│   ├── autonomy_controls.dart    # Autonomy level widgets
│   ├── manual_controls.dart      # Throttle/steering widgets
│   └── status_display.dart       # Status indicators
└── services/
    └── zenoh_service.dart        # All API communication
```

## Implementation Guide

### 1. First, create the service file:

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ZenohService {
  final String baseUrl;
  
  ZenohService({required this.baseUrl});
  
  Future<String> getCurrentAutonomyLevel(String keyExpr) async {
    final String url = '$baseUrl/$keyExpr';
    
    final response = await http.get(Uri.parse(url));
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonArray = json.decode(response.body);
      if (jsonArray.isNotEmpty && jsonArray[0] is Map<String, dynamic>) {
        final Map<String, dynamic> data = jsonArray[0];
        return data['value'] ?? 'N/A';
      } else {
        throw Exception('Invalid response format');
      }
    } else {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
  
  Future<String> updateAutonomyLevel(String keyExpr, String autonomyLevel) async {
    final String url = '$baseUrl/$keyExpr';
    
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'text/plain'},
      body: autonomyLevel,
    );
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.body;
    } else {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
  
  Future<void> setThrottle(double value) async {
    final String url = '$baseUrl/Vehicle/1/Powertrain/ElectricMotor/Speed';
    
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'text/plain'},
      body: value.toStringAsFixed(2),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
  
  Future<void> setSteering(double value) async {
    final String url = '$baseUrl/Vehicle/1/Chassis/SteeringWheel/Angle';
    
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'text/plain'},
      body: value.toStringAsFixed(2),
    );
    
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed with status code: ${response.statusCode}');
    }
  }
}
```

### 2. Create the manual controls widget:

```dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/zenoh_service.dart';

class ManualControls extends StatefulWidget {
  final ZenohService zenohService;
  final double throttle;
  final double steering;
  final Function(double) onThrottleChanged;
  final Function(double) onSteeringChanged;
  final VoidCallback onReset;

  const ManualControls({
    Key? key,
    required this.zenohService,
    required this.throttle,
    required this.steering,
    required this.onThrottleChanged,
    required this.onSteeringChanged,
    required this.onReset,
  }) : super(key: key);

  @override
  State<ManualControls> createState() => _ManualControlsState();
}

class _ManualControlsState extends State<ManualControls> {
  String _controlStatus = 'Ready';
  bool _isSending = false;
  
  // Throttle control widget
  Widget _buildThrottleControl() {
    return Column(
      children: [
        Text('Throttle: ${widget.throttle.toStringAsFixed(0)}%', 
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: widget.throttle > 0 ? Colors.green : 
                    widget.throttle < 0 ? Colors.red : Colors.black,
            )),
        SizedBox(height: 8),
        Container(
          height: 200,
          width: 60,
          child: RotatedBox(
            quarterTurns: 3,
            child: Slider(
              value: widget.throttle,
              min: -100,
              max: 100,
              divisions: 40,
              activeColor: widget.throttle >= 0 ? Colors.green : Colors.red,
              onChanged: widget.onThrottleChanged,
            ),
          ),
        ),
        Icon(
          widget.throttle > 0 ? Icons.arrow_upward : 
          widget.throttle < 0 ? Icons.arrow_downward : Icons.remove,
          color: widget.throttle > 0 ? Colors.green : 
                widget.throttle < 0 ? Colors.red : Colors.grey,
        ),
      ],
    );
  }
  
  // Steering control widget
  Widget _buildSteeringControl() {
    return Column(
      children: [
        Text('Steering: ${widget.steering.toStringAsFixed(0)}°', 
            style: TextStyle(fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Slider(
          value: widget.steering,
          min: 0,
          max: 180,
          divisions: 36,
          label: "${widget.steering.toStringAsFixed(0)}°",
          onChanged: widget.onSteeringChanged,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.arrow_back, 
                color: widget.steering < 90 ? Colors.blue : Colors.grey),
            SizedBox(width: 24),
            Icon(Icons.arrow_forward, 
                color: widget.steering > 90 ? Colors.blue : Colors.grey),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Manual Controls', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Status: $_controlStatus', 
                style: TextStyle(fontStyle: FontStyle.italic)),
            SizedBox(height: 15),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildThrottleControl(),
                SizedBox(width: 10),
                Expanded(child: _buildSteeringControl()),
              ],
            ),
            
            SizedBox(height: 10),
            
            ElevatedButton.icon(
              onPressed: widget.onReset,
              icon: Icon(Icons.refresh),
              label: Text('Reset Controls'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 3. Create the autonomy controls widget:

```dart
import 'package:flutter/material.dart';

class AutonomyControls extends StatelessWidget {
  final String status;
  final String currentValue;
  final Function(String) onAutonomyLevelChanged;
  
  const AutonomyControls({
    Key? key,
    required this.status,
    required this.currentValue,
    required this.onAutonomyLevelChanged,
  }) : super(key: key);
  
  Widget _buildControlButton(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        onPressed: () => onAutonomyLevelChanged(value),
        child: Text(label),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Autonomy Controls', 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Status: $status'),
            SizedBox(height: 5),
            Text('Current Autonomy Level: $currentValue', 
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildControlButton('SAE_1 LKAS', 'SAE_1_LKAS')),
                SizedBox(width: 8),
                Expanded(child: _buildControlButton('SAE_1 ACC', 'SAE_1_ACC')),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(child: _buildControlButton('SAE_2', 'SAE_2')),
                SizedBox(width: 8),
                Expanded(child: _buildControlButton('SAE_3', 'SAE_3')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 4. Create the main vehicle control page:

```dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../services/zenoh_service.dart';
import '../widgets/autonomy_controls.dart';
import '../widgets/manual_controls.dart';

class ZenohRestPage extends StatefulWidget {
  @override
  State<ZenohRestPage> createState() => _ZenohRestPageState();
}

class _ZenohRestPageState extends State<ZenohRestPage> {
  String _status = 'Idle';
  String _currentValue = 'Unknown';

  // Zenoh router REST endpoint base URL.
  final String baseUrl = 'http://10.21.221.9:7447';
  
  // The key expression for the stored info
  final String keyExpr = 'Vehicle/1/ADAS/ActiveAutonomyLevel';
  
  // Create service
  late final ZenohService _zenohService;

  Timer? _statusTimer;
  Timer? _throttleDebounce;
  Timer? _steeringDebounce;
  double _throttle = 0.0;  // -100 to 100
  double _steering = 90.0;  // 0 to 180

  @override
  void initState() {
    super.initState();
    _zenohService = ZenohService(baseUrl: baseUrl);
    
    // Fetch the current status when the widget initializes
    getCurrentStatus();

    _statusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      getCurrentStatus();
    });
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    _throttleDebounce?.cancel();
    _steeringDebounce?.cancel();
    super.dispose();
  }

  Future<void> getCurrentStatus() async {
    setState(() {
      _status = 'Fetching current status...';
    });
    
    try {
      final value = await _zenohService.getCurrentAutonomyLevel(keyExpr);
      setState(() {
        _currentValue = value;
        _status = 'Current status retrieved successfully';
      });
    } catch (e) {
      setState(() {
        _status = 'Error fetching status: $e';
      });
    }
  }

  Future<void> updateZenohState(String autonomyLevel) async {
    setState(() {
      _status = 'Updating...';
    });
    
    try {
      final result = await _zenohService.updateAutonomyLevel(keyExpr, autonomyLevel);
      setState(() {
        _status = 'Update successful: $result';
      });
      
      // Get the current status after successful update
      await getCurrentStatus();
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }
  
  void updateThrottle(double value) {
    setState(() {
      _throttle = value;
    });
    
    // Cancel previous timer
    _throttleDebounce?.cancel();
    
    // Set new timer to send value after short delay
    _throttleDebounce = Timer(Duration(milliseconds: 50), () {
      _zenohService.setThrottle(_throttle);
    });
  }
  
  void updateSteering(double value) {
    setState(() {
      _steering = value;
    });
    
    // Cancel previous timer
    _steeringDebounce?.cancel();
    
    // Set new timer to send value after short delay
    _steeringDebounce = Timer(Duration(milliseconds: 50), () {
      _zenohService.setSteering(_steering);
    });
  }
  
  void resetControls() {
    setState(() {
      _throttle = 0.0;
      _steering = 90.0;
    });
    _zenohService.setThrottle(_throttle);
    _zenohService.setSteering(_steering);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vehicle Control'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Autonomy controls
              AutonomyControls(
                status: _status,
                currentValue: _currentValue,
                onAutonomyLevelChanged: updateZenohState,
              ),
              
              SizedBox(height: 20),
              
              // Manual controls
              ManualControls(
                zenohService: _zenohService,
                throttle: _throttle,
                steering: _steering,
                onThrottleChanged: updateThrottle,
                onSteeringChanged: updateSteering,
                onReset: resetControls,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 5. Finally, update the main.dart file:

```dart
import 'package:flutter/material.dart';
import 'screens/vehicle_control_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Car Controller App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ZenohRestPage(),
    );
  }
}
```

This separation of concerns makes your code:
1. More maintainable
2. Easier to test
3. More readable
4. Better structured for future expansion

Each file now has a single responsibility, following the SOLID principles of good software design.