Program SizeOfs;
Type
    TObj = Object
        foo, bar: Integer;
        Constructor Init;
    End;

    bar = array [1 .. 16] of Integer;

Constructor TObj.Init;
    Begin
      foo:= 42;
    End;

function Align (v, Alignment : Integer) : Integer;
Begin
  Inc (v, Alignment - 1);
  Align := v - v mod Alignment
End;

Var
    O : TObj;

Begin
    O.Init;
    if ( SizeOf (bar) = 16 * SizeOf (Integer) )
       and ( SizeOf (O) >= SizeOf (Pointer) + 2 * SizeOf (Integer))
       and ( SizeOf (O) <= Align (SizeOf (Pointer) + 2 * SizeOf (Integer), AlignOf (O)))
       and ( SizeOf (TObj) = SizeOf (O) ) then
      writeln ( 'OK' )
    else
      writeln ( 'failed: ', SizeOf ( bar ), ' ', SizeOf ( O ) );
End.
