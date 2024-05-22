import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:mvvm_playground/const/theme.dart';

Widget textField({String? placeholder}) {
  return SizedBox(
    height: 40,
    child: TextField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      decoration: InputDecoration(
        hintText: placeholder,
        hintStyle: inputPlaceholder,
        contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        prefixIcon: const Icon(
          Icons.search,
          color: borderColor,
        ),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: BorderSide.none),
        filled: true,
        fillColor: barBackgroundColor,
      ),
      style: textBody,
    ),
  );
}

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
              style: TextStyle(color: Colors.black),
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
