import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:restaurant_helper/constants.dart';
import 'package:restaurant_helper/model/auth.dart';
import 'package:restaurant_helper/model/planner_table.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'planner_border.dart';
import 'planner_object.dart';

part 'planner_tables_board.freezed.dart';
part 'planner_tables_board.g.dart';

enum PlannerDirection {
  left,
  right,
  top,
  bottom;

  bool get isHorizontal =>
      this == PlannerDirection.left || this == PlannerDirection.right;
  bool get isVertical =>
      this == PlannerDirection.top || this == PlannerDirection.bottom;

  int get sizeMultiplier =>
      (this == PlannerDirection.left || this == PlannerDirection.top) ? -1 : 1;
}

enum BoardStatus {
  uninitialized,
  empty,
  standard,
}

enum BoardAction {
  none,
  initializing,
  placeBorder,
  chooseExtendBorder,
  chooseBorderType,
  addTable,
  tableInfo,
  resizeLeft,
  resizeRight,
  resizeTop,
  resizeBottom,
  moveTable;

  SystemMouseCursor? get cursor {
    switch (this) {
      case resizeLeft:
      case resizeRight:
        return SystemMouseCursors.resizeLeftRight;
      case resizeTop:
      case resizeBottom:
        return SystemMouseCursors.resizeUpDown;
      case moveTable:
        return SystemMouseCursors.move;
      case placeBorder:
      case addTable:
        return SystemMouseCursors.click;
      default:
        return null;
    }
  }
}

@freezed
class PlannerTablesBoard with _$PlannerTablesBoard {
  const PlannerTablesBoard._();
  @JsonSerializable(fieldRename: FieldRename.snake)
  factory PlannerTablesBoard({
    required List<PlannerTable> tables,
    required List<PlannerBorder> borders,
    required double precision,
    @JsonKey(ignore: true) @Default(true) bool editable,
    @JsonKey(ignore: true)
    @Default(BoardAction.none)
    BoardAction? currentAction,
    @JsonKey(ignore: true) int? selectedTable,
    @JsonKey(ignore: true) PlannerDirection? lastBorderExtension,
    @JsonKey(ignore: true) PlannerDirection? currentBorderExtension,
    @JsonKey(ignore: true)
    @Default(BoxConstraints())
    BoxConstraints constraints,
  }) = _PlannerTablesBoard;

  factory PlannerTablesBoard.fromJson(Map<String, dynamic> json) =>
      _$PlannerTablesBoardFromJson(json);

  BoardStatus get status {
    if (precision <= -1 || currentAction == BoardAction.initializing) {
      return BoardStatus.uninitialized;
    }
    if (tables.isEmpty && borders.isEmpty) {
      return BoardStatus.empty;
    }
    return BoardStatus.standard;
  }

  bool canUpdateTable(String id, {required bool isTable}) {
    final PlannerObject data = isTable
        ? tables.where((element) => element.id == id).first
        : borders[int.parse(id)];
    return doesTableNotCollide(data, id, isTable: isTable) && isTableInBounds(data);
  }

  bool doesTableNotCollide(PlannerObject data, String id, {required bool isTable}) {
    for (final table in tables) {
      if ((!isTable || table.id != id) &&
          data.toNewRect(precision).overlaps(table.applyTablesToCollision(
              table.toNewRect(precision), precision))) {
        return false;
      }
    }
    for (final (i, border) in borders.indexed) {
      if ((isTable || i != int.parse(id)) &&
          data.toNewRect(precision).overlaps(border.toRect(precision))) {
        return false;
      }
    }
    return true;
  }

  bool extendBorderOnEnd() {
    return lastBorderExtension == PlannerDirection.bottom ||
        lastBorderExtension == PlannerDirection.right;
  }

  bool canExtendBorderInDirection(int index, PlannerDirection direction) {
    for (final table in tables) {
      if (borders[index - 1 > 0 ? index - 1 : 0]
          .toExtendRect(precision, direction, onEnd: extendBorderOnEnd())
          .overlaps(table.toRect())) {
        return false;
      }
    }
    for (final border in borders) {
      if (borders[index - 1 > 0 ? index - 1 : 0]
          .toExtendRect(precision, direction, onEnd: extendBorderOnEnd())
          .overlaps(border.toRect(precision))) {
        return false;
      }
    }
    return true;
  }

