{ -g }
{ FLAG -O3 }

program fjf441a;

uses GPC;

type
  t = record
    a : PString
  end;

procedure p1;
var v : t;
begin
  v.a := nil
end;

procedure p2;
type
  x = record
    a : PString;
  end;
begin
end;

begin
  WriteLn ('OK')
end.
