import 'package:flutter/material.dart';

class SelectedDays extends ChangeNotifier {
  late List<bool> selectedElements;

  int _selectedCount = 1;
  SelectedDays(int n) {
    selectedElements = List.generate(n, (index) {
      if (index == DateTime.now().weekday - 1)
        return true;
      else {
        return false;
      }
    });
  }

  List<int> selected() {
    List<int> returnList = [];
    for (int i = 0; i < selectedElements.length; i++) {
      if (selectedElements[i]) {
        returnList.add(i + 1);
      }
    }

    return returnList;
  }

  void toggle(int index) {
    if (_selectedCount > 1) {
      if (selectedElements[index]) {
        _selectedCount--;
      } else {
        _selectedCount++;
      }
      selectedElements[index] = !selectedElements[index];
      notifyListeners();
    } else if (_selectedCount == 1) {
      if (!selectedElements[index]) {
        _selectedCount++;
        selectedElements[index] = true;
        notifyListeners();
      }
    }
  }
}

class SelectedMonths extends ChangeNotifier {
  late List<bool> selectedElements;

  int _selectedCount = 1;
  SelectedMonths(int n) {
    selectedElements = List.generate(n, (index) {
      if (index == DateTime.now().day - 1)
        return true;
      else {
        return false;
      }
    });
  }

  List<int> selected() {
    List<int> returnList = [];
    for (int i = 0; i < selectedElements.length; i++) {
      if (selectedElements[i]) {
        returnList.add(i + 1);
      }
    }

    return returnList;
  }

  void toggle(int index) {
    if (_selectedCount > 1) {
      if (selectedElements[index]) {
        _selectedCount--;
      } else {
        _selectedCount++;
      }
      selectedElements[index] = !selectedElements[index];
      notifyListeners();
    } else if (_selectedCount == 1) {
      if (!selectedElements[index]) {
        _selectedCount++;
        selectedElements[index] = true;
        notifyListeners();
      }
    }
  }
}
