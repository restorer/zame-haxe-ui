package org.zamedev.ui.internal;

#if macro

import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import sys.FileSystem;

class ResourcesBuilder {
    // to keep when auto-cleaning inports: Expr, Type

    macro public static function build():Array<Field> {
        var fields = Context.getBuildFields();
        var position = Context.currentPos();

        var fieldId = "board_easy";

        fields.push({
            name: "drawable",
            access: [ APublic ],
            kind: FVar(TAnonymous([{
                pos: position,
                name: fieldId,
                kind: FVar(TPath({
                    name: "Drawable",
                    pack: [],
                })),
            }])),
            pos: position,
        });

        fields.push({
            name: "new",
            access: [ APublic ],
            kind: FFun({
                args: [],
                ret: null,
                expr: {
                    expr: EBinop(OpAssign, {
                        expr: EConst(CIdent("drawable")),
                        pos: position,
                    }, {
                        expr: EObjectDecl([{
                            field: fieldId,
                            expr: {
                                expr: ENew({
                                    name: "Drawable",
                                    pack: [],
                                }, [{
                                    expr: EField({
                                        expr: EConst(CIdent("DrawableType")),
                                        pos: position,
                                    }, "BITMAP"),
                                    pos: position,
                                }, {
                                    expr: EConst(CString("drawable/board_easy.png")),
                                    pos: position,
                                }]),
                                pos: position,
                            }
                        }]),
                        pos: position,
                    }),
                    pos: position,
                }
            }),
            pos: position,
        });

        // FileSystem.readDirectory("assets")

        return fields;
    }
}

#end
