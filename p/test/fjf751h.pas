{ FLAG -Widentifier-case }

program fjf751h;

uses fjf751v;

begin
  WriteLn ('failed ', foobar)  { WARN }
end.
