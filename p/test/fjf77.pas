{ COMPILE-CMD: fjf77.cmp }

program fjf77;

uses GPC;

var
  a:Integer;
  b,c:LongReal;
  {$include "test.dat"}

begin
  b:=1; for a:=1 to i do b:=b*10;
  c:=1; for a:=1 to i do c:=c/10;
  if IsInfinity (b) then
    begin
      WriteLn ('failed: b IsInfinity');
      Halt
    end;
  if b = 2 * b then
    begin
      WriteLn ('failed: b big');
      Halt
    end;
  if c = 0 then
    begin
      WriteLn ('failed: c = 0');
      Halt
    end;
  if c = 2 * c then
    begin
      WriteLn ('failed: c small');
      Halt
    end;
  {$field-widths}
  if (Abs (b / d - 1) < 1E-10)
     and (Abs (c / e - 1) < 1E-10) then
    WriteLn ('OK')
  else
    WriteLn('failed: ',b,c,d,e)
end.
