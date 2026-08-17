import 'package:dietario/data/datasources/remote/remote_mappers.dart';
import 'package:dietario/domain/entities/plan_note.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('new note payload leaves UUID generation to Supabase', () {
    final row = RemotePayloads.noteRow(
      householdId: '11111111-1111-1111-1111-111111111111',
      n: const PlanNote(
        id: 1,
        topic: 'Hidratación',
        respected: 'Tomar agua',
        applied: 'Botella lista',
        source: 'Plan',
        orderIndex: 0,
      ),
    );

    expect(row.containsKey('id'), isFalse);
    expect(row['household_id'], '11111111-1111-1111-1111-111111111111');
  });
}
