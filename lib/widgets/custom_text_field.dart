import 'package:dating_app/export.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool isPassword;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final int? maxLines;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.isPassword = false,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.maxLines,
  }) : super(key: key);

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      maxLines: widget.isPassword ? 1 : widget.maxLines,
      cursorColor: isDarkMode ? Colors.white : Colors.black,
      style: TextStyle(
        fontSize: 18,
        color: isDarkMode ? Colors.white : Colors.black,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          fontSize: 18,
        ),
        prefixIcon: Icon(
          widget.icon,
          color: isDarkMode ? Colors.white70 : Colors.black54,
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 18),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDarkMode ? Colors.grey[500]! : Colors.grey[400]!,
            width: 1,
          ),
        ),
        filled: true,
        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
      ),
      validator: widget.validator,
    );
  }
}
