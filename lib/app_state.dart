import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();
  factory FFAppState() {
    return _instance;
  }
  FFAppState._internal();
  static void reset() {
    _instance = FFAppState._internal();
  }

  SharedPreferences? _prefs;

  // ⚠️ 변경점: dart:html(웹 전용) → shared_preferences(모바일+웹 공용)
  // 기존 웹에서 쌓인 localStorage 데이터는 자동 이전되지 않으니,
  // 필요하면 마이그레이션 로직을 별도로 추가해야 함(아래 initializePersistedState 참고).
  Future initializePersistedState() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs?.getString('completedCategories');
    if (saved != null && saved.isNotEmpty) {
      _completedCategories = saved.split(',');
    } else {
      _completedCategories = [];
    }
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  int _userLevel = 1;
  int get userLevel => _userLevel;
  set userLevel(int value) {
    _userLevel = value;
  }

  int _totalPoints = 0;
  int get totalPoints => _totalPoints;
  set totalPoints(int value) {
    _totalPoints = value;
  }

  int _streakCount = 0;
  int get streakCount => _streakCount;
  set streakCount(int value) {
    _streakCount = value;
  }

  bool _hanjaEnabled = true;
  bool get hanjaEnabled => _hanjaEnabled;
  set hanjaEnabled(bool value) {
    _hanjaEnabled = value;
  }

  bool _soundEnabled = false;
  bool get soundEnabled => _soundEnabled;
  set soundEnabled(bool value) {
    _soundEnabled = value;
  }

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
  }

  bool _ohangAccordionExpanded = false;
  bool get ohangAccordionExpanded => _ohangAccordionExpanded;
  set ohangAccordionExpanded(bool value) {
    _ohangAccordionExpanded = value;
  }

  bool _eumyangAccordionExpanded = false;
  bool get eumyangAccordionExpanded => _eumyangAccordionExpanded;
  set eumyangAccordionExpanded(bool value) {
    _eumyangAccordionExpanded = value;
  }

  bool _isSearchMode = false;
  bool get isSearchMode => _isSearchMode;
  set isSearchMode(bool value) {
    _isSearchMode = value;
  }

  String _dictionaryFilter = 'All';
  String get dictionaryFilter => _dictionaryFilter;
  set dictionaryFilter(String value) {
    _dictionaryFilter = value;
  }

  List<String> _todayQuestionIds = [];
  List<String> get todayQuestionIds => _todayQuestionIds;
  set todayQuestionIds(List<String> value) {
    _todayQuestionIds = value;
  }

  List<String> _completedCategories = [];
  List<String> get completedCategories => _completedCategories;
  set completedCategories(List<String> value) {
    _completedCategories = value;
  }

  void completeCategory(String category) {
    if (!_completedCategories.contains(category)) {
      _completedCategories = [..._completedCategories, category];
      _prefs?.setString('completedCategories', _completedCategories.join(','));
      notifyListeners();
    }
  }

  void resetProgress() {
    _completedCategories = [];
    _todayQuestionIds = [];
    _prefs?.remove('completedCategories');
    notifyListeners();
  }

  bool isCategoryCompleted(String category) {
    return _completedCategories.contains(category);
  }

  // ⚠️ 핵심 수정: "테스트 모드 전체 잠금 해제"였던 부분을 실제 로직으로 교체.
  //
  // stageOrder: 같은 그룹 안에서 순서대로 정렬된 subCategory 값 리스트
  //   예: ['십성_기초', '십성_일반', '십성_심화', '십성_응용']
  // currentSubCategory: 지금 확인하려는 단계의 subCategory 값
  //
  // 규칙: 첫 번째 단계는 항상 열려있고, 그 다음부터는 "바로 이전 단계가
  // 완료(completedCategories에 포함)"되어야 열림.
  bool isStageUnlocked(List<String> stageOrder, String currentSubCategory) {
    final idx = stageOrder.indexOf(currentSubCategory);
    if (idx <= 0) return true; // 못 찾았거나 첫 단계면 항상 열림
    final previousStage = stageOrder[idx - 1];
    return isCategoryCompleted(previousStage);
  }
}
