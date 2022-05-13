import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../domain.dart';
import '../utils.dart';
import 'progress_widget.dart';

enum ListItemAction { modify, delete }

abstract class ListOnTabWidget extends StatefulWidget {
  ListOnTabWidget({Key? key}) : super(key: key);
}

abstract class ListOnTabState<T extends ListOnTabWidget, E extends Entity> extends State<T>
    with NavigatorUtils {
  static const double itemExtent = 60.0;
  List<E>? entities;
  bool entitiesReady = false;

  @override
  Widget build(BuildContext context) {
    if (entities == null) {
      loadEntities(context);
    }

    var widget;
    if (entitiesReady) {
      widget = _buildTabContent(context);
    } else {
      widget = ProgressWidget();
    }
    return widget;
  }

  Widget _buildTabContent(BuildContext context) {
    AppLocalizations appLocalizations = AppLocalizations.of(context)!;
    return ListView.builder(
      itemExtent: itemExtent,
      padding: const EdgeInsets.all(8),
      itemCount: entities!.length,
      itemBuilder: (BuildContext context, int index) {
        E entity = entities![index];
        return Card(
          child: ListTile(
            title: listItemTitle(context, entity),
            leading: listItemLeadingWidget(context, entity),
            // trailing: Icon(Icons.menu_rounded),
            trailing: PopupMenuButton<ListItemAction>(
              icon: Icon(Icons.menu_rounded),
              onSelected: (ListItemAction result) {
                if (result == ListItemAction.modify) {
                  listItemModifyAction(context, entity);
                } else if (result == ListItemAction.delete) {
                  listItemDeleteAction(context, entity);
                }
              },
              itemBuilder: (BuildContext context) =>
                  <PopupMenuEntry<ListItemAction>>[
                PopupMenuItem<ListItemAction>(
                  value: ListItemAction.modify,
                  child: Text(appLocalizations.modify),
                ),
                PopupMenuItem<ListItemAction>(
                  value: ListItemAction.delete,
                  child: Text(appLocalizations.delete),
                ),
              ],
            ),
            onTap: () {
              listItemShowAction(context, entity);
            },
          ),
        );
      },
    );
  }

  void loadEntities(BuildContext context);

  Widget listItemTitle(BuildContext context, E entity);

  Widget? listItemLeadingWidget(BuildContext context, E entity) => null;

  void listItemModifyAction(BuildContext context, E entity);

  void listItemDeleteAction(BuildContext context, E entity);

  void listItemShowAction(BuildContext context, E entity);
}
