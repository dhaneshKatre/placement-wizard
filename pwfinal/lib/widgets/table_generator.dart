import 'package:flutter/material.dart';

class TableGenerator extends StatelessWidget {
  final Map<String, Map<String, int>> fieldMap;
  TableGenerator(this.fieldMap);

  @override
  Widget build(BuildContext context) {
    final textStyle =
        TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
    List<TableRow> rows = List();
    rows.add(TableRow(
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8.0), topRight: Radius.circular(8.0)),
      ),
      children: [
        TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Container(
            height: 20.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Text(
                    'Fields',
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Proj.',
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Interns.',
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Text(
                    'Certif.',
                    style: textStyle,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    ));
    this.fieldMap.forEach((k, t) {
      rows.add(TableRow(
        children: [
          TableCell(
            child: Container(
              height: 25.0,
              margin: EdgeInsets.symmetric(horizontal: 2.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      k,
                      textAlign: TextAlign.center,
                    ),
                    flex: 2,
                  ),
                  Expanded(
                    child: Text(
                      t["projects"].toString(),
                      textAlign: TextAlign.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text(
                      t["internships"].toString(),
                      textAlign: TextAlign.center,
                    ),
                    flex: 1,
                  ),
                  Expanded(
                    child: Text(
                      t["certificates"].toString(),
                      textAlign: TextAlign.center,
                    ),
                    flex: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ));
    });
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
        ),
        child: Table(
          children: rows,
          border: TableBorder(),
        ),
      ),
    );
  }
}
