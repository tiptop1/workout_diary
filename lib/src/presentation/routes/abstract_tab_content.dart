import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ListItemAction { modify, delete }

/// Abstract widget to provide list of items
abstract class AbstractTabContent<E> extends StatelessWidget {
  static const double itemExtent = 60.0;
  static const EdgeInsets padding = EdgeInsets.all(8);
  final List<E> entities;

  const AbstractTabContent({super.key, required this.entities});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        child: ListView.builder(
      itemCount: entities.length,
      itemExtent: itemExtent,
      padding: padding,
      itemBuilder: (context, i) => buildListItem(context, entities[i]),
    ));
  }

  Widget listItemTitle(BuildContext context, E entity);

  void listItemShowAction(BuildContext context, E entity);

  void listItemModifyAction(BuildContext context, E entity);

  void listItemDeleteAction(BuildContext context, E entity);

  Widget buildListItem(BuildContext context, E entity) {
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
