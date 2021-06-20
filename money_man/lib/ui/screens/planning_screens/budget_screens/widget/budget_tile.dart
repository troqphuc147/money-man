import 'package:flutter/material.dart';
import 'package:money_formatter/money_formatter.dart';
import 'package:money_man/core/models/budget_model.dart';
import 'package:money_man/core/models/super_icon_model.dart';
import 'package:money_man/core/models/wallet_model.dart';
import 'package:money_man/core/services/constaints.dart';
import 'package:money_man/core/services/firebase_firestore_services.dart';
import 'package:money_man/ui/style.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../budget_detail.dart';

class MyBudgetTile extends StatelessWidget {
  const MyBudgetTile({Key key, this.budget, this.wallet}) : super(key: key);
  final Budget budget;
  final Wallet wallet;

  @override
  Widget build(BuildContext context) {
    DateTime today = DateTime.now();
    var todayRate = today.difference(budget.beginDate).inDays /
        budget.endDate.difference(budget.beginDate).inDays;
    var todayTarget = budget.spent / budget.amount;
    final _firestore = Provider.of<FirebaseFireStoreService>(context);
    _firestore.updateBudget(budget, wallet);
    if (budget.isRepeat && budget.endDate.isBefore(today)) {
      Budget newBudget = new Budget(
          id: 'id',
          category: budget.category,
          amount: budget.amount,
          spent: budget.spent,
          walletId: budget.walletId,
          isFinished: budget.isFinished,
          beginDate: budget.endDate.add(Duration(days: 1)),
          endDate:
              budget.endDate.add(budget.endDate.difference(budget.beginDate)),
          isRepeat: budget.isRepeat);
      _firestore.addBudget(newBudget, wallet);
    }
    budget.label = getBudgetLabel(budget);

    return Center(
      child: GestureDetector(
        onTap: () async {
          Wallet wallet = await _firestore.getWalletByID(budget.walletId);
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => BudgetDetailScreen(
                      budget: this.budget,
                      wallet: wallet,
                    )),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Color(0xff222222),
          ),
          width: MediaQuery.of(context).size.width,
          //height: 140,
          margin: EdgeInsets.only(bottom: 15),
          padding: EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                        left: 15, bottom: 15, top: 10, right: 15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Text(
                            budget.label == null
                                ? 'Custom '
                                : '${budget.label} ',
                            style: TextStyle(
                                color: Style.foregroundColor.withOpacity(0.7),
                                fontSize: 14,
                                fontFamily: Style.fontFamily,
                                fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Container(
                          child: Text(
                            budget.label != 'Custom'
                                ? ''
                                : '${DateFormat('dd/MM/yyyy').format(budget.beginDate) + ' - ' + DateFormat('dd/MM/yyyy').format(budget.endDate)}',
                            style: TextStyle(
                                color: Style.foregroundColor.withOpacity(0.54),
                                fontFamily: Style.fontFamily,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                                padding: EdgeInsets.fromLTRB(15, 0, 15, 5),
                                child: SuperIcon(
                                  iconPath: this.budget.category.iconID,
                                  size: 30,
                                )),
                            Container(
                              child: Text(
                                this.budget.category.name,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: Style.fontFamily,
                                ),
                              ),
                            ), //Title cho khoản chi thu đã chọn
                          ],
                        ),
                        Container(
                          padding: EdgeInsets.fromLTRB(0, 0, 15, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                MoneyFormatter(amount: this.budget.amount)
                                    .output
                                    .withoutFractionDigits,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: Style.fontFamily,
                                ),
                              ), // Target
                              Text(
                                todayTarget > 1
                                    ? 'Over spent: ' +
                                        MoneyFormatter(
                                                amount: this.budget.spent -
                                                    this.budget.amount)
                                            .output
                                            .withoutFractionDigits
                                    : 'Remain: ' +
                                        MoneyFormatter(
                                                amount: this.budget.amount -
                                                    this.budget.spent)
                                            .output
                                            .withoutFractionDigits,
                                style: TextStyle(
                                    color: Colors.white54,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: Style.fontFamily,
                                ),
                              ), // Remain
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.fromLTRB(60, 8, 15, 0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    backgroundColor: Color(0xff161616),
                    valueColor: AlwaysStoppedAnimation<Color>(todayTarget > 1
                        ? Colors.red[700]
                        : todayTarget > todayRate
                            ? Colors.orange[700]
                            : Color(0xFF2FB49C)),
                    minHeight: 3,
                    value: this.budget.spent / this.budget.amount > 1
                        ? 1
                        : this.budget.spent / this.budget.amount,
                  ),
                ),
              ),
              SizedBox(
                height: 5,
              ),
              budget.beginDate.isAfter(today) || today.isAfter(budget.endDate)
                  ? Container()
                  : Container(
                      margin: EdgeInsets.only(
                          left: 65 +
                              (MediaQuery.of(context).size.width - 105) *
                                  todayRate),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      // height: 20,
                      // width: 40,
                      //alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Color(0xff171717)),
                      child: Text(
                        "Today",
                        style: TextStyle(
                            color: Colors.white, fontSize: 10,
                            fontFamily: Style.fontFamily,
                            fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  String getBudgetLabel(Budget budget) {
    DateTime today = DateTime.now();
    DateTime begin = budget.beginDate;
    DateTime end = budget.endDate;
    if (end.weekday == 7 &&
        begin.weekday == 1 &&
        begin.isBefore(today.add(Duration(days: 1))) &&
        end.isAfter(today.subtract(Duration(days: 1)))) return 'This week';
    if (begin.day == 1 &&
        end.day ==
            DateTime(begin.year, begin.month + 1, 1)
                .subtract(Duration(days: 1))
                .day &&
        end.month == today.month &&
        begin.month == end.month &&
        begin.isBefore(today) &&
        end.isAfter(today)) return 'This month';
    var temp = DateTime(today.year, today.month + 1, today.day);
    if (begin.day == 1 &&
        end.day ==
            DateTime(begin.year, begin.month + 1, 1)
                .subtract(Duration(days: 1))
                .day &&
        end.month == temp.month &&
        begin.isBefore(temp) &&
        end.isAfter(temp)) return 'Next month';

    double quarterNumber = (today.month - 1) / 3 + 3;
    DateTime firstDayOfQuarter =
        new DateTime(today.year, quarterNumber.toInt(), 1);
    final endDayOfQuarter =
        new DateTime(today.year, quarterNumber.toInt() + 3, 1)
            .subtract(Duration(days: 1));

    if (begin.compareTo(firstDayOfQuarter) == 0 &&
        end.compareTo(endDayOfQuarter) == 0) return 'This quarter';

    double nextQuarterNumber = (today.month - 1) / 3 + 6;
    DateTime firstDayOfNQuarter =
        new DateTime(today.year, nextQuarterNumber.toInt(), 1);
    final endDayOfNQuarter =
        new DateTime(today.year, nextQuarterNumber.toInt() + 3, 1)
            .subtract(Duration(days: 1));
    if (begin.compareTo(firstDayOfNQuarter) == 0 &&
        end.compareTo(endDayOfNQuarter) == 0) return 'Next quarter';

    if (begin.compareTo(DateTime(today.year, 1, 1)) == 0 &&
        end.compareTo(DateTime(today.year, 12, 31)) == 0) return 'This year';

    if (begin.compareTo(DateTime(today.year + 1, 1, 1)) == 0 &&
        end.compareTo(DateTime(today.year + 1, 12, 31)) == 0)
      return 'Next year';
    return 'Custom';
  }
}
