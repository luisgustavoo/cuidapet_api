import 'package:mocktail/mocktail.dart';
import 'package:mysql1/mysql1.dart';
import 'package:test/expect.dart';

class MockResultRow extends Mock implements ResultRow {
  MockResultRow(this.fields, [this.blobFields]);

  @override
  List<Object?>? values;

  @override
  Map<String, dynamic> fields;

  List<String>? blobFields;

  @override
  dynamic operator [](dynamic index) {
    if (index is int) {
      return values?[index];
    } else {
      final fieldName = index.toString();
      if (fields.containsKey(fieldName)) {
        final dynamic fieldValue = fields[fieldName];
        if(blobFields != null && blobFields!.contains(fieldName)){
          return Blob.fromString(fieldValue.toString());
        }
        return fieldValue;
      } else {
        fail('Field $fieldName not found in fixture');
      }
    }
  }
}