import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Barra de búsqueda y filtrado para las vistas CRUD
class CrudSearchBar extends StatefulWidget {
  final String hintText;
  final Function(String) onSearch;
  final VoidCallback? onAdd;
  final String? addButtonText;

  const CrudSearchBar({
    Key? key,
    required this.hintText,
    required this.onSearch,
    this.onAdd,
    this.addButtonText,
  }) : super(key: key);

  @override
  State<CrudSearchBar> createState() => _CrudSearchBarState();
}

class _CrudSearchBarState extends State<CrudSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(kIsWeb ? 12 : 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: TextStyle(color: Colors.grey),
                prefixIcon: Icon(Icons.search, size: kIsWeb ? 18 : 20),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: kIsWeb ? 18 : 20),
                        onPressed: () {
                          _searchController.clear();
                          widget.onSearch('');
                          setState(() {});
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: kIsWeb ? 12 : 16,
                  vertical: kIsWeb ? 10 : 12,
                ),
              ),
              style: TextStyle(fontSize: kIsWeb ? 13 : 14),
              onChanged: (value) {
                widget.onSearch(value);
                setState(() {});
              },
            ),
          ),
          if (widget.onAdd != null) ...[
            SizedBox(width: kIsWeb ? 12 : 16),
            ElevatedButton.icon(
              onPressed: widget.onAdd,
              icon: Icon(Icons.add, size: kIsWeb ? 18 : 20),
              label: Text(
                widget.addButtonText ?? 'Añadir',
                style: TextStyle(fontSize: kIsWeb ? 13 : 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1976d2),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: kIsWeb ? 20 : 24,
                  vertical: kIsWeb ? 12 : 16,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
