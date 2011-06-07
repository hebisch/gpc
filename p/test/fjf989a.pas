program fjf989a;

{ `asm' range test }

uses GPC;

var
  a: 10 .. 20;

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

begin
  {$ifdef i386}
  AtExit (ExpectError);
  asm ('movl $5, %0' : '=g' (a));
  {$else}
  WriteLn ('OK')
  {$endif}
end.
