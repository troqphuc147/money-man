import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:money_man/core/models/recurring_transaction_model.dart';
import 'package:money_man/core/models/super_icon_model.dart';
import 'package:money_man/core/models/wallet_model.dart';
import 'package:money_man/core/services/firebase_authentication_services.dart';
import 'package:money_man/core/services/firebase_firestore_services.dart';
import 'package:money_man/ui/screens/planning_screens/recurring_transaction_screens/add_recurring_transaction_sceen.dart';
import 'package:money_man/ui/screens/planning_screens/recurring_transaction_screens/recurring_transaction_detail_screen.dart';
import 'package:money_man/ui/screens/shared_screens/loading_screen.dart';
import 'package:money_man/ui/screens/wallet_selection_screens/wallet_selection.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class RecurringTransactionMainScreen extends StatefulWidget {
  Wallet wallet;
  RecurringTransactionMainScreen({
    Key key,
    @required this.wallet,
  }) : super(key: key);

  @override
  _RecurringTransactionMainScreenState createState() =>
      _RecurringTransactionMainScreenState();
}

class _RecurringTransactionMainScreenState
    extends State<RecurringTransactionMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.grey[900].withOpacity(0.2),
          elevation: 0.0,
          leading: Hero(
            // hong hiu ??
            tag: 'billToDetail_backBtn',
            child: MaterialButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Icon(
                  Icons.arrow_back_outlined,
                  color: Colors.white,
                )),
          ),
          title: Hero(
            tag: 'billToDetail_title',
            child: Text('Recurring transactions',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 17.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
          ),
          flexibleSpace: ClipRect(
            child: AnimatedOpacity(
              opacity: 1,
              duration: Duration(milliseconds: 0),
              child: BackdropFilter(
                filter: ImageFilter.blur(
                    sigmaX: 500, sigmaY: 500, tileMode: TileMode.values[0]),
                child: AnimatedContainer(
                    duration: Duration(milliseconds: 1),
                    //child: Container(
                    //color: Colors.transparent,
                    color: Colors.transparent
                    //),
                    ),
              ),
            ),
          ),
          actions: [
            Hero(
              tag: 'billToDetail_actionBtn',
              child: TextButton(
                onPressed: () async {
                  showCupertinoModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return AddRecurringTransactionScreen(
                            defaultWallet: widget.wallet);
                      });
                },
                child: Text('Add',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    )),
              ),
            ),
            GestureDetector(
              onTap: () async {
                buildShowDialog(context, widget.wallet.id);
              },
              child: Container(
                child: Row(
                  children: [
                    SuperIcon(
                      iconPath: widget.wallet.iconID,
                      size: 25.0,
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey)
                  ],
                ),
              ),
            ),
          ],
        ),
        body: ListView(
          physics:
              BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          children: [
            // buildOverallInfo(
            //     overdue: '\$ 1,000',
            //     forToday: '\$ 1,000',
            //     thisPeriod: '\$ 1,000'),
            // SizedBox(height: 20.0),
            buildListRecurringTransactionList(context),
          ],
        ));
  }

  Widget buildListRecurringTransactionList(context) {
    final _firestore = Provider.of<FirebaseFireStoreService>(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
          child: Text('THIS PERIOD',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              )),
        ),
        StreamBuilder<List<RecurringTransaction>>(
            stream: _firestore.recurringTransactionStream(widget.wallet.id),
            builder: (context, snapshot) {
              List<RecurringTransaction> reTransList = snapshot.data ?? [];
              if (reTransList.length == 0) return Container();
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: reTransList.length,
                  itemBuilder: (context, index) =>
                      buildRecurringTransactionCard(reTransList[index]));
            }),
      ],
    );
  }

  Widget buildRecurringTransactionCard(RecurringTransaction reTrans) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            PageTransition(
                childCurrent: widget,
                child: RecurringTransactionDetailScreen(
                  recurringTransaction: reTrans,
                  wallet: widget.wallet,
                ),
                type: PageTransitionType.rightToLeft));
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(20, 14, 20, 8),
        decoration: BoxDecoration(
            color: Color(0xFF1c1c1c),
            border: Border(
                top: BorderSide(
                  color: Colors.white12,
                  width: 0.5,
                ),
                bottom: BorderSide(
                  color: Colors.white12,
                  width: 0.5,
                ))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SuperIcon(
              iconPath: reTrans.category.iconID,
              size: 38.0,
            ),
            SizedBox(width: 20.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reTrans.category.name,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                SizedBox(height: 20.0),
                Text('Next occurence:',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    )),
                Text('Wednesday, 02/06/2021')
              ],
            ),
            // chỗ này chưa biết xử lý sao
            SizedBox(
              width: 80,
            ),
            Text(reTrans.amount.toString())
          ],
        ),
      ),
    );
  }

  Widget buildOverallInfo(
      {String overdue, String forToday, String thisPeriod}) {
    return Container(
        padding: EdgeInsets.all(20.0),
        decoration: BoxDecoration(
            color: Color(0xFF1c1c1c),
            border: Border(
                top: BorderSide(
                  color: Colors.white12,
                  width: 0.5,
                ),
                bottom: BorderSide(
                  color: Colors.white12,
                  width: 0.5,
                ))),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Remaining Bills',
                style: TextStyle(
                  fontFamily: 'Montserrat',
                  fontSize: 14.0,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                )),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Overdue',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    )),
                Text(overdue,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ))
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('For today',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    )),
                Text(forToday,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ))
              ],
            ),
            SizedBox(height: 10.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('This period',
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white38,
                    )),
                Text(thisPeriod,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 16.0,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ))
              ],
            )
          ],
        ));
  }

  void buildShowDialog(BuildContext context, String id) async {
    final _auth = Provider.of<FirebaseAuthService>(context, listen: false);
    final _firestore =
        Provider.of<FirebaseFireStoreService>(context, listen: false);

    final result = await showCupertinoModalBottomSheet(
        isDismissible: true,
        backgroundColor: Colors.grey[900],
        context: context,
        builder: (context) {
          return Provider(
              create: (_) {
                return FirebaseFireStoreService(uid: _auth.currentUser.uid);
              },
              child: WalletSelectionScreen(
                id: id,
              ));
        });
    final updatedWallet = await _firestore.getWalletByID(result);
    setState(() {
      widget.wallet = updatedWallet;
    });
  }
}