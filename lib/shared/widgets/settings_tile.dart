import 'package:flutter/material.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.icon,
    this.trailing,
    this.onTap,
    this.textColor,
  });

  factory SettingsTile.switchTile({
    Key? key,
    required String title,
    String? subtitle,
    IconData? leading,
    IconData? icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return SettingsTile(
      key: key,
      title: title,
      subtitle: subtitle,
      leading: leading,
      icon: icon,
      trailing: Builder(
        builder: (context) => SizedBox(
          height: 24,
          child: Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ),
      ),
      onTap: () {
        onChanged(!value);
        onTap?.call();
      },
      textColor: textColor,
    );
  }

  factory SettingsTile.sliderTile({
    Key? key,
    required String title,
    String? subtitle,
    IconData? leading,
    IconData? icon,
    required double value,
    required ValueChanged<double> onChanged,
    double min = 0.0,
    double max = 1.0,
    int? divisions,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return SettingsTile(
      key: key,
      title: title,
      subtitle: subtitle,
      leading: leading,
      icon: icon,
      trailing: Builder(
        builder: (context) => SizedBox(
          width: 200,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Slider(
                value: value,
                onChanged: onChanged,
                min: min,
                max: max,
                divisions: divisions,
                activeColor: Theme.of(context).primaryColor,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      min.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      value.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      max.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      onTap: onTap,
      textColor: textColor,
    );
  }

  factory SettingsTile.navigationTile({
    Key? key,
    required String title,
    String? subtitle,
    IconData? leading,
    IconData? icon,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return SettingsTile(
      key: key,
      title: title,
      subtitle: subtitle,
      leading: leading,
      icon: icon,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
      textColor: textColor,
    );
  }
  final String title;
  final String? subtitle;
  final IconData? leading;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                if (leading != null || icon != null)
                  Container(
                    width: 40,
                    height: 40,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      leading ?? icon,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: textColor ?? theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.textTheme.bodyMedium?.color
                                ?.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null)
                  Flexible(
                    child: Container(
                      margin: const EdgeInsets.only(left: 12),
                      constraints: BoxConstraints(
                        maxWidth: trailing is Slider ? 160 : double.infinity,
                      ),
                      child: trailing,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
