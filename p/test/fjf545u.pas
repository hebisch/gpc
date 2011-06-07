unit fjf545u;

interface

var Cond: Boolean = False;

implementation

{$gpc-main="oldmain"}

procedure OldMain (ArgC: Integer; ArgV, Env: Pointer); external name 'oldmain';

procedure Main (ArgC: Integer; ArgV, Env: Pointer); attribute (name = 'main');
begin
  Cond := True;
  OldMain (ArgC, ArgV, Env)
end;

end.
