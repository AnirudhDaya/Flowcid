import 'package:flowcid_desktop/launch_apps.dart';
import 'package:flutter/material.dart';
import 'workflow_features.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flowcid_desktop/models/MongoDBModel.dart';
import 'package:flowcid_desktop/dbhelper/mongodb.dart';

Workflow w = Workflow(name: "test", playButtonStatus: false, cards: []);

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
   List<String> appPaths = [];
  int _selectedIndex = 0;

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
      appBar: AppBar(
         title: SvgPicture.asset(
          'assets/flowcid (1).svg',
          height:40,
          fit: BoxFit.cover
        ),
        backgroundColor: Colors.grey[850],
        
      ),
      backgroundColor: Colors.grey[900],
      body: Row(
        children: [
          Container(
            width: 250,
            color: Colors.grey[850],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: TextButton(
                    onPressed: () {
                      _showCreateWorkflowDialog(context);
                    },
                    child: Row(
                      children: [
                        Icon(Icons.add, color: hexToColor('#04d2fa'),),
                        const SizedBox(width: 8),
                        const Text('Create new workflow', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
                Divider(color: Colors.grey[700]),
                Expanded(
                  child: ListView.builder(
                    itemCount: workflows.length,
                    itemBuilder: (context, index) {
                      w.name = workflows[index].name;
                      w.cards = workflows[index].cards;
                      return _buildWorkflowTile(workflows[index], index);
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              children: workflows.map((workflow) {
              return WorkflowFeatures(
                appLauncher: AppLauncher(), // Pass the AppLauncher instance
                context: context, 
                appPaths: appPaths, 
                workflow: w,
              );
            }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkflowTile(WorkflowNames workflow, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        pageController.jumpToPage(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: _selectedIndex == index ? hexToColor('#04d2fa') : Colors.transparent,
          border: Border(
            left: BorderSide(
              width: 5,
              color: _selectedIndex == index ? Colors.black : Colors.transparent,
            ),
          ),
        ),
        child: Text(
          workflow.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: _selectedIndex == index ?Colors.black : hexToColor('#04d2fa'),
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
          title: const Text('Create New Workflow',style: TextStyle(color: Colors.white)),
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
                  w.name = newWorkflowName;
                  w.cards = [];
                  Navigator.pop(context); // Close the dialog
                }
              },
              child: const Text('Create',style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
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

// void main() {
//   runApp(const MaterialApp(
//     home: HomeScreen(),
//   ));
// }
