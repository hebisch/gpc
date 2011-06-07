program fjf637d;

type
  a = abstract object
    procedure foo; abstract;
  end;

var
  v: a;  { WRONG }

begin
  WriteLn ('failed')
end.
