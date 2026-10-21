import 'package:flutter/material.dart';

import '../grading/grading.dart';

/// Numeric keyboard hint only; our own parser decides what is valid.
const numberKeyboard =
    TextInputType.numberWithOptions(decimal: true, signed: true);

/// The text of one assessment row. Owned and disposed by the page.
class AssessmentFields {
  AssessmentFields(this.id);

  final int id;
  final name = TextEditingController();
  final weight = TextEditingController();
  final maxPoints = TextEditingController();
  final pointsEarned = TextEditingController();
  final nameFocus = FocusNode();

  AssessmentInput toInput() => AssessmentInput(
        name: name.text,
        weight: weight.text,
        maxPoints: maxPoints.text,
        pointsEarned: pointsEarned.text,
      );

  void dispose() {
    name.dispose();
    weight.dispose();
    maxPoints.dispose();
    pointsEarned.dispose();
    nameFocus.dispose();
  }
}

/// One assessment row: on one line when there is room, otherwise stacked in
/// an outlined card so nothing scrolls sideways.
class AssessmentRow extends StatelessWidget {
  const AssessmentRow({
    super.key,
    required this.fields,
    required this.errors,
    required this.canRemove,
    required this.onChanged,
    required this.onRemove,
  });

  static const _singleLineMinWidth = 600.0;
  static const _gap = SizedBox(width: 8);

  final AssessmentFields fields;
  final AssessmentResult errors;
  final bool canRemove;
  final VoidCallback onChanged;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final name = _textField(fields.name, 'Name',
        focusNode: fields.nameFocus, maxLength: 40);
    final weight =
        _textField(fields.weight, 'Weight (%)', error: errors.weightError);
    final maxPoints = _textField(fields.maxPoints, 'Max points',
        error: errors.maxPointsError);
    final pointsEarned = _textField(fields.pointsEarned, 'Points earned',
        error: errors.pointsEarnedError);
    final remove = IconButton(
      onPressed: canRemove ? onRemove : null,
      icon: const Icon(Icons.delete_outline),
      tooltip: 'Remove',
    );

    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= _singleLineMinWidth) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: name),
              _gap,
              Expanded(flex: 2, child: weight),
              _gap,
              Expanded(flex: 2, child: maxPoints),
              _gap,
              Expanded(flex: 2, child: pointsEarned),
              Padding(padding: const EdgeInsets.only(top: 4), child: remove),
            ],
          ),
        );
      }
      return Card.outlined(
        margin: const EdgeInsets.only(bottom: 12),
        // Shows the white page card through, rather than the theme surface.
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            spacing: 8,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: name),
                  Padding(
                      padding: const EdgeInsets.only(top: 4), child: remove),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: weight),
                  _gap,
                  Expanded(child: maxPoints),
                ],
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: pointsEarned), _gap, const Spacer()],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _textField(
    TextEditingController controller,
    String label, {
    String? error,
    FocusNode? focusNode,
    int? maxLength,
  }) =>
      TextField(
        controller: controller,
        focusNode: focusNode,
        maxLength: maxLength,
        keyboardType: maxLength == null ? numberKeyboard : TextInputType.text,
        textInputAction: TextInputAction.next,
        onChanged: (_) => onChanged(),
        decoration: InputDecoration(
          labelText: label,
          errorText: error,
          errorMaxLines: 4,
        ),
      );
}
