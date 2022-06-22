import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

// import 'package:form_builder/data.dart';
import 'package:intl/intl.dart';

import 'data.dart';

// import 'result.dart';

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
  var autoValidate = AutovalidateMode.disabled;

  void _submit() {
    setState(() {
      autoValidate = AutovalidateMode.always;
    });

    if (!_fbKey.currentState!.validate()) {
      return;
    }

    _fbKey.currentState!.save();
    final inputValues = _fbKey.currentState!.value;
    debugPrint(inputValues.toString());
    //
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) {
    //     return Result(values: inputValues);
    //   }),
    // );
    //
  }

  // List<String> getSuggestion(String query) {
  //   if (query.isEmpty) {
  //     return [];
  //   }
  //
  //   List<String> matches = [];
  //   final regionNames = regions.map((region) {
  //     return region['regionName'];
  //   }).toList();
  //
  //   matches.addAll(regionNames);
  //
  //   matches.retainWhere((s) => s.contains(query));
  //   return matches;
  // }
  //
  // bool _checkRegionName(String regionName) {
  //   final foundRegion = regions.firstWhere((region) {
  //     return region['regionName'] == regionName;
  //   }, orElse: () => null);
  //
  //   return foundRegion == null ? false : true;
  // }

  InputDecoration inputDecoration(String label) => InputDecoration(
        filled: true,
        labelText: label,
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
                      name: 'startDate',
                      // map의 키값, attribute >> name
                      inputType: InputType.date,
                      // 시간도 설정할 수 있음
                      initialValue: startDate,
                      // 시작일 설정가능
                      firstDate: startDate,
                      // 시작~마지막 범위를 지정하여 제한가능
                      lastDate: DateTime(
                          startDate.year + 1, startDate.month, startDate.day),
                      format: DateFormat('yyyy-MM-dd'),
                      decoration: inputDecoration('시작일'),
                      // 하나만 검증하려면 required 사용
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
                      decoration: inputDecoration('종료일'),
                      // 여러가지 검증하려면 compose 사용
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(errorText: '종료일은 필수입니다'),
                        (val) {
                          debugPrint('val: $val');
                            final sd = _fbKey.currentState!.fields['startDate']!.value;
                            debugPrint('sd: $sd');

                            if (sd != null && sd.isAfter(val)) {
                              return '시작일이 종료일보다 뒤입니다';
                            }
                            return null;
                        },
                      ]),
                    ),
                    // const SizedBox(height: 20),
                    // FormBuilderDropdown(
                    //   attribute: 'cropId',
                    //   items: crops.map<DropdownMenuItem<String>>((crop) {
                    //     return DropdownMenuItem<String>(
                    //         value: crop['id'], child: Text(crop['cropName']));
                    //   }).toList(),
                    //   hint: const Text('대상 품종을 선택하세요'),
                    //   decoration: const InputDecoration(
                    //     filled: true,
                    //     labelText: '품종',
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   validators: [
                    //     FormBuilderValidators.required(
                    //       errorText: '품종을 필수입니다',
                    //     ),
                    //   ],
                    // ),
                    // const SizedBox(height: 20),
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
                    // const SizedBox(height: 20),
                    // FormBuilderTextField(
                    //   attribute: 'area',
                    //   decoration: const InputDecoration(
                    //     filled: true,
                    //     labelText: '면적',
                    //     hintText: '제곱미터 단위로 면적을 입력하세요',
                    //     border: OutlineInputBorder(),
                    //   ),
                    //   validators: [
                    //     FormBuilderValidators.required(errorText: '면적은 필수입니다'),
                    //     FormBuilderValidators.numeric(errorText: '숫자만 입력하세요'),
                    //     (val) {
                    //       final area = double.parse(val);
                    //       if (area < 100 || area > 10000) {
                    //         return '유효면적은 100에서 10000 사이입니다';
                    //       }
                    //       return null;
                    //     }
                    //   ],
                    // ),
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
                    // _fbKey.currentState.reset();
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
