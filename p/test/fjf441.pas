{ -g }
{ FLAG -O0 }

program fjf441;

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
