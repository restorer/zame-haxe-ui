package org.zamedev.ui.tools.generator;

import de.polygonal.Printf;
import org.zamedev.ui.errors.UiParseError;
import org.zamedev.ui.graphics.Color;
import org.zamedev.ui.graphics.Dimension;
import org.zamedev.ui.graphics.DimensionTools;
import org.zamedev.ui.graphics.DimensionType;
import org.zamedev.ui.graphics.Drawable;
import org.zamedev.ui.graphics.Gravity;
import org.zamedev.ui.graphics.GravityTools;
import org.zamedev.ui.graphics.GravityType;
import org.zamedev.ui.graphics.TextAlignExt;
import org.zamedev.ui.i18n.Quantity;
import org.zamedev.ui.res.Styleable;
import org.zamedev.ui.tools.parser.ParseHelper;
import org.zamedev.ui.tools.styleable.StyleableType;
import org.zamedev.ui.view.ViewVisibility;
import org.zamedev.ui.widget.LinearLayoutOrientation;

using StringTools;

@:access(org.zamedev.ui.graphics.Drawable)
class HaxeCode {
    public static function validateIdentifier(name : String, pos : GenPosition) : String {
        switch (name) {
            case "package"
            | "import"
            | "using"
            | "class"
            | "interface"
            | "enum"
            | "abstract"
            | "private"
            | "public"
            | "var"
            | "function"
            | "default":
                throw new UiParseError('"${name}" is reserved haxe identifier', pos);

            default:
                return name;
        }
    }

    public static function genInt(value : Int) : String {
        return Std.string(value);
    }

    public static function genFloat(value : Float) : String {
        return Std.string(value);
    }

    public static function genString(s : String) : String {
        s = s.replace("\"", "\\\"")
            .replace("\n", "\\n")
            .replace("\r", "\\r")
            .replace("\t", "\\t");

        return '"${s}"';
    }

    public static function genBool(value : Bool) : String {
        return (value ? "true" : "false");
    }

    public static function genColor(color : Int) : String {
        return "0x" + Printf.format("%06x", [color]);
    }

    public static function genStyleable(name : String) : String {
        return 'Styleable.${name}';
    }

    public static function genFont(f : GenFont) : String {
        if (f.bitmapName == null) {
            return 'FontExt.createTtf(${genString(f.ttfAssetId)})';
        } else {
            return 'FontExt.createBitmap(${genString(f.bitmapName)}, ${genString(f.bitmapImgAssetId)}, ${genString(f.bitmapXmlAssetId)})';
        }
    }

    public static function genDrawable(d : Drawable, pos : GenPosition) : String {
        switch (d.type) {
            case ASSET_BITMAP:
                return 'Drawable.fromAssetBitmap(${genString(d.id)})';

            case ASSET_PACKED:
                return 'Drawable.fromAssetPacked(${genString(d.id)}, ${d.packedX}, ${d.packedY}, ${d.packedW}, ${d.packedH})';

            default:
                throw new UiParseError('"${d.type}" drawable type is not supported for generation', pos);
        }
    }

    public static function genGravityType(gravityType : GravityType) : String {
        switch (gravityType) {
            case NONE:
                return "GravityType.NONE";

            case START:
                return "GravityType.START";

            case CENTER:
                return "GravityType.CENTER";

            case END:
                return "GravityType.END";
        }
    }

    public static function genGravity(gravity : Gravity) : String {
        return '{ horizontalType : ${genGravityType(gravity.horizontalType)}, verticalType : ${genGravityType(gravity.verticalType)} }';
    }

    public static function genDimensionType(type : DimensionType) : String {
        switch (type) {
            case UNSPECIFIED:
                return "DimensionType.UNSPECIFIED";

            case WIDTH:
                return "DimensionType.WIDTH";

            case HEIGHT:
                return "DimensionType.HEIGHT";

            case MIN:
                return "DimensionType.MIN";

            case MAX:
                return "DimensionType.MAX";
        }
    }

    public static function genDimension(dimen : Dimension) : String {
        switch (dimen) {
            case MATCH_PARENT:
                return "Dimension.MATCH_PARENT";

            case WRAP_CONTENT:
                return "Dimension.WRAP_CONTENT";

            case EXACT(size):
                return 'Dimension.EXACT(${size})';

            case WEIGHT_PARENT(weight, type, useWeightSum):
                return 'Dimension.WEIGHT_PARENT(${weight}, ${genDimensionType(type)}, ${genBool(useWeightSum)})';

            case WEIGHT_STAGE(weight, type, useWeightSum):
                return 'Dimension.WEIGHT_STAGE(${weight}, ${genDimensionType(type)}, ${genBool(useWeightSum)})';
        };
    }

