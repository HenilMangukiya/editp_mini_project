# 🖌️ EditP: Poster Creation App – Technical Documentation

## 1. Project Overview

**EditP** is a Flutter-based application designed to enable users to create stunning visual content such as posters, event flyers, social media graphics, and digital advertisements. It focuses on drag-and-drop simplicity and real-time customization, offering tools typically found in desktop design software, but in a mobile-friendly format.

### Vision
To empower individuals and teams to create impactful visual content without needing professional design experience.

### Problem Statement
Traditional graphic design tools are complex and not optimized for mobile or quick edits. EditP aims to solve this by offering an intuitive and lightweight solution for poster creation.

### Use Cases
- A college student designing event posters  
- A content creator preparing a YouTube thumbnail  
- A business manager promoting a flash sale  
- A teacher preparing announcements for school events  

---

## 2. Architecture

### High-Level Design
EditP uses a layered architecture consisting of:
- **Presentation Layer**: Screens and Widgets  
- **Business Logic Layer**: Controllers and Providers  
- **Data Layer**: Storage and asset services  
- **Platform Layer**: Flutter plugins, permissions, image picker  

### Internal Component Map
- `CanvasManager`: Controls element states, order, and updates  
- `ElementModel`: Data structure representing text/image/shape  
- `ThemeService`: Controls global theme switching  
- `UserSessionService`: Handles session state  
- `PosterStorageService`: Saves and retrieves project data  

### Communication Flow
`User Action → Widget → Provider → Service → Local Storage`

#### Example
```dart
// Saving a poster element
final element = PosterElement(type: ElementType.text, text: 'Welcome');
canvasProvider.addElement(element);
posterStorage.save(canvasProvider.elements);
```

---

## 3. Core Features

### a) Authentication System – Login and Registration

- Input validation for username, email, and password  
- Error feedback for invalid input  
- Toggle for password visibility  

#### Authentication Flow
1. User submits form  
2. Input is validated locally  
3. Credentials are stored using SharedPreferences  
4. A flag `isLoggedIn=true` is saved for session checking  

#### Session Management
- Persistent login via SharedPreferences  
- Logout clears data  
- Splash screen checks session on launch  

```dart
void saveSession(bool status) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('isLoggedIn', status);
}
```

---

### b) Home Screen

#### Poster Template Gallery
- `GridView` with custom cards  
- Posters shown with titles, thumbnails  
- Uses `Hero` animation for smooth navigation  

#### Recent Projects
- Pulls data from local cache  
- Shows last edited posters  
- “Resume” button opens in editor mode  

#### Dashboard Widgets
- Floating action button for “New Poster”  
- Profile picture with dropdown for Settings, Logout  

---

### c) Poster Editor (`CreatePosterScreen`)

#### Canvas
- Built with `Stack` and `Positioned` widgets  
- Element layering using z-index logic  
- Canvas supports pan and zoom  

#### Tools Toolbar
- Add: Text, Shape, Image, Sticker  
- Format: Font size, color, alignment  
- Modify: Move, Resize, Rotate  
- Customize: Background, Theme  

#### Text Tools
```dart
Text(
  'Hello World',
  style: GoogleFonts.roboto(
    fontSize: 24,
    color: Colors.white,
    fontWeight: FontWeight.bold,
  ),
)
```

#### Gesture System
- Tap: Select element  
- Drag: Move element  
- Pinch: Scale element  
- Rotate: Custom rotation widget using `Transform.rotate`  

#### Export Feature
```dart
Future<void> exportPoster() async {
  final boundary = canvasKey.currentContext.findRenderObject() as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 3.0);
  final byteData = await image.toByteData(format: ImageByteFormat.png);
  final pngBytes = byteData.buffer.asUint8List();
  // Save or share pngBytes
}
```

---

### d) Profile Management
- User avatar (from gallery or default icon)  
- Editable fields: Name, Bio, Theme  
- List of created posters  
- Preferences like “Auto-save”, “Snap-to-grid”, “Show grid lines”  

---

## 4. Technical Implementation Details

### a) UI Components
- **Modular Widgets**: `CustomTextField`, `DraggableSticker`, `ColorPickerPanel`  
- **Responsive Layout**:  
  - `LayoutBuilder` for element resizing  
  - Orientation handling for tablets and mobile  
