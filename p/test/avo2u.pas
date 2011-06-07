unit avo2u;

interface

FUNCTION F1: Pointer;

FUNCTION F2( I: INTEGER): Pointer;

VAR
  P1 : Pointer value @F1; {error - initializer element for `P1' is not constant}
  P2 : Pointer value @F2; {OK}

implementation

FUNCTION F1: Pointer; BEGIN F1:= NIL END;

FUNCTION F2( I: INTEGER): Pointer; BEGIN F2:= NIL END;

END.
