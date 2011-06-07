PROGRAM FP;

FUNCTION F1: Pointer; BEGIN F1:= NIL END;

FUNCTION F2( I: INTEGER): Pointer; BEGIN F2:= NIL END;

VAR
 P1 : Pointer value @F1; {error - initializer element for `P1' is not
constant}
 P2 : Pointer value @F2; {OK}

BEGIN
if (P1 = @F1) and (P2 = @F2) then WriteLn ('OK') else WriteLn ('failed')
END.
