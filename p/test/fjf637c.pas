program fjf637c;

type
  a = object
    procedure foo; abstract;
  end;

var
  v: a;  { WRONG }

begin
  WriteLn ('failed')
end.
