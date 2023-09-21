import 'package:flutter/material.dart';
import 'package:flowcid/widgets/launch_apps.dart';
import 'package:flowcid/widgets/settings.dart';
import 'package:flowcid/dbhelper/mongodb.dart'; // Adjust the import path
import 'package:flowcid/models/MongoDBModel.dart';

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

class WorkflowPage extends StatefulWidget {
  final Workflow workflow;
  const WorkflowPage({Key? key, required this.workflow}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WorkflowPageState createState() => _WorkflowPageState();
}

class _WorkflowPageState extends State<WorkflowPage> {
  final List<WorkflowCard> selectedCards = [];

  void addWorkflow(Workflow workflow) {
    setState(() {
      // print(workflow.name);
      for (var card in workflow.cards) {
        // print(card.title);
        addCard(card);
      }      
    });
  }

  void addCard(WorkflowCard card) {
    setState(() {
      selectedCards.add(card);
    });
  }

  @override
void initState() {
  super.initState();
  addWorkflow(widget.workflow); // Call addWorkflow with the provided workflow
}


  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(widget.workflow.name),
      centerTitle: true,
      backgroundColor: Colors.grey[900],
    ),
    backgroundColor: Colors.grey[900],
    body: Stack(
      alignment: Alignment.topCenter,
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: PlayButton(cards: selectedCards,isPressed: false,workflowName: widget.workflow.name),
        ),
        if (selectedCards.isNotEmpty)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.12, // Adjust this value as needed
            left: 4,
            right: 0,
            bottom: 0, // Ensure it takes the full height
            child: SingleChildScrollView(
              child: WorkflowCardGrid(cards: selectedCards),
            ),
          ),
        Positioned(
          bottom: 20, // Adjust this value to control the button's position
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

  void _addCard() {
    selectedCards.insert(0, WorkflowCard(title: 'New Card', appPath: 'None', url: null));
  }

  void _addAppCard(String appName, String appPath) async{
    if (isBrowser(appName)) {
      // Handle browser case...
    } else {

      final existingWorkflow = await MongoDatabase.fetchWorkflowByName(widget.workflow.name,"ron");

      if (existingWorkflow != null) {
    // Workflow exists, so update it with the new card
          WorkflowCard card;
          if(appName != "Setting") {
            card = WorkflowCard(title: appName, appPath: appPath);
          } else {
            card = WorkflowCard(title: appName, appPath: appPath, url: appPath);
          }

          existingWorkflow.cards.add(card);

          // Update the existing workflow in the database
          final result = await MongoDatabase.updateWorkflow(existingWorkflow, "ron");
          // print(result);
          if (result == 'Workflow updated successfully') {
            // Workflow updated successfully, add the card to the local state
            setState(() {  
            addCard(card);
            });
          } else {
            // Handle the case where the update fails
            print('Error updating workflow: $result');
          }
      }
      else
      {
        if(appName != "Setting") {
          final card = WorkflowCard(title: appName, appPath: appPath);
          addCard(card);
          final result = await MongoDatabase.insert(MongoDBModel(
          // userId: M.ObjectId(),// Replace with the actual user ID
          userId: "ron",
          workflows: [
            Workflow(name: widget.workflow.name, playButtonStatus: false, cards: [card]),
          ],
        ));

        // print(result); 
        }
        else {
          final card = WorkflowCard(title: appName, appPath: appPath, url: appPath);
          addCard(card);
          final result = await MongoDatabase.insert(MongoDBModel(
          // userId: M.ObjectId(),// Replace with the actual user ID
          userId: "ron",
          workflows: [
            Workflow(name: widget.workflow.name, playButtonStatus: false, cards: [card]),
          ],
        ));

        // print(result); 
        }
      }
    }
    
  }

  bool isBrowser(String appName) {
    return ['chrome', 'edge', 'firefox', 'brave'].any((browser) => appName.contains(browser));
  }
}

class PlayButton extends StatelessWidget {
  final List<WorkflowCard> cards;
  final bool isPressed;
  final String workflowName;
  const PlayButton({Key? key, required this.cards, required this.isPressed, required this.workflowName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        launch();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: hexToColor('#04d2fa'),
        shape: const CircleBorder(),
        padding: const EdgeInsets.all(14),
        elevation: 8,
      ),
      child: Icon(
        Icons.play_arrow,
        size: 28,
        color: Colors.grey[850],
      ),
    );
  }

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  bool isBrowser(String appName) {
    return ['chrome', 'edge', 'firefox', 'brave'].any((browser) => appName.contains(browser));
  }
  
  Future<void> launch() 
  async {
    final existingWorkflow = await MongoDatabase.fetchWorkflowByName(workflowName,"ron");
    existingWorkflow?.playButtonStatus=true;
    print(existingWorkflow?.name);
    final result = await MongoDatabase.updateWorkflow(existingWorkflow!, "ron");
    
    for (int i = 0; i < cards.length; i++) {
          if(!cards[i].appPath.contains("/"))
          {
            if(cards[i].title != "Setting") {
              if (isBrowser(cards[i].title)) {
                if (cards[i].url != null) {
                  AppLauncher().launchApplication(cards[i].appPath, url: cards[i].url!);
                }
              } else {
                AppLauncher().launchApplication(cards[i].appPath);
              }
            }
            else {
              Settings().toggleSetting(cards[i].appPath);
            }
          }
        }
  }
}

class AddNewCardButton extends StatelessWidget {
  final VoidCallback onAddCard;
  final Function(String, String) onAddAppCard;
  final BuildContext context;

  const AddNewCardButton({
    Key? key,
    required this.onAddCard,
    required this.onAddAppCard,
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
              color: hexToColor('#04d2fa'),
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
                size: 15,
                color: Colors.black,
              ),
            ),
          ),
        )
      ],
    );
  }

  void _showAddOptions(BuildContext context) async {
   await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: IntrinsicHeight(
            child: FractionallySizedBox(
              widthFactor: MediaQuery.of(context).size.width < 600 ? 1 : 0.5,
              child: AlertDialog(
                contentPadding: EdgeInsets.zero,
                backgroundColor: Colors.transparent,
                content: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.grey[800]!,
                        Colors.grey[900]!,
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
                                  onAddAppCard(appInfo['appName']!, appInfo['appPackage']!);
                                }
                              },
                            ),
                            const SizedBox(width: 20),
                            _buildOptionButton(
                              icon: Icons.settings,
                              text: 'Settings',
                              onPressed: () async{
                                Navigator.pop(context);
                                final settingLaunch = Settings();
                                final setting = await settingLaunch.pickAndLaunchApplication(context);
                                if(setting != null ){
                                  onAddAppCard("Setting", setting);
                                } // Perform action for Settings option
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
            size: 40,
            color: Colors.white,
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class WorkflowCardGrid extends StatelessWidget {
  final List<WorkflowCard> cards;

  const WorkflowCardGrid({Key? key, required this.cards}) : super(key: key);

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

  const WorkflowCardTile({Key? key, required this.card}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
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
                Colors.grey[800]!,
                Colors.grey[900]!,
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
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                subtitle: card.url != null
                    ? Text(
                        card.url!,
                        style: const TextStyle(
                          color: Colors.white70,
                        ),
                      )
                    : null,
              ),
              const Align(
                alignment: Alignment.topRight,
                child: SizedBox(
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
