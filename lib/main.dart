import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:intl/intl.dart';

import 'data.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Builder Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final DateTime startDate = DateTime.now();
  AutovalidateMode autoValidate = AutovalidateMode.disabled;
  final TextEditingController _typeAheadController = TextEditingController();

  void _submit() {
    setState(() {
      autoValidate = AutovalidateMode.always;
    });

    final form = _fbKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    // _fbKey.currentState!.save();
    form.save();

    // final inputValues = _fbKey.currentState!.value;
    var inputValues = form.value;
    debugPrint(inputValues.toString());
    debugPrint(_typeAheadController.text.toString());

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) {
    //     return Result(values: inputValues);
    //   }),
    // );
    //
  }

// 입력한 단어가 포함한 모든 리스트 리턴
  List<String> getSuggestion(String query) {
    if (query.isEmpty) {
      return [];
    }

    List<String> matches = [];
    List<String> regionNames = regions.map((region) {
      return region['regionName']!;
    }).toList();

    // for(var regionName in regionNames) {
    //   matches.add(regionName);
    // }
    matches.addAll(regionNames);

    matches.retainWhere((s) => s.contains(query));
    return matches;
  }

// 입력한 단어가 리스트에 존재하는지 확인.
  bool _checkRegionName(String regionName) {
    final foundRegion = regions.firstWhere(
      (region) {
        // 리턴 타입이 map 타입임
        return region['regionName'] == regionName;
      },
      orElse: () {
        // 정상인 리턴 타입이 map 타입이므로 여기도 map 타입으로 리턴해야 함
        return {"_id": "null", "dongcode": "null", "regionName": "null"};
      },
    );

    return foundRegion['regionName'] == "null" ? false : true;
  }

