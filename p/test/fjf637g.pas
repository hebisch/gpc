program fjf637g;

type
  a = abstract object
    procedure foo; abstract;
    procedure bar; abstract;
  end;

  b = object (a)
    procedure foo;  { WARN }
  end;

begin
  WriteLn ('failed')
end.
