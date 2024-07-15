import 'package:flutter/material.dart';
import 'package:newcall_center/blocs/customer.page.bloc.dart';

class ChangeService extends StatefulWidget {
  final CustomerPageBloc bloc;
  const ChangeService({super.key, required this.bloc});

  @override
  State<ChangeService> createState() => _ChangeServiceState();
}

class _ChangeServiceState extends State<ChangeService> {
  int? selectedServer;
  late CustomerPageBloc bloc;

  List<bool> isHovered = List.filled(7, false);

  @override
  void initState() {
    super.initState();
    bloc = widget.bloc;
  }

  void _updateColor(int index, bool hovered) {
    setState(() {
      if (selectedServer != index) {
        isHovered[index] = hovered;
      }
    });
  }

  String shortenServiceName(String name) {
    List<String> words = name.split(' ');
    if (words.length > 2) {
      return words.sublist(0, 2).join(' ');
    }
    return name;
  }

  Color getTextColor(bool isHovered) {
    return isHovered ? Colors.white : Colors.black;
  }

  Color getContainerColor(bool isHovered) {
    return isHovered ? Colors.blue : Colors.black12;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Object>(
      stream: bloc.service.stream,
      builder: (context, snapshot) {
        return SizedBox(
          height: 38,
          width: bloc.services.length * 109.5,
          child: Center(
            child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is OverscrollNotification && notification.overscroll < 0) {
                  // Disable scrolling in the upward direction
                  return true;
                }
                return false;
              },
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: bloc.services.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: bloc.services.length,
                  mainAxisSpacing: 5,
                  crossAxisSpacing: 5,
                  childAspectRatio: 3.3,
                ),
                itemBuilder: (context, index) => MouseRegion(
                  onHover: (event) => _updateColor(index, true),
                  onExit: (event) => _updateColor(index, false),
                  child: GestureDetector(
                    onTap: () {
                      selectedServer = index;
                      setState(() {
                        _updateColor(index, true);
                      });
                      bloc.changeService(bloc.services[index]);
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: getContainerColor(isHovered[index]),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          shortenServiceName(bloc.services[index].name),
                          style: TextStyle(
                            fontSize: 14.5,
                            color: getTextColor(isHovered[index]),
                          ),
                        ),
                      ),
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
}
