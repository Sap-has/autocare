import 'package:flutter/material.dart';

enum PageIdentifier {vehicleFormPage, vehicleProfilePage, suggestionPage, servicePage}

class NavigationProvider extends ChangeNotifier{
  PageIdentifier _currentPage = PageIdentifier.vehicleProfilePage;

  PageIdentifier get currentPage => _currentPage;

  void setPage(PageIdentifier page) {
    _currentPage = page;
    notifyListeners();
  }
}