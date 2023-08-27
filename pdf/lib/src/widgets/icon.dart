/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'package:meta/meta.dart';
import 'package:vector_math/vector_math_64.dart';

import '../../pdf.dart';
import 'basic.dart';
import 'geometry.dart';
import 'text.dart';
import 'text_style.dart';
import 'theme.dart';
import 'widget.dart';

/// A description of an icon fulfilled by a font glyph.
@immutable
class IconData {
  /// Creates icon data.
  const IconData(
    this.codePoint,
    this.fontFamily, {
    this.matchTextDirection = false,
  });

  /// The Unicode code point at which this icon is stored in the icon font.
  final int codePoint;
  final String fontFamily;

  /// Whether this icon should be automatically mirrored in right-to-left
  /// environments.
  final bool matchTextDirection;
}

/// Defines the color, opacity, and size of icons.
@immutable
class IconThemeData {
  /// Creates an icon theme data.
  const IconThemeData({
    this.color,
    this.opacity,
    this.size,
    required this.fontList,
  });

  /// Creates an icon them with some reasonable default values.
  const IconThemeData.fallback(this.fontList)
      : color = PdfColors.black,
        opacity = 1.0,
        size = 24.0;

  /// Creates a copy of this icon theme but with the given fields replaced with
  /// the new values.
  IconThemeData copyWith({
    PdfColor? color,
    double? opacity,
    double? size,
    List<FontData>? fontList,
  }) {
    return IconThemeData(
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      size: size ?? this.size,
      fontList: fontList ?? this.fontList,
    );
  }

  /// The default color for icons.
  final PdfColor? color;

  /// An opacity to apply to both explicit and default icon colors.
  final double? opacity;

  /// The default size for icons.
  final double? size;

  /// The font to use
  final List<FontData> fontList;
}

/// A graphical icon widget drawn with a glyph from a font described in
/// an [IconData] such as material's predefined [IconData]s in [Icons].
class Icon extends StatelessWidget {
  /// Creates an icon.
  Icon(
    this.icon, {
    this.size,
    this.color,
    this.textDirection,
  }) : super();

  /// The icon to display. The available icons are described in [Icons].
  final IconData icon;

  /// The size of the icon in logical pixels.
  final double? size;

  /// The color to use when drawing the icon.
  final PdfColor? color;

  /// The text direction to use for rendering the icon.
  final TextDirection? textDirection;

  @override
  Widget build(Context context) {
    final textDirection = this.textDirection ?? Directionality.of(context);
    final iconTheme = Theme.of(context).iconTheme;
    final iconSize = size ?? iconTheme.size;
    final iconColor = color ?? iconTheme.color!;
    final iconOpacity = iconColor.alpha;
    final iconFont = iconTheme.fontList
        .firstWhere(
          (element) => element.name == icon.fontFamily,
        )
        .font;

    Widget iconWidget = RichText(
      textDirection: textDirection,
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle.defaultStyle().copyWith(
          color: iconColor,
          fontSize: iconSize,
          fontFamily: iconFont.fontName,
          fontList: [
            FontData(font: iconFont, name: iconFont.fontName),
          ],
        ),
      ),
    );

    if (icon.matchTextDirection) {
      switch (textDirection) {
        case TextDirection.rtl:
          iconWidget = Transform(
            transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
            alignment: Alignment.center,
            child: iconWidget,
          );
          break;
        case TextDirection.ltr:
          break;
      }
    }

    if (iconOpacity < 1.0) {
      iconWidget = Opacity(
        opacity: iconOpacity,
        child: iconWidget,
      );
    }
    return iconWidget;
  }
}
