import 'package:flowcid_desktop/dbhelper/mongodb.dart';
import 'package:flowcid_desktop/models/MongoDBModel.dart';
import 'package:flutter/material.dart';
import 'launch_apps.dart';
import 'dart:async';

class WorkflowCard {
  final String title;
  final String appPath;
  final String? url;

  WorkflowCard({required this.title, required this.appPath, this.url}); 

  factory WorkflowCard.fromJson(Map<String, dynamic> json) => WorkflowCard(
        title: json["title"],
        appPath: json["appPath"],
        url: json["url"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "appPath": appPath,
        "url": url,
      };
}

class WorkflowFeatures extends StatefulWidget {
  final AppLauncher appLauncher;
  final BuildContext context;
  final List<String> appPaths; // Add this line
  final Workflow workflow;

  const WorkflowFeatures({
    Key? key,
    required this.appLauncher,
    required this.context,
    required this.appPaths, 
    required this.workflow// Add this line
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WorkflowFeaturesState createState() => _WorkflowFeaturesState();
}

class _WorkflowFeaturesState extends State<WorkflowFeatures> {
  List<WorkflowCard> workflowCards = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900], // Set your desired background color here
      body: Stack(
        children: [
          Column(
            children: [
              PlayButton(cards: workflowCards),
              WorkflowCardGrid(cards: workflowCards),
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: AddNewCardButton(
              onAddCard: _addCard,
              onAddAppCard: _addAppCard,
              context: context,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
  super.initState();
  addWorkflow(widget.workflow); 
  Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      checkForUpdates();
  });// Call addWorkflow with the provided workflow
}

  void addWorkflow(Workflow workflow) {
    setState(() {
      // print(workflow.name);
      for (var card in workflow.cards) {
        // print(card.title);
        addCard(card);
      }      
    });
  }

  void _addCard() {
    setState(() {
      workflowCards.insert(0, WorkflowCard(title: 'New Card', appPath: 'None'));
    });
  }

  void addCard(WorkflowCard card) {
    setState(() {
      workflowCards.add(card);
    });
  }

  void _addAppCard(String appName, String appPath) async{
      appName = appName.replaceAll('.exe', '');
      appName = appName.replaceAll('.EXE', '');
      final existingWorkflow = await MongoDatabase.fetchWorkflowByName(widget.workflow.name,"ron");
      WorkflowCard card = WorkflowCard(title: appName, appPath: appPath);
      if(existingWorkflow != null)  //updation
      {
        if (isBrowser(appName)) 
        {
            card = WorkflowCard(title: appName, appPath: appPath, url: appPath);
        }
        existingWorkflow.cards.add(card);//Update the existing workflow in the database
        final result = await MongoDatabase.updateWorkflow(existingWorkflow, "ron");
          // print(result);
          if (result == 'Workflow updated successfully') {
          // Workflow updated successfully, add the card to the local state
            setState(() {  
            addCard(card);
            });
          } 
          else { // Handle the case where the update fails
            print('Error updating workflow: $result');
          }
      }
      else //insertion
      {
        if (isBrowser(appName)) 
        {
            _showBrowserUrlDialog(appName, appPath);
        }
        else
        { 
          setState(() {     
          workflowCards.insert(0, WorkflowCard(title: appName, appPath: appPath));
          });
          final card = WorkflowCard(title: appName, appPath: appPath);
          addCard(card);
          final result = await MongoDatabase.insert(MongoDBModel(
          // userId: M.ObjectId(),// Replace with the actual user ID
            userId: "ron",
            workflows: [
              Workflow(name: widget.workflow.name, playButtonStatus: false, cards: [card]),
            ],
          ));
          print(result);
        }
      }
      
  }

  void _showBrowserUrlDialog(String appName, String appPath) async {
    TextEditingController urlController = TextEditingController();

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text('Add URL for $appName', style: const TextStyle(color: Colors.white),),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Browser: $appName', style: const TextStyle(color: Colors.white),),
              const SizedBox(height: 10),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(hintText: 'Enter URL', hintStyle: TextStyle(color: Colors.white70)),
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async{
                String url = urlController.text;
                setState(() {
                  workflowCards.insert(0, WorkflowCard(title: appName, appPath: appPath, url: url));
                });
            final result = await MongoDatabase.insert(MongoDBModel(
          // userId: M.ObjectId(),// Replace with the actual user ID
            userId: "ron",
            workflows: [
            Workflow(name: widget.workflow.name, playButtonStatus: false, cards: [WorkflowCard(title: appName, appPath: appPath, url: url)]),
              ],
            ));

        print(result); 
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  bool isBrowser(String appName) {
    if (appName.contains('chrome') || appName.contains('edge') || appName.contains('firefox') ||appName.contains('brave')) {
      return true;
    }
    return false;
  }
  
  void checkForUpdates() async 
  {
    final existingWorkflow = await MongoDatabase.fetchWorkflowByName(widget.workflow.name,"ron");
    if(existingWorkflow?.playButtonStatus == true)
    {
        launcher();
        existingWorkflow?.playButtonStatus=false;
    }
    final result = await MongoDatabase.updateWorkflow(existingWorkflow!, "ron");
    }

  void launcher() 
  {
    for (int i = 0; i < workflowCards.length; i++) {
            if(workflowCards[i].title !=  'Setting' && !workflowCards[i].appPath.startsWith('com.'))
            {
              if (isBrowser(workflowCards[i].title)) {
                if (workflowCards[i].url != null) {
                  AppLauncher().launchApplication(workflowCards[i].appPath, url: workflowCards[i].url!);
                }
              } else {
                AppLauncher().launchApplication(workflowCards[i].appPath);
              }
            }
    }
  }

}

class PlayButton extends StatelessWidget {
  final List<WorkflowCard> cards; // Add this line

  const PlayButton({Key? key, required this.cards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: const EdgeInsets.all(15),
      child: ElevatedButton(
        onPressed: () {
          launch();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: hexToColor('#04d2fa'), // Change the button color as needed
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(24),
          elevation: 8,
        ),
        child: Icon(
          Icons.play_arrow,
          size: 48,
          color: Colors.grey[850], // Change the icon color as needed
        ),
      ),
    );
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  bool isBrowser(String appName) {
    return ['chrome', 'edge', 'firefox','brave'].any((browser) => appName.contains(browser));
  }
  
  void launch() 
  {
    for (int i = 0; i < cards.length; i++) {
            if(cards[i].title !=  'Setting' && !cards[i].appPath.startsWith('com.'))
            {
              if (isBrowser(cards[i].title)) {
                if (cards[i].url != null) {
                  AppLauncher().launchApplication(cards[i].appPath, url: cards[i].url!);
                }
              } else {
                AppLauncher().launchApplication(cards[i].appPath);
              }
            }
    }
  }
}


class WorkflowCardGrid extends StatelessWidget {
  final List<WorkflowCard> cards;

  const WorkflowCardGrid({super.key, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 10,
      runSpacing: 10,
      children: cards.map((card) => WorkflowCardTile(card: card)).toList(),
    );
  }
}

class WorkflowCardTile extends StatelessWidget {
  final WorkflowCard card;

  const WorkflowCardTile({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return Container(
      width: 150, // Change the width as needed
      height: 150, // Change the height as needed
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[800]!, // Dark gradient color (use ! to indicate non-null)
                Colors.grey[900]!, // Dark gradient color (use ! to indicate non-null)
              ],
              stops: const [0.0, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              ListTile(
                title: Text(
                  card.title,
                  style: const TextStyle(
                    color: Colors.white, // Text color
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: card.url != null
                    ? Text(
                        card.url!,
                        style: const TextStyle(
                          color: Colors.white70, // Subtitle text color
                        ),
                      )
                    : null,
                // leading: const Icon(
                //   Icons.person,
                //   color: Colors.grey, // Leading icon color
                // ),
                // trailing: const Icon(
                //   Icons.keyboard_arrow_right,
                //   color: Colors.grey, // Trailing icon color
                // ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 20,
                  height: 20,
                  
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class AddNewCardButton extends StatelessWidget {
  final VoidCallback onAddCard;
  final Function(String, String) onAddAppCard;
  // final List<String> appPaths; // Accept appPaths
  final BuildContext context; // Accept context

  const AddNewCardButton({
    Key? key,
    required this.onAddCard,
    required this.onAddAppCard,
    // required this.appPaths,
    required this.context,
  }) : super(key: key);


  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
        onTap: () {
          _showAddOptions(context);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 20),
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color:  hexToColor('#04d2fa'), // Change the button color as needed
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              size: 30,
              color: Colors.black, // Change the icon color as needed
            ),
          ),
        ),
     )
      ]
      );
    
  }

void _showAddOptions(BuildContext context) async {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Center(
        child: IntrinsicHeight(
          child: FractionallySizedBox(
            widthFactor: 0.5, // Adjust the width factor as needed
            child: AlertDialog(
              contentPadding: EdgeInsets.zero, // Remove padding
              backgroundColor: Colors.transparent,
              content: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.grey[800]!, // Dark gradient color
                      Colors.grey[900]!, // Dark gradient color
                    ],
                    stops: const [0.0, 1.0],
                  ),
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildOptionButton(
                            icon: Icons.apps,
                            text: 'Apps',
                            onPressed: () async {
                              Navigator.pop(context);
                              final appLauncher = AppLauncher();
                              final appInfo = await appLauncher.pickAndLaunchApplication(context);
                              if (appInfo != null) {
                                onAddAppCard(appInfo['appName']!, appInfo['appPath']!);
                              }
                            },
                          ),
                          const SizedBox(width: 20), // Adjust spacing as needed
                          _buildOptionButton(
                            icon: Icons.settings,
                            text: 'Settings',
                            onPressed: () {
                              Navigator.pop(context);
                              // Perform action for Settings option
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}


Widget _buildOptionButton({required IconData icon, required String text, required VoidCallback onPressed}) {
  return TextButton(
    onPressed: onPressed,
    child: Column(
      children: [
        Icon(
          icon,
          size: 60,
          color: Colors.white, // Icon color
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 18,
            color: Colors.white, // Text color
          ),
        ),
      ],
    ),
  );
}
}