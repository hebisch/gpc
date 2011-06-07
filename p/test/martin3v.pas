Unit martin3v;
Interface

Type TRecord = packed Record
                 a, b, c, d, e, f, g, h, i: Boolean
               end;

Var ARecord:TRecord = (False, True, True, True, False, True, False, False, True);
    s: Integer;

Implementation

Begin
  s := SizeOf (TRecord)
end.
