

// ignore_for_file: avoid_print

import 'package:flowcid_desktop/dbhelper/constant.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:flowcid_desktop/models/MongoDBModel.dart';

class MongoDatabase {
  // ignore: prefer_typing_uninitialized_variables
  static var db, userCollection;
  static connect() async {
     try {
      db = await Db.create(MONGO_CONN_URL);
      await db.open();
      userCollection = db.collection(USER_COLLECTION);
      print('Connected to MongoDB successfully'); 
    } catch (e) {
      print('Error connecting to MongoDB: $e');
    }
    
  }

  static Future<String> insert(MongoDBModel data) async {
      try{
            var result = await userCollection.insertOne(data.toJson());
            if(result.isSuccess) {
              return "Data inserted";
            }
            else {
              return "Data insertion error";
            }
      }
      catch(e)
      {
          print(e.toString());
          return e.toString();
      }
  }

  static Future<MongoDBModel?> fetchDataFromDatabase(String userId) async {
    try {
      final data = await userCollection.findOne(where.eq('userId', userId));
      return data != null ? MongoDBModel.fromJson(data) : null;
    } catch (e) {
      print('Error fetching data: $e');
      return null;
    }
  }

  static Future<Workflow?> fetchWorkflowByName(String workflowName, String userId) async {
    try {
      final result = await userCollection.findOne(
        where.match('userId', userId).eq('workflows.name', workflowName),
      );
      // print(result);
      if (result != null) {
        final data = MongoDBModel.fromJson(result);
        for (var workflow in data.workflows) {
          if (workflow.name == workflowName) {
            return workflow;
          }
        }
      }

      return null; // Workflow not found
    } catch (e) {
      print('Error fetching workflow by name: $e');
      return null;
    }
  }

  static Future<String> updateWorkflow(Workflow updatedWorkflow, String userId) async {
    try {
      final userCollection = db.collection(USER_COLLECTION);

      // Find the user document
      final userDoc = await userCollection.findOne(where.eq('userId', userId));

      if (userDoc == null) {
        return 'User not found';
      }

      // Find the workflow to update by name
      final List<dynamic> workflows = userDoc['workflows'];
      final int index = workflows.indexWhere((w) => w['name'] == updatedWorkflow.name);

      if (index == -1) {
        return 'Workflow not found';
      }

      // Update the cards in the workflow
      workflows[index]['playButtonStatus'] = updatedWorkflow.playButtonStatus;
      workflows[index]['cards'] = updatedWorkflow.cards.map((card) => card.toJson()).toList();

      // Update the document in the database
      await userCollection.update(
        where.eq('_id', userDoc['_id']), // Use the document's ObjectId
        userDoc, // The updated user document
      );

      return 'Workflow updated successfully';
    } catch (e) {
      print('Error updating workflow: $e');
      return 'Error updating workflow';
    }
  }

}