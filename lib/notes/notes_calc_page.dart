import 'package:cupertino_ui/cupertino_ui.dart';
import 'database/notes_database.dart';
import 'model/note_item.dart';
import 'theme/notes_theme.dart';
import 'utils/debounce.dart';
import 'utils/math_evaluator.dart';
import 'widget/editable_title_card.dart';
import 'widget/note_line_card.dart';
import 'widget/total_bottom_card.dart';

class NotesCalcPage extends StatefulWidget {
  const NotesCalcPage({super.key});

  @override
  State<NotesCalcPage> createState() => _NotesCalcPageState();
}

class _NotesCalcPageState extends State<NotesCalcPage> {
  late final NotesDatabase _database;
  late final Debouncer _debouncer;
  late final TextEditingController _titleController;
  late final List<TextEditingController> _lineControllers;
  late final List<FocusNode> _lineFocusNodes;

  List<NoteItem> _items = [];
  double _grandTotal = 0.0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _database = NotesDatabase();
    _debouncer = Debouncer();
    _titleController = TextEditingController();

    _lineControllers = List.generate(20, (_) => TextEditingController());
    _lineFocusNodes = List.generate(20, (_) => FocusNode());

    _loadData();
  }

  Future<void> _loadData() async {
    final (title, items) = await _database.loadOrCreateDefaultSheet();
    _titleController.text = title;
    _items = items;

    for (int i = 0; i < _items.length; i++) {
      _lineControllers[i].text = _items[i].text;
    }

    _recalculate(persist: false);
    setState(() => _isLoading = false);
  }

  void _recalculate({bool persist = true}) {
    final (updatedItems, total) = MathEvaluator.computeDocument(_items);
    setState(() {
      _items = updatedItems;
      _grandTotal = total;
    });

    if (persist) {
      _debouncer.run(() {
        _database.saveSheet(title: _titleController.text, items: _items);
      });
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
    _debouncer.dispose();
    _titleController.dispose();
    for (final c in _lineControllers) {
      c.dispose();
    }
    for (final f in _lineFocusNodes) {
      f.dispose();
    }
    _database.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CupertinoPageScaffold(
        child: Center(child: CupertinoActivityIndicator()),
      );
    }

    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground,
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Notes Calculator'),
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
    );
  }
}
