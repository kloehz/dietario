import 'package:dietario/data/datasources/local/app_database_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('supports the aggregate queries used by web repositories', () async {
    final store = createLocalStore();
    await store.open();

    expect(
      await store.rawQuery(
        'SELECT COALESCE(MAX(order_index), -1) AS m FROM plan_notes',
      ),
      [{'m': -1}],
    );

    await store.insertRow('plan_notes', {'order_index': 3});
    await store.insertRow('plan_notes', {'order_index': 7});
    await store.insertRow('shopping_items', {'status': 'pendiente'});
    await store.insertRow('shopping_items', {'status': 'comprado'});

    expect(
      await store.rawQuery(
        'SELECT COALESCE(MAX(order_index), -1) AS m FROM plan_notes',
      ),
      [{'m': 7}],
    );
    expect(
      await store.rawQuery('SELECT COUNT(*) AS c FROM shopping_items'),
      [{'c': 2}],
    );
    expect(
      await store.rawQuery(
        "SELECT COUNT(*) AS c FROM shopping_items WHERE status = 'comprado'",
      ),
      [{'c': 1}],
    );
  });
}
