Program CaseAll3 (Output);

uses GPC;

Var
  Meta: (Foo, Bar, Baz);

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

{$classic-pascal}

begin
  AtExit (ExpectError);
  Meta := Foo;
  case Meta of
    Bar: WriteLn ('bar');
    Baz: WriteLn ('baz')
  end { case };
  Write ('failed ')
end.