  bool canAddChairs(PlannerDirection direction) {
    final table = tables[selectedTable!];
    switch (direction) {
      case PlannerDirection.top:
        if (table.width < (table.seatsTop + 1) * precision) {
          return false;
        }
        break;
      case PlannerDirection.bottom:
        if (table.width < (table.seatsBottom + 1) * precision) {
          return false;
        }
        break;
      case PlannerDirection.left:
        if (table.height < (table.seatsLeft + 1) * precision) {
          return false;
        }
        break;
      case PlannerDirection.right:
        if (table.height < (table.seatsRight + 1) * precision) {
          return false;
        }
        break;
    }
    final newRect = table
        .modifyChairs(direction, precision, false)
        .applyTablesToCollision(table.toRect(), precision);
    final id = table.id;
    for (final table in tables) {
      if (table.id != id &&
          newRect.overlaps(table.applyTablesToCollision(
              table.toNewRect(precision), precision))) {
        return false;
      }
    }
    for (final border in borders) {
      if (newRect.overlaps(border.toRect(precision))) {
        return false;
      }
    }
    return true;
  }

  bool canSubtractChairs(PlannerDirection direction) {
    final table = tables[selectedTable!];
    switch (direction) {
      case PlannerDirection.top:
        return table.seatsTop > 0;
      case PlannerDirection.bottom:
        return table.seatsBottom > 0;
      case PlannerDirection.left:
        return table.seatsLeft > 0;
      case PlannerDirection.right:
        return table.seatsRight > 0;
    }
  }

  bool isTableInBounds(PlannerObject data) {
    final Rect newRect = data.toNewRect(precision);
    return !(newRect.left < 0 ||
        newRect.top < 0 ||
        newRect.left + newRect.width > constraints.maxWidth ||
        newRect.top + newRect.height > constraints.maxHeight);
  }

  bool isBorderFinished() {
    if (borders.length < 4) {
      return false;
    }
    return borders.first.toBroadenedRect(precision).overlaps(borders.last
        .onDragEnd(DragEndDetails(), precision)
        .toBroadenedRect(precision));
  }

  bool isSelectedTable(PlannerTable table) {
    return table == tables.elementAtOrNull(selectedTable ?? tables.length);
  }
}

