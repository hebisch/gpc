{$methods-always-virtual}

program fjf903e;

type
  a = abstract object
    procedure p; abstract;  { no warning }
  end;

begin
  WriteLn ('OK')
end.
