import 'package:cupertino_ui/cupertino_ui.dart';
import 'database/notes_database.dart';
import 'model/note_item.dart';
import 'utils/debounce.dart';
import 'utils/math_evaluator.dart';
import 'widget/editable_title_card.dart';
import 'widget/note_line_card.dart';
import 'widget/total_bottom_card.dart';

class NotesCalcPage extends StatefulWidget {
  final int? sheetId;

  const NotesCalcPage({super.key, this.sheetId});

  @override
  State<NotesCalcPage> createState() => _NotesCalcPageState();
}

class _NotesCalcPageState extends State<NotesCalcPage> {
  late final Debouncer _debouncer;
  late final TextEditingController _titleController;
  late final List<TextEditingController> _lineControllers;
  late final List<FocusNode> _lineFocusNodes;

  int _currentSheetId = 0;
  List<NoteItem> _items = [];
  double _grandTotal = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _debouncer = Debouncer();
    _titleController = TextEditingController();
    _lineControllers = List.generate(20, (_) => TextEditingController());
    _lineFocusNodes = List.generate(20, (_) => FocusNode());

    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final (id, title, items) = await NotesDatabase.instance.loadOrCreateSheet(
        widget.sheetId,
      );
      _currentSheetId = id;
      _titleController.text = title;
      _items = items;

      for (int i = 0; i < _items.length; i++) {
        _lineControllers[i].text = _items[i].text;
      }

      _recalculate(persist: false);
    } catch (e) {
      _items = List.generate(
        20,
        (i) => NoteItem(index: i, text: '', type: LineType.standard),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _recalculate({bool persist = true}) {
    final (updatedItems, total) = MathEvaluator.computeDocument(_items);
    setState(() {
      _items = updatedItems;
      _grandTotal = total;
    });

    if (persist && _currentSheetId > 0) {
      _debouncer.run(_flushSave);
    }
  }

  /// Synchronously cancels debounce timer and guarantees immediate save on exit
  void _flushSave() {
    if (_currentSheetId > 0) {
      _debouncer.dispose();
      NotesDatabase.instance.saveSheet(
        sheetId: _currentSheetId,
        title: _titleController.text,
        grandTotal: _grandTotal,
        items: _items,
      );
    }
  }

  void _handleTextChanged(int index, String text) {
    _items[index] = _items[index].copyWith(text: text);
    _recalculate();
  }

  void _handleSubtotalToggled(int index) {
    final current = _items[index];
    final nextType = current.type.isSubtotal
        ? LineType.standard
        : LineType.subtotal;

    if (nextType == LineType.subtotal) {
      _lineControllers[index].text = 'Subtotal';
      _items[index] = current.copyWith(type: nextType, text: 'Subtotal');
    } else {
      _lineControllers[index].text = '';
      _items[index] = current.copyWith(type: nextType, text: '');
    }

    _recalculate();
  }

  void _handleSubmitted(int index) {
    if (index < _lineFocusNodes.length - 1) {
      _lineFocusNodes[index + 1].requestFocus();
    } else {
      _lineFocusNodes[index].unfocus();
    }
  }

  @override
  void dispose() {
    _flushSave();
    _titleController.dispose();
    for (final c in _lineControllers) {
      c.dispose();
    }
    for (final f in _lineFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) {
          // Immediately flush to database on back button or gesture swipe-back
          _flushSave();
        }
      },
      child: CupertinoPageScaffold(
        backgroundColor: CupertinoColors.systemGroupedBackground,
        navigationBar: CupertinoNavigationBar(
          transitionBetweenRoutes: false,
          middle: Text(
            _titleController.text.isEmpty ? 'Notes' : _titleController.text,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top Card: Editable Title (~100px)
              EditableTitleCard(
                controller: _titleController,
                onChanged: (_) => _recalculate(),
              ),

              // Scrollable 20 Note Line Cards
              Expanded(
                child: ListView.builder(
                  itemCount: 20,
                  padding: const EdgeInsets.only(bottom: 8),
                  itemBuilder: (context, index) {
                    return NoteLineCard(
                      key: ValueKey('note_line_$index'),
                      item: _items[index],
                      controller: _lineControllers[index],
                      focusNode: _lineFocusNodes[index],
                      onTextChanged: (val) => _handleTextChanged(index, val),
                      onSubtotalToggled: () => _handleSubtotalToggled(index),
                      onSubmitted: () => _handleSubmitted(index),
                    );
                  },
                ),
              ),

              // Pinned Bottom Grand Total Card
              TotalBottomCard(totalAmount: _grandTotal),
            ],
          ),
        ),
      ),
    );
  }
}