// InputDecoration 축약 스타일로
  InputDecoration inputDecoration({required String label, String hint = ''}) =>
      InputDecoration(
        filled: true,
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Builder Demo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 40,
                horizontal: 20,
              ),
              child: FormBuilder(
                key: _fbKey,
                autovalidateMode: autoValidate,
                child: Column(
                  children: <Widget>[
                    FormBuilderDateTimePicker(
                      // map 형식의 키값 설정, attribute >> name
                      name: 'startDate',
                      // 시간은 사용안함
                      inputType: InputType.date,
                      initialValue: startDate,
                      // 시작일 설정하면 과거 선택 불가
                      firstDate: startDate,
                      // 마지막일 범위를 지정하여 제한가능
                      lastDate: DateTime(
                          startDate.year + 1, startDate.month, startDate.day),
                      format: DateFormat('yyyy-MM-dd'),
                      decoration: inputDecoration(label: '시작일'),
                      // 하나만 검증하려면 required 사용
                      // 여러가지 검증하려면 compose 사용
                      validator: FormBuilderValidators.required(
                        errorText: '시작일은 필수입니다',
                      ),
                      // validators: [
                      //   FormBuilderValidators.required(
                      //     errorText: '시작일은 필수입니다',
                      //   )
                      // ],
                    ),
                    const SizedBox(height: 20),
                    FormBuilderDateTimePicker(
                      name: 'endDate',
                      inputType: InputType.date,
                      initialValue: startDate,
                      firstDate: startDate,
                      lastDate: DateTime(
                          startDate.year + 1, startDate.month, startDate.day),
                      format: DateFormat('yyyy-MM-dd'),
                      decoration: inputDecoration(label: '종료일'),
                      // 하나만 검증하려면 required 사용
                      // 여러가지 검증하려면 compose 사용
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '종료일은 필수입니다'),
                        (val) {
                          // debugPrint('val: $val');
                          final sd =
                              _fbKey.currentState!.fields['startDate']!.value;
                          // debugPrint('sd: $sd');

                          if (sd != null && sd.isAfter(val)) {
                            return '시작일이 종료일보다 뒤입니다';
                          }
                          return null;
                        },
                      ]),
                    ),
                    const SizedBox(height: 20),
                    FormBuilderDropdown(
                      name: 'cropId',
                      items: crops.map<DropdownMenuItem<String>>((crop) {
                        return DropdownMenuItem<String>(
                            value: crop['id'], child: Text(crop['cropName']!));
                      }).toList(),
                      hint: const Text('대상 품종을 선택하세요'),
                      decoration: inputDecoration(label: '품종'),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '품종을 필수입니다'),
                      ]),
                    ),
                    Visibility(
                      visible: false,
                      child: FormBuilderTextField(
                        controller: _typeAheadController,
                        name: 'regionName',
                        decoration: const InputDecoration(
                          labelText:
                              'This value is passed along to the [Text.maxLines] attribute of the [Text] widget used to display the hint text.',
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TypeAheadFormField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _typeAheadController,
                        decoration: inputDecoration(
                            label: '시군구', hint: '시군구 자동으로 입력됩니다'),
                      ),
                      suggestionsCallback: (String pattern) {
                        return getSuggestion(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion.toString()),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        debugPrint(suggestion.toString());
                        _typeAheadController.text = suggestion.toString();
                        // _checkRegionName1(_typeAheadController.text);
                      },
                      // 미입력 검증, 입력하다가 중단한 경우 검증
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '시군구는 필수입니다'),
                        (val) {
                          if (!_checkRegionName(val!)) {
                            return '잘못된 지역 이름입니다';
                          }
                          return null;
                        }
                      ]),
                    ),
                    // FormBuilderTypeAhead(
                    //   attribute: 'regionName',
                    //   decoration: const InputDecoration(
                    //     filled: true,
                    //     labelText: '시군구',
                    //     hintText: '시군구를 입력하면 자동 완성됩니다',
                    //     border: const OutlineInputBorder(),
                    //   ),
                    //   validators: [
                    //     FormBuilderValidators.required(
                    //       errorText: '시군구는 필수입니다',
                    //     ),
                    //     (val) {
                    //       if (!_checkRegionName(val)) {
                    //         return '잘못된 지역 이름입니다';
                    //       }
                    //       return null;
                    //     }
                    //   ],
                    //   suggestionsCallback: (pattern) {
                    //     return getSuggestion(pattern);
                    //   },
                    //   itemBuilder: (context, suggestion) {
                    //     return ListTile(
                    //       title: Text(suggestion),
                    //     );
                    //   },
                    // ),
                    const SizedBox(height: 20),
                    FormBuilderTextField(
                      name: 'area',
                      decoration: inputDecoration(
                          label: '면적', hint: '제곱미터 단위로 면적을 입력하세요'),
                      // 미입력 검증, 숫자만 입력가능, 범위이내 검증
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '면적은 필수입니다'),
                        FormBuilderValidators.numeric(errorText: '숫자만 입력하세요'),
                        (val) {
                          final area = double.parse(val!);
                          if (area < 100 || area > 10000) {
                            return '유효면적은 100에서 10000 사이입니다';
                          }
                          return null;
                        }
                      ]),
                    ),
                    // const SizedBox(height: 20),
                    // FormBuilderRadio(
                    //   attribute: 'urgent',
                    //   decoration: const InputDecoration(
                    //     filled: true,
                    //     labelText: '긴급 여부',
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   validators: [
                    //     FormBuilderValidators.required(
                    //       errorText: '긴급여부를 선택하세여',
                    //     ),
                    //   ],
                    //   options: ['긴급', '보통']
                    //       .map(
                    //         (u) => FormBuilderFieldOption(value: u),
                    //       )
                    //       .toList(),
                    // ),
                    // const SizedBox(height: 20),
                    // FormBuilderCheckboxList(
                    //   attribute: 'warning',
                    //   leadingInput: true,
                    //   decoration: const InputDecoration(
                    //     filled: true,
                    //     fillColor: Colors.amberAccent,
                    //     labelText: '주의사항',
                    //     border: const OutlineInputBorder(),
                    //   ),
                    //   validators: [
                    //     (val) {
                    //       if (val.length != 2) {
                    //         return '전부 동의하셔야 합니다';
                    //       }
                    //       return null;
                    //     }
                    //   ],
                    //   options: [
                    //     const FormBuilderFieldOption(value: '악천후 시 일정 재협의'),
                    //     const FormBuilderFieldOption(value: '10% 선금 지급 필수'),
                    //   ],
                    // ),
                  ],
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                MaterialButton(
                  onPressed: _submit,
                  color: Colors.indigo,
                  textColor: Colors.white,
                  minWidth: 120,
                  height: 45,
                  child: const Text(
                    'SUBMIT',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
                MaterialButton(
                  onPressed: () {
                    _fbKey.currentState!.reset();
                  },
                  color: Colors.red,
                  textColor: Colors.white,
                  minWidth: 120,
                  height: 45,
                  child: const Text(
                    'RESET',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
