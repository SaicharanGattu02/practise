import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Expanded(
          child: Dock(
            items:  [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (item, isDragging){
              return AnimatedContainer(
                duration:  Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                constraints:  BoxConstraints(minWidth: 48),
                height: 48,
                margin:  EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: isDragging
                      ? Colors.grey.shade300
                      : Colors.primaries[item.hashCode % Colors.primaries.length],
                ),
                child: Icon(
                  item,
                  color: isDragging ? Colors.black45 : Colors.white,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder for creating each [T] item.
  final Widget Function(T item, bool isDragging) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] widget with animated reordering.
class _DockState<T extends Object> extends State<Dock<T>> with SingleTickerProviderStateMixin {
  /// Current list of items.
  late List<T> _items = widget.items.toList();

  /// Index of the dragged item.
  int? _draggingIndex;

  /// Currently dragged item.
  T? _draggedItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding:  EdgeInsets.all(4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double itemWidth = 60.0;

          return Stack(
            alignment: Alignment.center,
            children: _items
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final item = entry.value;

              return AnimatedPositioned(
                key: ValueKey(item),
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                left: index * itemWidth,
                child: Draggable<T>(
                  data: item,
                  feedback: Material(
                    color: Colors.transparent,
                    child: widget.builder(item, true),
                  ),
                  childWhenDragging: const SizedBox.shrink(),
                  onDragStarted: () {
                    setState(() {
                      _draggingIndex = index;
                      _draggedItem = item;
                    });
                  },
                  onDragEnd: (details) {
                    setState(() {
                      _draggingIndex = null;
                      _draggedItem = null;
                    });
                  },
                  child: DragTarget<T>(
                    onWillAccept: (incomingItem) {
                      if (incomingItem != item) {
                        final oldIndex = _items.indexOf(incomingItem!);
                        setState(() {
                          _items.removeAt(oldIndex);
                          _items.insert(index, incomingItem);
                        });
                      }
                      return true;
                    },
                    onAccept: (_) {
                      setState(() {
                        _draggingIndex = null;
                        _draggedItem = null;
                      });
                    },
                    builder: (context, candidateData, rejectedData) {
                      return widget.builder(item, _draggingIndex == index);
                    },
                  ),
                ),
              );
            })
                .toList(),
          );
        },
      ),
    );
  }
}
