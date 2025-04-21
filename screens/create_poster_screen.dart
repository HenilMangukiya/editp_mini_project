import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Canvas element types
enum ElementType {
  text,
  shape,
  icon,
  sticker,
  image,
}

// Text style presets
class TextStylePreset {
  final String name;
  final TextStyle style;

  TextStylePreset(this.name, this.style);
}

// Base class for canvas elements
class CanvasElement {
  final String id;
  final ElementType type;
  final Offset position;
  final Size size;
  final Map<String, dynamic> properties;
  final double rotation;

  CanvasElement({
    required this.id,
    required this.type,
    required this.position,
    required this.size,
    required this.properties,
    this.rotation = 0.0,
  });

  CanvasElement copyWith({
    String? id,
    ElementType? type,
    Offset? position,
    Size? size,
    Map<String, dynamic>? properties,
    double? rotation,
  }) {
    return CanvasElement(
      id: id ?? this.id,
      type: type ?? this.type,
      position: position ?? this.position,
      size: size ?? this.size,
      properties: properties ?? Map.from(this.properties),
      rotation: rotation ?? this.rotation,
    );
  }
}

class CreatePosterScreen extends StatefulWidget {
  const CreatePosterScreen({super.key});

  @override
  State<CreatePosterScreen> createState() => _CreatePosterScreenState();
}

class _CreatePosterScreenState extends State<CreatePosterScreen> {
  int _selectedToolIndex = 0;
  final List<String> _tools = ['Elements', 'Text', 'Background', 'Effects'];
  final List<CanvasElement> _canvasElements = [];
  CanvasElement? _selectedElement;
  int _elementCounter = 0;
  Color _backgroundColor = Colors.white;
  double _backgroundOpacity = 1.0;
  LinearGradient? _backgroundGradient;
  final TextEditingController _textController = TextEditingController();
  bool _isEditingText = false;

