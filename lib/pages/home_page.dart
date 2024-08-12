import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../db/database_helper.dart';
import '../models/bank_transaction_model.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late User user;
  late Future<List<BankTransaction>> transactionsFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    user = ModalRoute.of(context)!.settings.arguments as User;
    transactionsFuture = DatabaseHelper.instance.getUserTransactions(user.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome, ${user.username}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              'Balance: \$${user.balance.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 24, color: Colors.green),
            ),
            SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<List<BankTransaction>>(
                future: transactionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No transactions found.'));
                  } else {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        BankTransaction transaction = snapshot.data![index];
                        return ListTile(
                          leading: Icon(
                            transaction.type == 'Deposit' || transaction.type == 'Transfer In'
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: transaction.type == 'Deposit' || transaction.type == 'Transfer In'
                                ? Colors.green
                                : Colors.red,
                          ),
                          title: Text(transaction.type),
                          subtitle: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _performTransaction('Deposit'),
                  child: Text('Deposit'),
                ),
                ElevatedButton(
                  onPressed: () => _performTransaction('Withdraw'),
                  child: Text('Withdraw'),
                ),
                ElevatedButton(
                  onPressed: _performTransfer,
                  child: Text('Transfer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performTransaction(String type) async {
    TextEditingController _amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('$type Amount'),
          content: TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Enter amount'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                double amount = double.parse(_amountController.text);
                if (type == 'Withdraw' && amount > user.balance) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Insufficient balance')),
                  );
                } else {
                  double newBalance =
                      type == 'Deposit' ? user.balance + amount : user.balance - amount;
                  await DatabaseHelper.instance.updateUserBalance(user.id!, newBalance);
                  await DatabaseHelper.instance.insertTransaction(
                    BankTransaction(
                      userId: user.id!,
                      type: type,
                      amount: amount,
                    ),
                  );

                  setState(() {
                    user.balance = newBalance;
                    transactionsFuture =
                        DatabaseHelper.instance.getUserTransactions(user.id!);
                  });

                  Navigator.of(context).pop();
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performTransfer() async {
  TextEditingController _recipientUsernameController = TextEditingController();
  TextEditingController _amountController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Transfer Money'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _recipientUsernameController,
              decoration: InputDecoration(labelText: 'Enter recipient username'),
            ),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Enter amount'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              String recipientUsername = _recipientUsernameController.text;
              double amount = double.parse(_amountController.text);

              if (amount > user.balance) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Insufficient balance')),
                );
              } else {
                try {
                  await DatabaseHelper.instance.transferMoneyByUsername(
                      user.username, recipientUsername, amount);
                  
                  double newBalance = user.balance - amount;
                  setState(() {
                    user.balance = newBalance;
                    transactionsFuture =
                        DatabaseHelper.instance.getUserTransactions(user.id!);
                  });

                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transfer successful')),
                  );
                } catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Transfer failed: $e')),
                  );
                }
              }
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}

}