@riverpod
class PlannerBoard extends _$PlannerBoard {
  @override
  Future<PlannerTablesBoard> build() async {
    final token = ref.read(authProvider);
    try {
      final response = await Dio().get('${dotenv.env['API_URL']!}planner-info',
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      return PlannerTablesBoard.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak przy wczytywaniu planu restauracji. Spróbuj ponownie później",
            true);
      }
    }
    return PlannerTablesBoard(precision: -1, tables: [], borders: []);
  }

  void updateConstraints(BoxConstraints constraints) {
    state = AsyncData(state.value!.copyWith(constraints: constraints));
  }

  void onTableDragStart(String id, DragStartDetails details,
      [PlannerDirection? direction]) {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!.copyWith(tables: [
      for (final table in state.value!.tables)
        if (table.id == id) table.onDragStart(details, direction) else table
    ]));
  }

  void onTableDragUpdate(String id, DragUpdateDetails details,
      [PlannerDirection? direction]) {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!.copyWith(tables: [
      for (final table in state.value!.tables)
        if (table.id == id)
          table.onDragUpdate(details, state.value!.precision, direction)
        else
          table
    ]));
  }

  void onTableDragEnd(
    String id,
    DragEndDetails details,
  ) {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!.copyWith(tables: [
      for (final table in state.value!.tables)
        if (table.id == id)
          state.value!.canUpdateTable(id, isTable: true)
              ? table.onDragEnd(details, state.value!.precision)
              : table.resetDrag()
        else
          table
    ]));
  }

  void onBorderDragStart(DragStartDetails details,
      [PlannerDirection? direction]) {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!.copyWith(borders: [
      ...List.from(state.value!.borders)..removeLast(),
      state.value!.borders.length > 1
          ? state.value!.borders.last.onPlaceAndDragStart(
              details,
              direction!,
              state.value!.borders[state.value!.borders.length - 2]
                  .toExtendRect(state.value!.precision, direction,
                      onEnd: state.value!.extendBorderOnEnd()))
          : state.value!.borders.last.onDragStart(details, direction)
    ], currentBorderExtension: direction));
  }

  void onBorderDragUpdate(DragUpdateDetails details,
      [PlannerDirection? direction]) {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!.copyWith(borders: [
      ...List.from(state.value!.borders)..removeLast(),
      state.value!.borders.last.onDragUpdate(
          details, state.value!.precision, state.value!.currentBorderExtension)
    ]));
  }

  void onBorderDragEnd(DragEndDetails details, PlannerDirection direction) {
    if (!state.value!.editable) return;
    final canUpdate = state.value!
        .canUpdateTable((state.value!.borders.length - 1).toString(), isTable: false);
    final isFirst = state.value!.borders.length == 1;
    state = AsyncData(state.value!.copyWith(
        borders: [
          ...List.from(state.value!.borders)..removeLast(),
          if (canUpdate)
            state.value!.borders.last
                .onDragEnd(details, state.value!.precision),
          if (!canUpdate && isFirst) state.value!.borders.last.resetDrag()
        ],
        currentAction: canUpdate && state.value!.isBorderFinished()
            ? BoardAction.none
            : (!canUpdate && isFirst
                ? BoardAction.chooseExtendBorder
                : BoardAction.chooseBorderType),
        lastBorderExtension: canUpdate
            ? state.value!.currentBorderExtension
            : state.value!.lastBorderExtension));
  }

  void updatePrecision(double value) {
    state = AsyncData(state.value!.copyWith(
        precision: value,
        currentAction: state.value!.precision < 15
            ? BoardAction.initializing
            : state.value!.currentAction));
  }

  void addTable() {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!.copyWith(tables: [
      ...state.value!.tables,
      PlannerTable(
          id: "new",
          left: -4 * state.value!.precision,
          top: -2 * state.value!.precision,
          width: 4 * state.value!.precision,
          height: 2 * state.value!.precision)
    ], currentAction: BoardAction.addTable));
  }

  void stopAddTable() {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!.copyWith(
        tables: state.value!.tables.where((x) => x.id != "new").toList(),
        currentAction: BoardAction.none));
  }

  void updateAddTable(PointerHoverEvent event) {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!.copyWith(tables: [
      for (final table in state.value!.tables)
        if (table.id == "new") table.updateAddTable(event) else table
    ]));
  }

  void placeNewTable() {
    if (!state.value!.editable) return;
    if (!state.value!.canUpdateTable("new", isTable: true)) return;
    state = AsyncData(state.value!.copyWith(tables: [
      for (final table in state.value!.tables)
        if (table.id == "new")
          table.placeNewTable(
              state.value!.precision, state.value!.tables.length.toString())
        else
          table
    ], currentAction: BoardAction.none));
  }

  void placeBorder() {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!.copyWith(borders: [
      PlannerBorder(
          type: PlannerBorderType.wall,
          left: -state.value!.precision,
          top: -state.value!.precision,
          length: state.value!.precision,
          isHorizontal: true)
    ], currentAction: BoardAction.placeBorder));
  }

  void updatePlaceBorder(PointerHoverEvent event) {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!.copyWith(borders: [
      ...List.from(state.value!.borders)..removeLast(),
      state.value!.borders.last.updateAddBorder(event, state.value!.precision)
    ]));
  }

  void placeNewBorder() {
    if (!state.value!.editable) return;
    if (!state.value!.canUpdateTable(
        (state.value!.borders.length - 1).toString(), isTable: false)) return;
    state = AsyncData(state.value!.copyWith(borders: [
      ...List.from(state.value!.borders)..removeLast(),
      state.value!.borders.last
          .onDragEnd(DragEndDetails(), state.value!.precision)
    ], currentAction: BoardAction.chooseExtendBorder));
  }

  void stopAddBorder() {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!
        .copyWith(borders: List.empty(), currentAction: BoardAction.none));
  }

  void chooseNewBorderType(PlannerBorderType type) {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!
        .copyWith(currentAction: BoardAction.chooseExtendBorder, borders: [
      ...List.from(state.value!.borders),
      PlannerBorder(
          left: -state.value!.precision,
          top: -state.value!.precision,
          isHorizontal: true,
          length: state.value!.precision,
          type: type)
    ]));
  }

  void removeLastBorder() {
    if (!state.value!.editable) return;

    state = AsyncData(state.value!.copyWith(borders: List.from(state.value!.borders)..removeLast(),currentAction: BoardAction.chooseBorderType));
  }

  void selectTable(PlannerTable table) {
    state = AsyncData(state.value!.copyWith(
        selectedTable: state.value!.tables.indexOf(table),
        currentAction: BoardAction.tableInfo));
  }

  void deselectTable() {
    if (!state.value!.editable) return;
    state = AsyncData(state.value!
        .copyWith(selectedTable: null, currentAction: BoardAction.none));
  }

  void modifyChairs(PlannerDirection direction, bool subtract) {
    if (!state.value!.editable) return;
    if (subtract
        ? !state.value!.canSubtractChairs(direction)
        : !state.value!.canAddChairs(direction)) return;
    final modifyTable = state.value!.tables[state.value!.selectedTable!];
    state = AsyncData(state.value!.copyWith(tables: [
      for (final table in state.value!.tables)
        if (table == modifyTable)
          table.modifyChairs(direction, state.value!.precision, subtract)
        else
          table
    ]));
  }

  void updateTableID(TextEditingController controller) {
    if (!state.value!.editable) return;
    final modifyTable = state.value!.tables[state.value!.selectedTable!];
    if (modifyTable.id == controller.text) return;
    for (final table in state.value!.tables) {
      if (table != modifyTable && controller.text == table.id) {
        controller.text = modifyTable.id;
        fluttertoastDefault("Wybrany identyfikator jest już zajęty", true);
        return;
      }
    }
    fluttertoastDefault("Poprawnie zmodyfikowano identyfikator");
    state = AsyncData(state.value!.copyWith(tables: [
      for (final table in state.value!.tables)
        if (table == modifyTable) table.copyWith(id: controller.text) else table
    ]));
  }

  Future<void> savePrecision() async {
    if (!state.value!.editable) return;
    final token = ref.read(authProvider);
    try {
      final response = await Dio().post(
          '${dotenv.env['API_URL']!}save-precision',
          data: {"precision": state.value!.precision},
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      state = AsyncData(state.value!.copyWith(currentAction: BoardAction.none));
      fluttertoastDefault(response.data['message']);
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak. Spróbuj ponownie później", true);
      }
    }
  }

  Future<void> saveChanges() async {
    if (!state.value!.editable) return;
    final token = ref.read(authProvider);
    try {
      final response = await Dio().post(
          '${dotenv.env['API_URL']!}save-planner-info',
          data: state.value!.toJson(),
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      fluttertoastDefault(response.data['message']);
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault("Wykryto następujące błędy w konfiguracji restauracji:\n${responseBody['detail'].join("\n")}", true,10);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak. Spróbuj ponownie później", true);
      }
    }
  }

  Future<void> resetBorders() async {
    final token = ref.read(authProvider);
    try {
      final response = await Dio().get('${dotenv.env['API_URL']!}planner-info',
          options:
              Options(headers: {"Authorization": "Bearer ${token.jwtToken}"}));
      state = AsyncData(state.value!.copyWith(
          borders: PlannerTablesBoard.fromJson(response.data).borders));
    } on DioException catch (e) {
      if (e.response != null) {
        Map responseBody = e.response!.data;
        fluttertoastDefault(responseBody['detail'], true);
      } else {
        fluttertoastDefault(
            "Coś poszło nie tak przy wczytywaniu dotychczasowych granic. Spróbuj ponownie później lub odśwież stronę",
            true);
      }
    }
  }

  Future<void> resetChanges() async {
    fluttertoastDefault("okon\nokon<br>okon");
    ref.invalidateSelf();
    await future;
  }
}
