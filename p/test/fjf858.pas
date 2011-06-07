{ Should write `OK'. }

{$borland-pascal}

program fjf858;

var
  t: Text;
  s: String [20];

begin
  if ParamStr (1) = '' then
    begin
      WriteLn ('failed 1');
      Halt
    end;
  FillChar (t, SizeOf (t), 0);
  Assign (t, ParamStr (1));
  Reset (t);
  ReadLn (t, s);
  WriteLn (Copy (s, 17, 2))
end.
