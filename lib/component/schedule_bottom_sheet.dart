import 'package:calendar_scheduler/component/custom_text_field.dart';
import 'package:calendar_scheduler/const/color.dart';
import 'package:calendar_scheduler/datebase/drift_database.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../model/category_color.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate;
  final int? scheduleId;

  const ScheduleBottomSheet(
      {required this.selectedDate, this.scheduleId, Key? key})
      : super(key: key);

  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet> {
  final GlobalKey<FormState> formKey = GlobalKey();

  int? startTime;
  int? endTime;
  String? content;
  int? selectedColorId;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: FutureBuilder<Schedule>(
          future: null,
          builder: (context, snapshot) {
            return FutureBuilder<Schedule>(
                future: widget.scheduleId == null
                    ? null
                    : GetIt.I<LocalDatabase>()
                        .getSchedulesById(widget.scheduleId!),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('스케줄을 불러올 수 없습니다.'),
                    );
                  }

                  // FutureBuilder 처음 실행됐고
                  // 로딩중일때
                  if (snapshot.connectionState != ConnectionState.none &&
                      !snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  // Future가 실행이 되고
                  // 값이 있는데 단 한번도 startTime이 세팅되지 않았을때

                  if (snapshot.hasData && startTime == null) {
                    startTime = snapshot.data!.startTime;
                    endTime = snapshot.data!.endTime;
                    content = snapshot.data!.content;
                    selectedColorId = snapshot.data!.colorId;
                  }
                  return SafeArea(
                    child: Container(
                      height:
                          MediaQuery.of(context).size.height / 2 + bottomInset,
                      child: Padding(
                        padding: EdgeInsets.only(bottom: bottomInset),
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 8.0,
                            right: 8.0,
                            top: 16.0,
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _Time(
                                  onStartSaved: (String? val) {
                                    startTime = int.parse(val!);
                                  },
                                  onEndSaved: (String? val) {
                                    endTime = int.parse(val!);
                                  },
                                  startInitialValue:
                                      startTime?.toString() ?? "",
                                  endInitialValue: endTime?.toString() ?? "",
                                ),
                                SizedBox(height: 16.0),
                                _Content(
                                  onSaved: (String? val) {
                                    content = val;
                                  },
                                  initialValue: content ?? "",
                                ),
                                SizedBox(height: 16.0),
                                FutureBuilder<List<CategoryColor>>(
                                    future: GetIt.I<LocalDatabase>()
                                        .getCategoryColors(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          selectedColorId == null &&
                                          snapshot.data!.isNotEmpty) {
                                        selectedColorId = snapshot.data![0].id;
                                      }
                                      return _ColorPicker(
                                        colors: snapshot.hasData
                                            ? snapshot.data!
                                            : [],
                                        selectedColorId: selectedColorId,
                                        colorIdSetter: (int id) {
                                          setState(() {
                                            selectedColorId = id;
                                          });
                                        },
                                      );
                                    }),
                                SizedBox(height: 16.0),
                                _SaveButton(
                                  onPressed: onSavePressed,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }

  void onSavePressed() async {
    // formKey는 생성을 했는데
    // Form 위젯과 결합을 안했을때
    // 다른 개발자의 실수를 대비 예외처리
    if (formKey.currentState == null) {
      return;
    }
    // 모든 하위 TextFormField의 validate에서 null을 return할 때
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();

      // 처음 일정을 생성할때
      if (widget.scheduleId == null) {
        await GetIt.I<LocalDatabase>().createSchedule(
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            colorId: Value(selectedColorId!),
          ),
        );
      }
      // 일정을 수정했을때
      else {
        await GetIt.I<LocalDatabase>().updateScheduleById(
          widget.scheduleId!,
          SchedulesCompanion(
            date: Value(widget.selectedDate),
            startTime: Value(startTime!),
            endTime: Value(endTime!),
            content: Value(content!),
            colorId: Value(selectedColorId!),
          ),
        );
      }

      Navigator.of(context).pop();
    }
    // 하위 TextFormField의 validate에서 에러(text)를 return할 때
    else {
      print('에러가 있습니다.');
    }
  }
}

class _Time extends StatelessWidget {
  final FormFieldSetter<String> onStartSaved;
  final FormFieldSetter<String> onEndSaved;
  final String startInitialValue;
  final String endInitialValue;
  const _Time(
      {required this.onStartSaved,
      required this.onEndSaved,
      required this.startInitialValue,
      required this.endInitialValue,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextField(
            label: '시작 시간',
            isTime: true,
            onSaved: onStartSaved,
            initialValue: startInitialValue,
          ),
        ),
        SizedBox(
          width: 16.0,
        ),
        Expanded(
          child: CustomTextField(
            label: '마감 시간',
            isTime: true,
            onSaved: onEndSaved,
            initialValue: endInitialValue,
          ),
        ),
      ],
    );
  }
}

class _Content extends StatelessWidget {
  final FormFieldSetter<String> onSaved;
  final String initialValue;
  const _Content({required this.onSaved, required this.initialValue, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: CustomTextField(
        label: '내용',
        isTime: false,
        onSaved: onSaved,
        initialValue: initialValue,
      ),
    );
  }
}

typedef ColorIdSetter = Function(int id);

class _ColorPicker extends StatelessWidget {
  final List<CategoryColor> colors;
  final int? selectedColorId;
  final ColorIdSetter colorIdSetter;

  const _ColorPicker(
      {required this.colors,
      required this.selectedColorId,
      required this.colorIdSetter,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0, // 요소별 수평 띄우기
      runSpacing: 10.0, // 요소별 수직 띄우기
      children: colors
          .map(
            (e) => GestureDetector(
                onTap: () {
                  colorIdSetter(e.id);
                },
                child: renderColor(
                  e,
                  selectedColorId == e.id,
                )),
          )
          .toList(),
    );
  }

  Widget renderColor(CategoryColor color, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color(
            int.parse('FF${color.hexCode}', radix: 16),
          ),
          border: isSelected
              ? Border.all(
                  color: Colors.black,
                  width: 4.0,
                )
              : null),
      width: 32.0,
      height: 32.0,
    );
  }
}

class _SaveButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SaveButton({required this.onPressed, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: PRIMARY_COLOR,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Text(
              '저장',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
