import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  authenticate();

  // readDocument();

  runApp(const SpacedItemsList());
}

void authenticate() async {
  FirebaseAuth auth = FirebaseAuth.instance;

  // TODO: do not commit the password.
  try {

    UserCredential userCredential = await auth.signInWithEmailAndPassword(
      email: "mathieu.delehaye@gmail.com",
      password: "7WMWZyCq5zNxVD3"
    );

    final User? user = userCredential.user;

    if (user != null) {
      // User signed in successfully
      print("User signed in: ${user.uid}");

    } else {
      print('Sign in failed. Please check your credentials.');
    }
  } on FirebaseAuthException catch (e) {
    if (e.code == 'user-not-found') {
      print('No user found for that email.');
    } else if (e.code == 'wrong-password') {
      print('Wrong password provided for that user.');
    } else {
      print(e.message);
    }
  }
}

class SpacedItemsList extends StatelessWidget {
  const SpacedItemsList({super.key});

  @override
  Widget build(BuildContext context) {
    const items = 10;

    // readDocument();

    return MaterialApp(
      title: 'Firestore Listview',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        cardTheme: CardTheme(color: Colors.blue.shade50),
        useMaterial3: true,
      ),
      home: Scaffold(
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('accommodations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const LinearProgressIndicator();

        return _buildList(context, snapshot.data!.docs);
      },
    );
  }

  Widget _buildList(BuildContext context, List<QueryDocumentSnapshot<Object?>> snapshot) {
    return ListView(
      padding: const EdgeInsets.only(top: 20.0),
      children: snapshot.map((data) => _buildListItem(data)).toList(),
    );
  }

  Widget _buildListItem(QueryDocumentSnapshot<Object?> snapshot) {
    final record = Record.fromSnapshot(snapshot);
    // print('_buildListItem: record=${record.toString()}');

    return Padding(
      key: ValueKey(record.pointName),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: ListTile(
          title: Text(record.pointName),
          trailing: Text(record.address + record.postcode + record.city),
          onTap: () => print(record),
        ),
      ),
    );
    // return Text("Work in progress");
  }
}

class Record {
  final String pointName;
  final String address;
  final String postcode;
  final String city;
  final QueryDocumentSnapshot<Object?> reference;
  final String id;

  Record.fromMap(Map<String, dynamic> map, QueryDocumentSnapshot<Object?> ref)
    : assert(map['PointName'] != null),
      assert(map['Address'] != null),
      assert(map['Postcode'] != null),
      assert(map['City'] != null),
      pointName = map['PointName'],
      address = map['Address'],
      postcode = map['Postcode'],
      city = map['City'],
      reference = ref,
      id = ref.id;

  Record.fromSnapshot(QueryDocumentSnapshot<Object?> snapshot)
    : this.fromMap(snapshot.data() as Map<String, dynamic>, snapshot);

  @override
  String toString() {
    String output = '\n';
    output += 'document id: ${id}\n';
    output += 'document pointName: ${pointName}\n';
    output += 'document address: ${address}\n';
    output += 'document postcode: ${postcode}\n';
    output += 'document city: ${city}\n';
    
    return output;
  }
}
