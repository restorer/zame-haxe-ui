package org.zamedev.ui.internal;

class XmlExt {
    public static function getNodeValue(node:Xml, def:String = ""):String {
        var child = node.firstChild();

        if (child != null && (child.nodeType == Xml.PCData || child.nodeType == Xml.CData)) {
            return child.nodeValue;
        }

        return def;
    }
}
