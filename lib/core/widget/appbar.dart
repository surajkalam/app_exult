
import 'package:coffee_shop/core/utils/utils.dart';
import 'package:flutter/material.dart';


class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? titleText;
  final IconData? icon;
  final Widget? leadingWidget;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final double? elevation;
  final bool centerTitle;
  final double toolbarHeight;
  

  const CustomAppBar({
    super.key,
    this.titleText,
    this.icon,
    this.leadingWidget,
    this.titleWidget,
    this.actions,
    this.backgroundColor,
    this.elevation,
    this.centerTitle = false,
    this.toolbarHeight = kToolbarHeight,
    
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // final textTheme = Theme.of(context).textTheme;
    return AppBar(
      leading: leadingWidget ?? (icon != null ? IconButton(
        icon: Icon(icon,color: colorScheme.secondaryFixed,),
        onPressed: () => Navigator.of(context).pop(),
      ) : null),
      title: titleWidget 
      ?? (titleText != null 
      ? Text(titleText!,style: textTheme.titleLarge?.copyWith(color: colorScheme.primaryContainer, fontWeight: FontWeight.w400,fontSize: 14),) 
      : null
      ),
      actions: actions,
      backgroundColor: backgroundColor ?? Theme.of(context).colorScheme.surface,
      elevation: elevation ?? Theme.of(context).appBarTheme.elevation,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      foregroundColor: colorScheme.primary,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(toolbarHeight);
}

