import 'package:flutter/widgets.dart';

class SearchWidget extends StatefulWidget {
  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  bool isSearchFieldVisible = false;

  void showSearchField() {
    setState(() {
      isSearchFieldVisible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomIconButton(
          onPressed: showSearchField,
          icon: SvgPicture.asset(
            'assets/search.svg',
            fit: BoxFit.none,
            color: Theme.of(context).iconTheme.color,
          ),
          borderColor: Theme.of(context).dividerColor,
        ),
        if (isSearchFieldVisible)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: TextField(
              decoration: InputDecoration(hintText: 'Search...'),
              // Additional search field setup
            ),
          ),
      ],
    );
  }
}
