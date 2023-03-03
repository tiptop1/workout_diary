import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import '../model/app_state.dart';
import '../model/entity.dart';

enum ListItemAction { modify, delete }

/// Abstract widget to provide list of items
abstract class ListWidget<E extends Entity> extends StatelessWidget {
  static const double itemExtent = 60.0;

  const ListWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreConnector<AppState, List<E>>(
      converter: storeConnectorConverter,
      builder: listBuilder,
      distinct: true,
    );
  }

  List<E> storeConnectorConverter(Store<AppState> store);

  Widget listItemTitle(BuildContext context, E entity);

  void listItemModifyAction(BuildContext context, E entity);

  void listItemDeleteAction(BuildContext context, E entity);

  void listItemShowAction(BuildContext context, E entity);

  Widget listBuilder(BuildContext context, List<E> entities) {
    return Scrollbar(
      child: ListView.builder(
        itemExtent: itemExtent,
        padding: const EdgeInsets.all(8),
        itemCount: entities.length,
        itemBuilder: (context, index) =>
            listItemBuilder(context, entities[index]),
      ),
    );
  }

  Widget listItemBuilder(BuildContext context, E entity) {
    return Card(
      child: ListTile(
        title: listItemTitle(context, entity),
        trailing: listItemPopup(context, entity),
        onTap: () => listItemShowAction(context, entity),
      ),
    );
  }

  PopupMenuButton<ListItemAction> listItemPopup(
      BuildContext context, E entity) {
    var appLocalizations = AppLocalizations.of(context)!;
    return PopupMenuButton<ListItemAction>(
      icon: const Icon(Icons.menu_rounded),
      onSelected: (ListItemAction result) {
        if (result == ListItemAction.modify) {
          listItemModifyAction(context, entity);
        } else if (result == ListItemAction.delete) {
          listItemDeleteAction(context, entity);
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<ListItemAction>>[
        PopupMenuItem<ListItemAction>(
          value: ListItemAction.modify,
          child: Text(appLocalizations.modify),
        ),
        PopupMenuItem<ListItemAction>(
          value: ListItemAction.delete,
          child: Text(appLocalizations.delete),
        ),
      ],
    );
  }
}
