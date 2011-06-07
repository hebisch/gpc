unit BO4_19a;

interface

uses BO4_19b;

var
  s: String (10);

procedure b (v: p);

implementation

procedure b (v: p);
begin
  s := v^.c;
  Write (s)
end;

end.
