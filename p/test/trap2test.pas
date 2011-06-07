{ Test of the Trap unit with nested traps. }

program Trap2Test;

uses Trap;

var
  s : String (100);

procedure Test2 (Trapped : Boolean);
var Counter : Integer = 0; attribute (static);
begin
  s := s + '<';
  if Trapped then
    begin
      Inc (Counter);
      if Counter < 8 then
        Write (Ln (0))
      else
        s := s + '>'
    end
  else
    begin
      s := s + '#';
      Write (Ln (0))
    end
end;

procedure Test (Trapped : Boolean);
var Counter : Integer = 0; attribute (static);
begin
  s := s + '[';
  if not Trapped then
    Write (Ln (0));
  TrapExec (Test2);  { Nested trap! }
  Inc (Counter);
  if Counter < 5 then
    begin
      s := s + '-';
      Write (Ln (0))
    end
  else
    s := s + ']'
end;

begin
  s := '';
  TrapExec (Test);
  TrappedExitCode := 0;
  TrappedErrorAddr := nil;
  TrappedErrorMessageString := '';
  if s = '[[<#<<<<<<<<>-[<#<>-[<#<>-[<#<>-[<#<>]' then
    WriteLn ('OK')
  else
    WriteLn ('failed ', s)
end.
