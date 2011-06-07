{ FLAG --delphi }

program fjf434d;

var
  cfoo, cbar : Boolean;
  vfoo, vbar, a : Integer;
  i : Integer = 0;

function foo : Integer;
begin
  if cfoo then
    begin
      WriteLn ('foo called twice');
      Halt
    end;
  cfoo := True;
  foo := vfoo
end;

function bar : Integer;
begin
  if cbar then
    begin
      WriteLn ('bar called twice');
      Halt
    end;
  cbar := True;
  bar := vbar
end;

procedure Check (c : Boolean);
begin
  Inc (i);
  if not c then
    begin
      WriteLn ('failed #', i, ': ', a);
      Halt
    end;
  if not cfoo then
    begin
      WriteLn ('failed #', i, ': foo not called');
      Halt
    end;
  if not cbar then
    begin
      WriteLn ('failed #', i, ': bar not called');
      Halt
    end
end;

begin
  vfoo :=  42; vbar :=  17; cfoo := False; cbar := False; a := foo mod bar; Check (a =  8);
  vfoo :=  42; vbar := -17; cfoo := False; cbar := False; a := foo mod bar; Check (a =  8);
  vfoo := -42; vbar :=  17; cfoo := False; cbar := False; a := foo mod bar; Check (a = -8);
  vfoo := -42; vbar := -17; cfoo := False; cbar := False; a := foo mod bar; Check (a = -8);
  WriteLn ('OK')
end.