    public static function genQuantity(quantity : Quantity) : String {
        switch (quantity) {
            case ZERO:
                return "Quantity.ZERO";

            case ONE:
                return "Quantity.ONE";

            case TWO:
                return "Quantity.TWO";

            case FEW:
                return "Quantity.FEW";

            case MANY:
                return "Quantity.MANY";

            case OTHER:
                return "Quantity.OTHER";
        }
    }

    public static function genStringArray(value : Array<String>) : String {
        return "[" + value.map(function(v) {
            return genString(v);
        }).join(", ") + "]";
    }

    public static function genTextAlign(value : TextAlignExt) : String {
        switch (value) {
            case CENTER:
                return "TextAlignExt.CENTER";

            case JUSTIFY:
                return "TextAlignExt.JUSTIFY";

            case RIGHT:
                return "TextAlignExt.RIGHT";

            case LEFT:
                return "TextAlignExt.LEFT";
        }
    }

    public static function genViewVisibility(value : ViewVisibility) : String {
        switch (value) {
            case VISIBLE:
                return "ViewVisibility.VISIBLE";

            case INVISIBLE:
                return "ViewVisibility.INVISIBLE";

            case GONE:
                return "ViewVisibility.GONE";
        }
    }

    public static function genLinearLayoutOrientation(value : LinearLayoutOrientation) : String {
        switch (value) {
            case VERTICAL:
                return "LinearLayoutOrientation.VERTICAL";

            case HORIZONTAL:
                return "LinearLayoutOrientation.HORIZONTAL";
        }
    }

    public static function genResolvedValue(textValue : String, type : StyleableType, pos : GenPosition) : String {
        var refInfo = ParseHelper.parseRef(textValue);
        var typeRef = getRefByType(type);

        if (refInfo != null) {
            if (refInfo.type != typeRef) {
                throw new UiParseError('"${textValue}" is not a "${typeRef}"', pos);
            }

            refInfo.name = validateIdentifier(refInfo.name, pos);

            switch (type) {
                case IDENTIFIER:
                    return 'id.${refInfo.name}';

                case COLOR:
                    return 'r.colorMap[color.${refInfo.name}]';

                case DIMENSION:
                    return 'r.dimenMap[dimen.${refInfo.name}]';

                case STRING:
                    return 'r.stringMap[string.${refInfo.name}]';

                case FONT:
                    return 'r.fontMap[font.${refInfo.name}]';

                case DRAWABLE:
                    return 'r.drawableMap[drawable.${refInfo.name}]';

                case STYLE:
                    return 'r.styleMap[style.${refInfo.name}]';

                default:
                    throw new UiParseError('Reference for "${typeRef}" is not supported ("${textValue}")', pos);
            }
        } else {
            switch (type) {
                case COLOR:
                    return genColor(Color.parse(textValue));

                case DIMENSION:
                    return genDimension(DimensionTools.parse(textValue));

                case STRING:
                    return genString(textValue);

                case FLOAT:
                    return Std.string(ParseHelper.parseFloat(textValue, pos));

                case BOOL:
                    return genBool(ParseHelper.parseBool(textValue));

                case STRING_ARRAY:
                    return genStringArray(ParseHelper.parseStringArray(textValue));

                case GRAVITY:
                    return genGravity(GravityTools.parse(textValue));

                case TEXT_ALIGN:
                    return genTextAlign(ParseHelper.parseTextAlign(textValue, pos));

                case VIEW_VISIBILITY:
                    return genViewVisibility(ParseHelper.parseViewVisibility(textValue, pos));

                case LINEAR_LAYOUT_ORIENTATION:
                    return genLinearLayoutOrientation(ParseHelper.parseLinearLayoutOrientation(textValue, pos));

                default:
                    throw new UiParseError('Direct "${typeRef}" value is not supported ("${textValue}")', pos);
            }
        }
    }

    private static function getRefByType(type : StyleableType) : String {
        switch (type) {
            case IDENTIFIER:
                return "id";

            case COLOR:
                return "color";

            case DIMENSION:
                return "dimen";

            case STRING:
                return "string";

            case FONT:
                return "font";

            case DRAWABLE:
                return "drawable";

            case STYLE:
                return "style";

            case FLOAT:
                return "float";

            case BOOL:
                return "bool";

            case STRING_ARRAY:
                return "stringArray";

            case GRAVITY:
                return "gravity";

            case TEXT_ALIGN:
                return "textAlign";

            case VIEW_VISIBILITY:
                return "viewVisibility";

            case LINEAR_LAYOUT_ORIENTATION:
                return "linearLayoutOrienration";
        }
    }
}
