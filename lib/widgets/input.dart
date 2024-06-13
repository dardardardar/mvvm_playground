import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_playground/const/enums.dart';
import 'package:mvvm_playground/const/theme.dart';
import 'package:mvvm_playground/widgets/typography.dart';

class InputQty extends StatefulWidget {
  final int minVal;
  final int maxVal;
  final int initVal;
  final double width;
  final Color? btnColor;
  final Function(int) onQtyChanged;

  const InputQty({
    super.key,
    this.minVal = 0,
    this.maxVal = 999999999999,
    this.initVal = 0,
    this.width = 32,
    required this.onQtyChanged,
    this.btnColor,
  });
  @override
  State<StatefulWidget> createState() => _InputQty();
}

class _InputQty extends State<InputQty> {
  TextEditingController qtyController = TextEditingController();
  int value = 0;
  @override
  void initState() {
    super.initState();
    qtyController.text = widget.initVal.toString();
    setState(() {
      value = widget.initVal;
    });
  }

  _applyValue() {
    qtyController.text = value.toString();
  }

  _onDecrease() {
    if (value > widget.minVal) {
      setState(() {
        value--;
      });
      _applyValue();
    }
  }

  _onIncrease() {
    if (value < widget.maxVal) {
      setState(() {
        value++;
      });
      _applyValue();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: value <= 0
                    ? Colors.black12
                    : widget.btnColor ?? primaryColor,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                fixedSize: const Size(30, 30),
                minimumSize: const Size(20, 20),
              ),
              onPressed: value <= 0
                  ? () {}
                  : () {
                      _onDecrease();
                      widget.onQtyChanged(value);
                    },
              child: Icon(
                Icons.remove,
                color: value > 0 ? null : Colors.black45,
              ),
            ),
          ),
          SizedBox(
            width: widget.width,
            child: TextField(
              onTapOutside: (event) {
                FocusManager.instance.primaryFocus?.unfocus();
              },
              textAlign: TextAlign.center,
              controller: qtyController,
              style: TStyles.body,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              onChanged: (val) {
                setState(() {
                  value = int.parse(val);
                  widget.onQtyChanged(int.parse(val));
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: widget.btnColor ?? primaryColor,
                shape: const CircleBorder(),
                padding: EdgeInsets.zero,
                fixedSize: const Size(30, 30),
                minimumSize: const Size(20, 20),
              ),
              onPressed: () {
                _onIncrease();
                widget.onQtyChanged(value);
              },
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}

class InputFormField extends StatefulWidget {
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final String label;
  final bool? isDark;
  const InputFormField(
      {super.key,
      this.controller,
      this.validator,
      required this.label,
      this.isDark});

  @override
  State<InputFormField> createState() => _InputFormFieldState();
}

class _InputFormFieldState extends State<InputFormField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        displayText(widget.label,
            style:
                widget.isDark != null || false ? Styles.BodyAlt : Styles.Body),
        TextFormField(
          onTapOutside: (event) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
          decoration: const InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              ),
              //When the TextFormField is ON focus
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
              )),
          style: TextStyle(
            color: Colors.white, // Change this to your desired color
          ),
          controller: widget.controller,
          validator: widget.validator,
        ),
      ],
    );
  }
}
