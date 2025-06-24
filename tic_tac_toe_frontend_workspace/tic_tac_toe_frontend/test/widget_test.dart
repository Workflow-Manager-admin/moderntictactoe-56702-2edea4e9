import 'package:flutter_test/flutter_test.dart';
import 'package:tic_tac_toe_frontend/main.dart';

void main() {
  testWidgets('App builds and displays Tic Tac Toe title', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TicTacToeApp());

    // Verify that our title appears.
    expect(find.text('Tic Tac Toe'), findsOneWidget);
    // Optionally, check for presence of Reset button as core UI.
    expect(find.text('Reset'), findsOneWidget);
  });
}
