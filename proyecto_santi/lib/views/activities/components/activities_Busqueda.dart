import 'package:flutter/material.dart';

class Busqueda extends StatelessWidget {
  final Function(String) onSearchQueryChanged;
  final Function(String?, int?, String?, String?) onFilterSelected;

  Busqueda({required this.onSearchQueryChanged, required this.onFilterSelected});

  @override
  Widget build(BuildContext context) {
    var searchText = '';
    var showPopup = false;

    return Column(
      children: [
        TextField(
          onChanged: (text) {
            searchText = text;
            onSearchQueryChanged(text);
          },
          decoration: InputDecoration(
            labelText: 'Buscar actividad...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () {
                showPopup = !showPopup;
              },
            ),
            filled: true,
            fillColor: Colors.white.withOpacity(0.3),
          ),
        ),
        if (showPopup)
        // Implement filter options popup
          Container(),
      ],
    );
  }
}