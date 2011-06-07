program ian7 (input,output);

var
  s: String (42);
  i: Integer;

procedure Test;
var r: Real;
begin
  Inc (i);
  r := 0;
  ReadStr (s, r);
  if Abs (r - 0.1) > 1e-6 then
    begin
      WriteLn ('failed ', i, ': ', s);
      Halt
    end
end;

begin
  i := 0;
  WriteStr (s, 10.0*0.01);            Test;
  WriteStr (s, 100.0*0.001);          Test;
  WriteStr (s, 1.0*0.1);              Test;
  WriteStr (s, 10.0*0.01 : 0 : 10);   Test;
  WriteStr (s, 100.0*0.001 : 0 : 10); Test;
  WriteStr (s, 1.0*0.1 : 0 : 10);     Test;
  WriteLn ('OK')
end.
