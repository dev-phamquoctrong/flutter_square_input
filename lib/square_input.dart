library square_input;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SquareInputView extends StatefulWidget {
  final ValueChanged<String> onResult;
  final int squareInputLength;

  const SquareInputView({
    Key? key,
    required this.onResult,
    this.squareInputLength = 4,
  }) : super(key: key);

  @override
  State<SquareInputView> createState() => _SquareInputViewState();
}

class _SquareInputViewState extends State<SquareInputView> {
  String codeEntered = '';
  final focusNodes = <FocusNode>[];
  final controllers = <TextEditingController>[];

  @override
  void initState() {
    super.initState();
    while (focusNodes.length < widget.squareInputLength) {
      focusNodes.add(
        FocusNode(),
      );
    }
    while (controllers.length < widget.squareInputLength) {
      controllers.add(
        TextEditingController(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        widget.squareInputLength,
        (index) => _InputItem(
          onInput: (String value) {
            codeEntered += value;
            widget.onResult(codeEntered);
            if (index == focusNodes.length - 1) {
              FocusScope.of(context).unfocus();
            } else {
              focusNodes[index + 1].requestFocus();
            }
          },
          onDelete: (bool isDeletePrevious) {
            codeEntered = codeEntered.substring(0, codeEntered.length - 1);
            widget.onResult(codeEntered);
            if (isDeletePrevious && codeEntered.length >= 2) {
              controllers[index - 1].text = '';
              focusNodes[index - 2].requestFocus();
            } else {
              controllers[index].text = '';
              if (codeEntered.isNotEmpty) {
                focusNodes[index - 1].requestFocus();
              } else {
                FocusScope.of(context).unfocus();
              }
            }
          },
          focusNode: focusNodes[index],
          controller: controllers[index],
        ),
      ),
    );
  }
}

class _InputItem extends StatefulWidget {
  const _InputItem({
    Key? key,
    required this.onInput,
    required this.focusNode,
    required this.controller,
    required this.onDelete,
  }) : super(key: key);
  final ValueChanged<String> onInput;
  final ValueChanged<bool> onDelete;
  final FocusNode focusNode;
  final TextEditingController controller;

  @override
  State<_InputItem> createState() => _InputItemState();
}

class _InputItemState extends State<_InputItem> {
  final focusNodeDetect = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF6F4F5),
        borderRadius: BorderRadius.circular(
          8,
        ),
      ),
      child: Center(
        child: RawKeyboardListener(
          focusNode: focusNodeDetect,
          onKey: (event) {
            //Because this function is getting called for both keydown and keyup events with instances of following classes:
            // 1.RawKeyDownEvent (Pressed a key).
            // 2.RawKeyUpEvent (Release a key).
            // if (event.runtimeType.toString() == 'RawKeyDownEvent') -> Ensure this trigger a time.
            if (event.runtimeType.toString() == 'RawKeyDownEvent') {
              if (event.logicalKey == LogicalKeyboardKey.backspace) {
                final text = widget.controller.text;
                widget.controller.text = '';
                if (text.isNotEmpty) {
                  widget.onDelete(false);
                } else {
                  widget.onDelete(true);
                }
              }
            }
          },
          child: TextFormField(
            controller: widget.controller,
            focusNode: widget.focusNode,
            autofocus: true,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
            ],
            style: const TextStyle(
              color: Color(0xFF2C3137),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.zero,
              focusedBorder: InputBorder.none,
              border: InputBorder.none,
            ),
            onChanged: (String value) {
              widget.onInput(widget.controller.text);
            },
          ),
        ),
      ),
    );
  }
}
