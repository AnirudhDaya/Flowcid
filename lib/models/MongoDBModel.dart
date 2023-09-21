// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

import 'package:flowcid_desktop/workflow_features.dart';

MongoDBModel welcomeFromJson(String str) => MongoDBModel.fromJson(json.decode(str));

String welcomeToJson(MongoDBModel data) => json.encode(data.toJson());

class MongoDBModel {
    // Object userId;
    String userId;
    List<Workflow> workflows;

    MongoDBModel({
        required this.userId,
        required this.workflows,
    });

    factory MongoDBModel.fromJson(Map<String, dynamic> json) => MongoDBModel(
        userId: json["userId"],
        workflows: List<Workflow>.from(json["workflows"].map((x) => Workflow.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "userId": userId,
        "workflows": List<dynamic>.from(workflows.map((x) => x.toJson())),
    };
}

class Workflow {
    String name;
    bool playButtonStatus;
    List<WorkflowCard> cards; // Change this to WorkflowCard

    Workflow({
        required this.name,
        required this.playButtonStatus,
        required this.cards,
    });

    factory Workflow.fromJson(Map<String, dynamic> json) => Workflow(
        name: json["name"],
        playButtonStatus: json["playButtonStatus"],
        cards: List<WorkflowCard>.from(json["cards"].map((x) => WorkflowCard.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "playButtonStatus": playButtonStatus,
        "cards": List<dynamic>.from(cards.map((x) => x.toJson())),
    };
}

// class Wcard {
//     final String title;
//   final String appPath;
//   final String? url;

//   Wcard({required this.title, required this.appPath, this.url});

//     factory Wcard.fromJson(Map<String, dynamic> json) => Wcard(
//         title: json["title"],
//         appPath: json["appPath"],
//         url: json["url"],
//     );

//     Map<String, dynamic> toJson() => {
//         "title": title,
//         "appPath": appPath,
//         "url": url,
//     };
// }
