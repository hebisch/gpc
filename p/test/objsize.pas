Program ObjSize;

Type
  FirstPtr = ^FirstObj;
  SecondPtr = ^SecondObj;

FirstObj = object
  p: Pointer;
  a, b: Integer;
  Constructor Init;
end { FirstObj };

SecondObj = object ( FirstObj )
  c, d: Integer;
end { FirstObj };

Var
  p: FirstPtr;
  O: FirstObj;

Constructor FirstObj.Init;

begin { FirstObj.Init }
  { empty }
end { FirstObj.Init };

function Align (v, Alignment : Integer) : Integer;
begin
  Inc (v, Alignment - 1);
  Align := v - v mod Alignment
end;

begin
  O.Init;
  p:= @O;
  if (SizeOf (p^) < 2 * SizeOf (Pointer) + 2 * SizeOf (Integer))
     or (SizeOf (p^) > Align (2 * SizeOf (Pointer) + 2 * SizeOf (Integer), AlignOf (p^))) then
    WriteLn ('failed 1 ', SizeOf (p^), ' ', Align (2 * SizeOf (Pointer) + 2 * SizeOf (Integer), AlignOf (p^)))
  else
    begin
      p:= New ( SecondPtr, Init );
      if (SizeOf (p^) < 2 * SizeOf (Pointer) + 4 * SizeOf (Integer))
         or (SizeOf (p^) > Align (2 * SizeOf (Pointer) + 4 * SizeOf (Integer), AlignOf (p^))) then
        WriteLn ('failed 2 ', SizeOf (p^), ' ', Align (2 * SizeOf (Pointer) + 4 * SizeOf (Integer), AlignOf (p^)))
      else
        WriteLn ('OK')
    end
end.