- **Animations**:  
  - `AnimatedContainer`, `Hero`, `AnimatedOpacity`  

### b) Local Data Handling
- Posters stored in JSON format  
- Custom model serialization:

```dart
class PosterElement {
  final String type;
  final Offset position;
  final double width;
  final double height;
  final Map<String, dynamic> style;

  Map<String, dynamic> toJson() => {
    'type': type,
    'position': {'dx': position.dx, 'dy': position.dy},
    'width': width,
    'height': height,
    'style': style
  };
}
```

#### Load from storage:
```dart
Future<List<PosterElement>> loadPosters() async {
  final prefs = await SharedPreferences.getInstance();
  final data = prefs.getString('savedPoster');
  final list = jsonDecode(data);
  return list.map((e) => PosterElement.fromJson(e)).toList();
}
```

---

## 5. Canvas System

### Element Model
```dart
enum ElementType { text, shape, sticker, image }

class CanvasElement {
  final ElementType type;
  final Offset position;
  final double scale;
  final double rotation;
  final Map<String, dynamic> metadata;
}
```

### Interactions
- Drag: `LongPressDraggable`  
- Drop: `DragTarget`  
- Resize: Scale gestures with `Matrix` transformations  
- Rotate: Custom angle sliders and handles  

### Z-Index
- Maintained using element list ordering  
- `bringToFront()` reorders list  

### Snap to Grid
- Optional feature to auto-align to invisible grid  
- Adjustable grid spacing  

---

## 6. Dependencies and Plugins

| Dependency              | Version | Purpose                        |
|-------------------------|---------|--------------------------------|
| flutter                 | 3.x     | UI Framework                   |
| provider                | 6.x     | State Management               |
| shared_preferences      | 2.x     | Local Storage                  |
| google_fonts            | 3.x     | Font Styling                   |
| flutter_colorpicker     | 1.x     | Color Selection                |
| image_picker            | 1.x     | Image Insertion                |
| path_provider           | 2.x     | File System Access             |
| flutter_launcher_icons  | 0.13.x  | App Icon Generator             |
| screenshot              | 1.x     | For export to PNG              |
| vector_math             | 2.x     | Transformations for gestures   |

---

## 7. User Interface

### Navigation Flow
- Named route navigation  
- Bottom navigation for Home, Profile, Settings  
- Modal bottom sheets for tool panels  

### Layouts and Screens
- **Home**: Grid layout with cards  
- **Editor**: Stack-based canvas with toolbar  
- **Profile**: ScrollView with personal info and settings  

### Accessibility
- Contrast-friendly color schemes  
- Large clickable areas for better UX  
- Keyboard shortcuts for web builds (future)  

### Themes
```dart
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.blueAccent,
  fontFamily: 'Roboto',
);
```

---

## 8. Advanced Features

### Upcoming Capabilities
- Cloud backup via Firebase  
- Poster sharing via link or QR  
- Collaboration and multi-user editing  
- Undo/Redo with action stacks  
- Web and tablet versions  

### Performance Considerations
- Poster rendering optimization using `CustomPainter`  
- Lazy loading of assets  
- GPU-accelerated transformations  

### Testing Strategy
- Widget testing for canvas elements  
- Unit tests for model conversion  
- Integration testing for storage and load flow  

---

## 9. Developer Notes

### Coding Standards
- Follows Dart best practices  
- `CamelCase` for classes and methods  
- Constants and themes moved to `utils/constants.dart`  

### Contribution Guide
1. Fork repository  
2. Use `feature/` branch naming  
3. Format code with `dart format .`  
4. Submit pull requests with description  

### CI/CD Plan (Future)
- GitHub Actions for:  
  - Test execution  
  - Code formatting check  
  - Build verification  

---

## 10. Conclusion

EditP bridges the gap between complex design software and mobile-first simplicity. With a strong architectural foundation, modular design, and forward-looking features, the application serves as a powerful design tool for creatives, students, and professionals alike.

Future development will include collaboration features, cloud syncing, AI integrations, and cross-platform support to meet growing user needs.
