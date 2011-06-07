unit fjf628b;

interface

uses fjf628a;

procedure p (v: t);

implementation

procedure p (v: t);
begin
  if v = b then WriteLn ('OK') else WriteLn ('failed')
end;

end.
