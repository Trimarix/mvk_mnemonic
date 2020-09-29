import 'package:flutter/material.dart';


class PanelButton extends StatelessWidget {

  final Key key;
  final String _text;
  final bool _isConfirmBtn;
  final bool _isCancelBtn;
  final Function() _onPressed;


  PanelButton(this._text, this._isConfirmBtn, this._isCancelBtn,
      this._onPressed, {this.key}) : super(key: key) {
    assert(!(_isConfirmBtn && _isCancelBtn));
  }

  @override
  Widget build(BuildContext context) => FlatButton(
    onPressed: _onPressed,
    child: Text(
      _text,
      style: _isConfirmBtn || _isCancelBtn
        ? Theme.of(context).textTheme.button.copyWith(
          color: _isConfirmBtn
            ? Colors.green
            : Colors.red
          )
        : null,
    ),
  );

}

class Panel extends StatefulWidget {

  final String title, text;
  final Widget panelContent;
  final List<PanelButton> buttons;
  final Color circleColor;
  final Widget icon;

  Panel({
    @required this.title,
    @required this.text,
    @required this.buttons,
    this.panelContent,
    this.circleColor = Colors.grey,
    this.icon,
  });

  @override
  State<StatefulWidget> createState() => PanelState();

}

class PanelState extends State<Panel> {

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Stack(children: <Widget>[
          Container(
              padding: EdgeInsets.only(
                top: 56,
                left: 16,
                right: 16,
              ),
              margin: EdgeInsets.only(top: 40),
              decoration: new BoxDecoration(
                  color: Theme.of(context).canvasColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10.0,
                    offset: const Offset(0.0, 10.0),
                  )]
              ),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.0),
                    Text(widget.text),
                    SizedBox(height: 6.0),
                    Container(
                      constraints: BoxConstraints(
//                        minHeight: 0,
//                        maxHeight: 330,
                      ),
                      child: widget.panelContent == null
                          ? Container(height: 0, width: 0,)
                          : widget.panelContent,
                    ),
                    SizedBox(height: 24.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: widget.buttons,
                    ),
                  ]
              )
          ),
          Positioned(
              left: 16,
              right: 16,
              child: CircleAvatar(
                backgroundColor: widget.circleColor.withOpacity(0.8),
                radius: 40,
                child: widget.icon,
              )
          )
        ]
        ),
      ),
    );
  }
}