  // Modern font styles
  final List<TextStylePreset> _textStyles = [
    TextStylePreset(
        'Modern',
        GoogleFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        )),
    TextStylePreset(
        'Elegant',
        GoogleFonts.playfairDisplay(
          fontSize: 28,
          fontWeight: FontWeight.w500,
          fontStyle: FontStyle.italic,
        )),
    TextStylePreset(
        'Bold',
        GoogleFonts.montserrat(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        )),
    TextStylePreset(
        'Minimal',
        GoogleFonts.raleway(
          fontSize: 22,
          fontWeight: FontWeight.w300,
          letterSpacing: 2,
        )),
    TextStylePreset(
        'Creative',
        GoogleFonts.dancingScript(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        )),
    TextStylePreset(
        'Tech',
        GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          letterSpacing: 1,
        )),
  ];

  // Resize handles
  final List<Offset> _resizeHandles = [
    const Offset(-1, -1), // Top-left
    const Offset(1, -1), // Top-right
    const Offset(-1, 1), // Bottom-left
    const Offset(1, 1), // Bottom-right
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Poster'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              // TODO: Implement save functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {
              // TODO: Implement share functionality
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Tools Panel
          Container(
            width: 280,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border(
                right: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: Column(
              children: [
                // Tools Tabs
                Container(
                  height: 48,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tools.length,
                    itemBuilder: (context, index) {
                      final isSelected = _selectedToolIndex == index;
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedToolIndex = index;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                            ),
                            child: Text(
                              _tools[index],
                              style: TextStyle(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).colorScheme.onSurface,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Tools Content
                Expanded(
                  child: _buildToolsContent(),
                ),
              ],
            ),
          ),
          // Canvas Area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: _backgroundColor,
                gradient: _backgroundGradient,
              ),
              child: Stack(
                children: [
                  // Canvas Grid
                  CustomPaint(
                    painter: GridPainter(),
                    child: Container(),
                  ),
                  // Canvas Elements
                  ..._canvasElements
                      .map((element) => _buildCanvasElement(element)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasElement(CanvasElement element) {
    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            final index = _canvasElements.indexOf(element);
            _canvasElements[index] = element.copyWith(
              position: element.position + details.delta,
            );
          });
        },
        onTap: () {
          setState(() {
            _selectedElement = element;
            if (element.type == ElementType.text) {
              _textController.text = element.properties['text'] ?? '';
              _isEditingText = true;
            }
          });
        },
        child: Transform.rotate(
          angle: element.rotation,
          child: Container(
            width: element.size.width,
            height: element.size.height,
            decoration: BoxDecoration(
              border: _selectedElement?.id == element.id
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: Stack(
              children: [
                _buildElementContent(element),
                if (_selectedElement?.id == element.id)
                  ..._buildResizeHandles(element),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildResizeHandles(CanvasElement element) {
    return _resizeHandles.map((handle) {
      final isLeft = handle.dx < 0;
      final isTop = handle.dy < 0;
      return Positioned(
        left: isLeft ? 0 : element.size.width - 10,
        top: isTop ? 0 : element.size.height - 10,
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              final index = _canvasElements.indexOf(element);
              final newWidth = element.size.width + (isLeft ? -details.delta.dx : details.delta.dx);
              final newHeight = element.size.height + (isTop ? -details.delta.dy : details.delta.dy);
              final newPosition = Offset(
                element.position.dx + (isLeft ? details.delta.dx : 0),
                element.position.dy + (isTop ? details.delta.dy : 0),
              );
              _canvasElements[index] = element.copyWith(
                size: Size(newWidth, newHeight),
                position: newPosition,
              );
            });
          },
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _buildElementContent(CanvasElement element) {
    switch (element.type) {
      case ElementType.text:
        return _isEditingText && _selectedElement?.id == element.id
            ? TextField(
                controller: _textController,
                style: element.properties['textStyle'] as TextStyle?,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                maxLines: null,
                onChanged: (text) {
                  setState(() {
                    final index = _canvasElements.indexOf(element);
                    _canvasElements[index] = element.copyWith(
                      properties: {
                        ...element.properties,
                        'text': text,
                      },
                    );
                  });
                },
                onEditingComplete: () {
                  setState(() {
                    _isEditingText = false;
                  });
                },
              )
            : Text(
                element.properties['text'] ?? '',
                style: element.properties['textStyle'] as TextStyle?,
              );
      case ElementType.shape:
        return Container(
          width: element.size.width,
          height: element.size.height,
          decoration: BoxDecoration(
            color: element.properties['color'] ?? Colors.transparent,
            border: element.properties['borderWidth'] != null &&
                    element.properties['borderWidth'] > 0
                ? Border.all(
                    color: element.properties['borderColor'] ?? Colors.black,
                    width: element.properties['borderWidth'] ?? 2.0,
                  )
                : null,
            borderRadius: BorderRadius.circular(
              element.properties['borderRadius'] ?? 0.0,
            ),
          ),
          child: Icon(
            element.properties['icon'] ?? Icons.square_outlined,
            size: element.size.width * 0.6,
            color: element.properties['iconColor'] ?? Colors.black,
          ),
        );
      case ElementType.icon:
        return Icon(
          element.properties['icon'] ?? Icons.emoji_emotions_outlined,
          size: element.size.width,
          color: element.properties['color'] ?? Colors.black,
        );
      case ElementType.sticker:
        return Icon(
          element.properties['icon'] ?? Icons.celebration_outlined,
          size: element.size.width,
          color: element.properties['color'] ?? Colors.black,
        );
      case ElementType.image:
        return Image.asset(
          element.properties['asset'] ?? '',
          width: element.size.width,
          height: element.size.height,
          fit: BoxFit.cover,
        );
    }
  }

  void _addElement(ElementType type, Map<String, dynamic> properties) {
    setState(() {
      _elementCounter++;
      _canvasElements.add(
        CanvasElement(
          id: 'element_$_elementCounter',
          type: type,
          position: const Offset(100, 100),
          size: type == ElementType.text ? const Size(200, 50) : const Size(100, 100),
          properties: {
            ...properties,
            'color': type == ElementType.shape ? Colors.transparent : Colors.black,
            'iconColor': Colors.black,
          },
        ),
      );
    });
  }

  Widget _buildToolsContent() {
    switch (_selectedToolIndex) {
      case 0:
        return _buildElementsPanel();
      case 1:
        return _buildTextPanel();
      case 2:
        return _buildBackgroundPanel();
      case 3:
        return _buildEffectsPanel();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildElementsPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildElementCategory('Shapes', [
          Icons.circle_outlined,
          Icons.square_outlined,
          Icons.rectangle_outlined,
          Icons.hexagon_outlined,
          Icons.change_history_outlined,
          Icons.star_outline,
          Icons.favorite_outline,
          Icons.emoji_emotions_outlined,
        ], ElementType.shape),
        const SizedBox(height: 24),
        _buildElementCategory('Icons', [
          Icons.favorite_outline,
          Icons.star_outline,
          Icons.emoji_emotions_outlined,
          Icons.music_note_outlined,
          Icons.sports_soccer_outlined,
          Icons.local_cafe_outlined,
          Icons.local_pizza_outlined,
          Icons.local_mall_outlined,
        ], ElementType.icon),
        const SizedBox(height: 24),
        _buildElementCategory('Stickers', [
          Icons.celebration_outlined,
          Icons.local_fire_department_outlined,
          Icons.auto_awesome_outlined,
          Icons.workspace_premium_outlined,
          Icons.rocket_launch_outlined,
          Icons.mood_outlined,
          Icons.thumb_up_outlined,
          Icons.thumb_down_outlined,
        ], ElementType.sticker),
        if (_selectedElement?.type == ElementType.shape) ...[
          const SizedBox(height: 24),
          Text(
            'Shape Properties',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildColorPicker(),
          const SizedBox(height: 8),
          _buildBorderColorPicker(),
          const SizedBox(height: 8),
          _buildBorderWidthSlider(),
          const SizedBox(height: 8),
          _buildBorderRadiusSlider(),
          const SizedBox(height: 8),
          _buildIconColorPicker(),
        ],
      ],
    );
  }

  Widget _buildElementCategory(
      String title, List<IconData> icons, ElementType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: icons.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: InkWell(
                onTap: () {
                  _addElement(type, {'icon': icons[index]});
                },
                borderRadius: BorderRadius.circular(8),
                child: Center(
                  child: Icon(icons[index]),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTextPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: _textController,
          decoration: const InputDecoration(
            labelText: 'Add Text',
            hintText: 'Type something...',
          ),
          maxLines: 3,
          onSubmitted: (text) {
            if (text.isNotEmpty) {
              _addElement(
                ElementType.text,
                {
                  'text': text,
                  'textStyle': _textStyles[0].style,
                },
              );
              _textController.clear();
            }
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Text Styles',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _textStyles.length,
          itemBuilder: (context, index) {
            final style = _textStyles[index];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: InkWell(
                onTap: () {
                  if (_selectedElement?.type == ElementType.text) {
                    setState(() {
                      final index = _canvasElements.indexOf(_selectedElement!);
                      _canvasElements[index] = _selectedElement!.copyWith(
                        properties: {
                          ..._selectedElement!.properties,
                          'textStyle': style.style,
                        },
                      );
                    });
                  } else {
                    _addElement(
                      ElementType.text,
                      {
                        'text': 'Double click to edit',
                        'textStyle': style.style,
                      },
                    );
                  }
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        style.name,
                        style: style.style.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Aa',
                        style: style.style,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        if (_selectedElement?.type == ElementType.text) ...[
          const SizedBox(height: 16),
          Text(
            'Text Properties',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          _buildColorPicker(),
          const SizedBox(height: 8),
          _buildFontSizeSlider(),
          const SizedBox(height: 8),
          _buildBoldToggle(),
        ],
      ],
    );
  }

  Widget _buildBackgroundPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Solid Colors',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 10,
          itemBuilder: (context, index) {
            final color = Colors.primaries[index % Colors.primaries.length];
            return InkWell(
              onTap: () {
                setState(() {
                  _backgroundColor = color;
                  _backgroundGradient = null;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Gradients',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            final colors = [
              Colors.primaries[index % Colors.primaries.length],
              Colors.primaries[(index + 1) % Colors.primaries.length],
            ];
            return Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _backgroundGradient = LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    );
                    _backgroundColor = Colors.transparent;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
        Text(
          'Opacity',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Slider(
          value: _backgroundOpacity,
          onChanged: (value) {
            setState(() {
              _backgroundOpacity = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fill Color',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...Colors.primaries.map((color) => InkWell(
                  onTap: () {
                    setState(() {
                      final index = _canvasElements.indexOf(_selectedElement!);
                      _canvasElements[index] = _selectedElement!.copyWith(
                        properties: {
                          ..._selectedElement!.properties,
                          'color': color,
                        },
                      );
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildFontSizeSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Font Size',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Slider(
          value: _selectedElement?.properties['fontSize'] ?? 16.0,
          min: 8.0,
          max: 72.0,
          onChanged: (value) {
            setState(() {
              final index = _canvasElements.indexOf(_selectedElement!);
              _canvasElements[index] = _selectedElement!.copyWith(
                properties: {
                  ..._selectedElement!.properties,
                  'fontSize': value,
                },
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildBoldToggle() {
    return Row(
      children: [
        Text(
          'Bold',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const Spacer(),
        Switch(
          value: _selectedElement?.properties['bold'] ?? false,
          onChanged: (value) {
            setState(() {
              final index = _canvasElements.indexOf(_selectedElement!);
              _canvasElements[index] = _selectedElement!.copyWith(
                properties: {
                  ..._selectedElement!.properties,
                  'bold': value,
                },
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildBorderColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Border Color',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...Colors.primaries.map((color) => InkWell(
                  onTap: () {
                    setState(() {
                      final index = _canvasElements.indexOf(_selectedElement!);
                      _canvasElements[index] = _selectedElement!.copyWith(
                        properties: {
                          ..._selectedElement!.properties,
                          'borderColor': color,
                        },
                      );
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildBorderWidthSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Border Width',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Slider(
          value: _selectedElement?.properties['borderWidth'] ?? 2.0,
          min: 0.0,
          max: 10.0,
          onChanged: (value) {
            setState(() {
              final index = _canvasElements.indexOf(_selectedElement!);
              _canvasElements[index] = _selectedElement!.copyWith(
                properties: {
                  ..._selectedElement!.properties,
                  'borderWidth': value,
                },
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildBorderRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Border Radius',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Slider(
          value: _selectedElement?.properties['borderRadius'] ?? 0.0,
          min: 0.0,
          max: 50.0,
          onChanged: (value) {
            setState(() {
              final index = _canvasElements.indexOf(_selectedElement!);
              _canvasElements[index] = _selectedElement!.copyWith(
                properties: {
                  ..._selectedElement!.properties,
                  'borderRadius': value,
                },
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildIconColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Icon Color',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ...Colors.primaries.map((color) => InkWell(
                  onTap: () {
                    setState(() {
                      final index = _canvasElements.indexOf(_selectedElement!);
                      _canvasElements[index] = _selectedElement!.copyWith(
                        properties: {
                          ..._selectedElement!.properties,
                          'iconColor': color,
                        },
                      );
                    });
                  },
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildEffectsPanel() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildEffectCategory('Filters', [
          'Normal',
          'Grayscale',
          'Sepia',
          'Vintage',
        ]),
        const SizedBox(height: 24),
        _buildEffectCategory('Adjustments', [
          'Brightness',
          'Contrast',
          'Saturation',
          'Blur',
        ]),
      ],
    );
  }

  Widget _buildEffectCategory(String title, List<String> effects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        ...effects.map((effect) => Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: ListTile(
                title: Text(effect),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Apply effect
                },
              ),
            )),
      ],
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..strokeWidth = 1;

    const spacing = 20.0;

    for (double i = 0; i < size.width; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i < size.height; i += spacing) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
