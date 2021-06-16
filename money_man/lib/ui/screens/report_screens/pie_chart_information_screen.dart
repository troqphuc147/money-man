import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:money_man/core/models/super_icon_model.dart';
import 'package:money_man/core/models/transaction_model.dart';
import 'package:money_man/core/models/category_model.dart';
import 'package:money_man/core/models/wallet_model.dart';
import 'package:money_man/core/services/firebase_firestore_services.dart';
import 'package:money_man/ui/screens/report_screens/report_list_transaction_in_time.dart';
import 'package:money_man/ui/style.dart';
import 'package:money_man/ui/widgets/money_symbol_formatter.dart';
import 'package:provider/provider.dart';

class PieChartInformationScreen extends StatefulWidget {
  List<MyTransaction> currentList;
  List<MyCategory> categoryList;
  final Wallet currentWallet;
  Color color;
  PieChartInformationScreen(
      {Key key,
      @required this.currentList,
      @required this.categoryList,
      @required this.color,
      this.currentWallet})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _PieChartInformationScreen();
}

class _PieChartInformationScreen extends State<PieChartInformationScreen> {
  double _total;
  int touchedIndex = -1;
  List<MyTransaction> _transactionList;
  List<List<MyTransaction>> _listTransactionOfEachCatecory = [];
  List<MyCategory> _categoryList;
  List<double> _info = [];
  Color _color;
  double _height;
  List<MyCategory> _listCategoryReport = [];

  final double fontSizeText = 30;

  // Cái này để check xem element đầu tiên trong ListView chạm đỉnh chưa.
  int reachTop = 0;
  int reachAppBar = 0;

  // Phần này để check xem mình đã Scroll tới đâu trong ListView
  ScrollController _controller = ScrollController();

  _scrollListener() {
    if (_controller.offset > 0) {
      setState(() {
        reachAppBar = 1;
      });
    } else {
      setState(() {
        reachAppBar = 0;
      });
    }
    if (_controller.offset >= fontSizeText - 5) {
      setState(() {
        reachTop = 1;
      });
    } else {
      setState(() {
        reachTop = 0;
      });
    }
  }

  // Phần này để check xem mình đã Scroll tới đâu trong ListView
  bool isContained(MyCategory currentCategory, List<MyCategory> categoryList) {
    if (categoryList.isEmpty) return false;
    int n = 0;
    categoryList.forEach((element) {
      if (element.name == currentCategory.name) n += 1;
    });
    if (n == 1) return true;
    return false;
  }

  void generateData(List<MyCategory> categoryList,
      List<MyTransaction> transactionList) {
    categoryList.forEach((element) {
      if (!isContained(element, _listCategoryReport)) {
        _listCategoryReport.add(element);
      }
    });
    _listCategoryReport.forEach((element) {
      _info.add(calculateByCategory(element, transactionList));
    });
  }

  int b = 0;

  double calculateByCategory(MyCategory category,
      List<MyTransaction> transactionList) {
    double sum = 0;
    DateTime _endDate;
    transactionList.forEach((element) {
      if (element.category.name == category.name) {
        sum += element.amount;
      }
    });
    final b = transactionList
        .where((element) => element.category.name == category.name);
    _listTransactionOfEachCatecory.add(b.toList());
    _listTransactionOfEachCatecory[_listTransactionOfEachCatecory.length - 1]
        .sort((a, b) => b.date.compareTo(a.date));
    return sum;
  }

  @override
  void initState() {
    _transactionList = widget.currentList;
    _transactionList.sort((a, b) => b.date.compareTo(a.date));
    _categoryList = widget.categoryList;
    _color = widget.color;
    generateData(_categoryList, _transactionList);
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    super.initState();
    _height = _listCategoryReport.length.toDouble() * 65;
  }

  @override
  void didUpdateWidget(covariant PieChartInformationScreen oldWidget) {
    _transactionList = widget.currentList ?? [];
    _transactionList.sort((a, b) => b.date.compareTo(a.date));
    _categoryList = widget.categoryList ?? [];
    _color = widget.color;
    _controller = ScrollController();
    _controller.addListener(_scrollListener);
    _listTransactionOfEachCatecory = [];
    _info = [];
    _listCategoryReport = [];
    generateData(_categoryList, _transactionList);
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final _firestore = Provider.of<FirebaseFireStoreService>(context);
    return StreamBuilder<Object>(
        stream: _firestore.transactionStream(widget.currentWallet, 50),
        builder: (context, snapshot) {
          return Container(
              decoration: BoxDecoration(
                  color: boxBackgroundColor,
                  border: Border(
                      bottom: BorderSide(
                        color: foregroundColor.withOpacity(0.12),
                        width: 1,
                      )
                  )
              ),
              padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5),
              child: _listCategoryReport.length > 0 ? Column(
                children: List.generate(
                    _listCategoryReport.length,
                        (index) =>
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ReportListTransaction(
                                          endDate: _listTransactionOfEachCatecory[index]
                                          [0]
                                              .date,
                                          beginDate: _listTransactionOfEachCatecory[
                                          index][
                                          _listTransactionOfEachCatecory[index]
                                              .length -
                                              1]
                                              .date,
                                          totalMoney:
                                          _listTransactionOfEachCatecory[index][0]
                                              .category
                                              .type ==
                                              'expense'
                                              ? -_info[index]
                                              : _info[index],
                                          currentWallet: widget.currentWallet,
                                        )));
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                SuperIcon(
                                  iconPath: _listCategoryReport[index].iconID,
                                  size: 30,
                                ),
                                SizedBox(width: 15,),
                                Expanded(
                                  child: Text(_listCategoryReport[index].name,
                                      style: TextStyle(
                                        fontFamily: fontFamily,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15.0,
                                        color: foregroundColor,
                                      )
                                  ),
                                ),
                                Column(
                                  children: <Widget>[
                                    MoneySymbolFormatter(
                                        text: _info[index],
                                        currencyId: widget.currentWallet
                                            .currencyID,
                                        textStyle: TextStyle(
                                            fontFamily: fontFamily,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 15.0,
                                            color: _color)
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        )
                ),
              ) : Container(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  alignment: Alignment.center,
                  child: Text(
                    'No transaction',
                    style: TextStyle(
                      fontFamily: fontFamily,
                      fontSize: 15.0,
                      fontWeight: FontWeight.w500,
                      color: foregroundColor.withOpacity(0.24),
                    ),
                  )
              )
          );
        });
  }
}
