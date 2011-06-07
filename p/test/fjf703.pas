program fjf703;

type
  a = packed object  { WRONG }
        b: Integer
      end;

begin
  WriteLn ('failed')
end.
