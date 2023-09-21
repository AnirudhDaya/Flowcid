import 'package:flowcid/dbhelper/mongodb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flowcid/widgets/workflow_features.dart';
import 'package:flowcid/models/MongoDBModel.dart';

class WorkflowNames {
  final String name;
  final List<WorkflowCard> cards;
  WorkflowNames(this.name, this.cards);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController = PageController();
  List<WorkflowNames> workflows = [];
  int _selectedIndex = 0;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Color hexToColor(String code) {
    return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
  }

  @override
  
  void initState() {
    super.initState();
    _loadWorkflows(); // Load workflows from the database when the screen initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey, // Add the key to the Scaffold
      appBar: AppBar(
        title: SvgPicture.asset(
          'assets/flowcid (1).svg',
          alignment: Alignment.centerLeft,
          height: 50,
        ),
        backgroundColor: Colors.grey[850],
      ),
      backgroundColor: Colors.grey[900],
      drawer: Drawer(
        backgroundColor: Colors.grey[850],
        child: LayoutBuilder(
          builder: (context, constraints) {
            double drawerWidth = constraints.maxWidth;
            return Column(
              children: [
                const SizedBox(height: 25),
                Container(
                  width: drawerWidth,
                  child: ElevatedButton(
                    onPressed: () {
                      _showCreateWorkflowDialog(context);
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(Colors.grey[850]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.yellow,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Create new workflow',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                // Display workflows in the drawer
                Expanded(
                  child: ListView(
                    children: List.generate(workflows.length, (index) {
                      return _buildWorkflowTile(workflows[index], index);
                    }),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkflowTile(WorkflowNames workflow, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        _scaffoldKey.currentState!.openEndDrawer(); // Close the drawer
        // print(workflow.name);
        // print(workflow.cards[0].title);
        _navigateToWorkflowPage(Workflow(name: workflow.name, playButtonStatus: false, cards: workflow.cards)); 
        // Move the following line to where you actually have a PageView to control
        // pageController.jumpToPage(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: _selectedIndex == index
              ? hexToColor('#04d2fa')
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              width: 5,
              color: _selectedIndex == index
                  ? Colors.black
                  : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          workflow.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedIndex == index
                ? Colors.black
                : hexToColor('#04d2fa'),
          ),
        ),
      ),
    );
  }

  void _showCreateWorkflowDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newWorkflowName = '';

        return AlertDialog(
          title: const Text('Create New WorkflowNames',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[800],
          content: TextField(
            onChanged: (value) {
              newWorkflowName = value;
            },
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Enter workflow name',
              hintStyle: TextStyle(color: Colors.white70),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (newWorkflowName.isNotEmpty) {
                  setState(() {
                    workflows.add(WorkflowNames(newWorkflowName,[]));
                  });
                  Navigator.pop(context); // Close the dialog
                  _navigateToWorkflowPage(Workflow(name: newWorkflowName, playButtonStatus: false, cards: [])); 
                }
              },
              child:
                  const Text('Create', style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _navigateToWorkflowPage(Workflow workflowName) {
    // Use Navigator to push a new route (page) for the workflow
    // print(workflowName.cards[0].title);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkflowPage(
          workflow: workflowName,  // Pass the workflow name to the next page
        ),
      ),
    );
  }

  Future<void> _loadWorkflows() async {
    // Replace 'userId' with the actual user ID for your app
    String userId = "ron";
    MongoDBModel? data = await MongoDatabase.fetchDataFromDatabase(userId);
    setState(() {
    for (var workflow in data!.workflows) {
      workflows.add(WorkflowNames(workflow.name,workflow.cards));
    }
    });
    
  }
}
