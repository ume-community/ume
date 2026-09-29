import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tuple/tuple.dart';
import 'package:ume_core/ume_core.dart';
import 'package:ume_core/util/floating_widget.dart';
import 'package:flutter_svg_provider/flutter_svg_provider.dart';

class BlocInspectorEvent {
  final String blocName;
  final String type;
  final dynamic data;
  final DateTime timestamp;

  BlocInspectorEvent({
    required this.blocName,
    required this.type,
    this.data,
    required this.timestamp,
  });

  @override
  String toString() {
    return '[$timestamp] $blocName - $type: $data';
  }
}

class BlocInspectorManager {
  static final BlocInspectorManager instance = BlocInspectorManager._();
  BlocInspectorManager._();

  final List<BlocInspectorEvent> _events = [];
  final List<BlocBase> _blocs = [];
  final StreamController<void> _updateController = StreamController.broadcast();

  List<BlocInspectorEvent> get events => _events;
  List<BlocBase> get blocs => _blocs;
  Stream<void> get onUpdate => _updateController.stream;

  void addEvent(BlocInspectorEvent event) {
    _events.insert(0, event);
    if (_events.length > 100) {
      _events.removeLast();
    }
    _updateController.add(null);
  }

  void addBloc(BlocBase bloc) {
    _blocs.insert(0, bloc);
    _updateController.add(null);
  }

  void removeBloc(BlocBase bloc) {
    _blocs.remove(bloc);
    _updateController.add(null);
  }

  void clear() {
    _events.clear();
    _updateController.add(null);
  }
}

class UmeBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    BlocInspectorManager.instance.addBloc(bloc);
    BlocInspectorManager.instance.addEvent(
      BlocInspectorEvent(
        blocName: bloc.runtimeType.toString(),
        type: 'onCreate',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    BlocInspectorManager.instance.addEvent(
      BlocInspectorEvent(
        blocName: bloc.runtimeType.toString(),
        type: 'onEvent',
        data: event.toString(),
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    BlocInspectorManager.instance.addEvent(
      BlocInspectorEvent(
        blocName: bloc.runtimeType.toString(),
        type: 'onChange',
        data: 'State: ${change.nextState.runtimeType}',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    BlocInspectorManager.instance.addEvent(
      BlocInspectorEvent(
        blocName: bloc.runtimeType.toString(),
        type: 'onTransition',
        data:
            'Event: ${transition.event.runtimeType}, Current: ${transition.currentState.runtimeType}, Next: ${transition.nextState.runtimeType}',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    BlocInspectorManager.instance.addEvent(
      BlocInspectorEvent(
        blocName: bloc.runtimeType.toString(),
        type: 'onError',
        data: error.toString(),
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    BlocInspectorManager.instance.removeBloc(bloc);
    BlocInspectorManager.instance.addEvent(
      BlocInspectorEvent(
        blocName: bloc.runtimeType.toString(),
        type: 'onClose',
        timestamp: DateTime.now(),
      ),
    );
  }
}

class BlocInspector extends StatefulWidget implements Pluggable {
  const BlocInspector({Key? key}) : super(key: key);

  static void initialize() {
    Bloc.observer = UmeBlocObserver();
  }

  @override
  String get name => 'BLoCInspector';

  @override
  String get displayName => 'BLoCInspector';

  @override
  // 读取assets/icon.svg
  ImageProvider<Object> get iconImageProvider => const Svg('assets/icon.svg');

  @override
  Widget buildWidget(BuildContext? context) => const BlocInspector();

  @override
  void onTrigger() {}

  @override
  State<BlocInspector> createState() => _BlocInspectorState();
}

class _BlocInspectorState extends State<BlocInspector>
    with SingleTickerProviderStateMixin {
  final _manager = BlocInspectorManager.instance;
  late StreamSubscription _subscription;
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _subscription = _manager.onUpdate.listen((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    _tabController?.dispose();
    super.dispose();
  }

  String _prettyJson(dynamic data) {
    try {
      var encoder = const JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final events = _manager.events;
    final blocs = _manager.blocs;
    final content = Scaffold(
      backgroundColor: Colors.transparent,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Events'),
              Tab(text: 'Active BLoCs'),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListTile(
                title: Text('${event.blocName} - ${event.type}'),
                subtitle: event.data != null
                    ? Text(event.data.toString())
                    : null,
                trailing: Text(
                  '${event.timestamp.hour}:${event.timestamp.minute}:${event.timestamp.second}',
                ),
              );
            },
          ),
          ListView.builder(
            itemCount: blocs.length,
            itemBuilder: (context, index) {
              final bloc = blocs[index];
              return ListTile(
                title: Text(bloc.runtimeType.toString()),
                subtitle: Text('State: ${bloc.state.runtimeType}'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(bloc.runtimeType.toString()),
                      content: SingleChildScrollView(
                        child: Text(_prettyJson(bloc.state)),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );

    return FloatingWidget(
      contentWidget: content,
      toolbarActions: [
        Tuple3('Clear', const Icon(Icons.delete, size: 20), () {
          setState(() {
            _manager.clear();
          });
        }),
      ],
    );
  }
}
