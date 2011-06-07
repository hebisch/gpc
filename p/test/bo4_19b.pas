unit BO4_19b;

interface

type
  p = ^t;
  t = record c, d: Char end;

procedure a (v: p);

var
  q: String (10);

implementation

uses BO4_19a;

procedure a (v: p);
begin
  b (v);
  q := v^.d;
  WriteLn (q)
end;

end.
