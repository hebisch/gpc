program fjf444b;

var
  cfoo, cbar : Boolean;
  vfoo, vbar, a : Integer;

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
var i : Integer = 0; attribute (static);
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
  vfoo :=  42; vbar :=  17; cfoo := False; cbar := False; a := foo div bar; Check (a =  2);
  vfoo :=  42; vbar := -17; cfoo := False; cbar := False; a := foo div bar; Check (a = -2);
  vfoo := -42; vbar :=  17; cfoo := False; cbar := False; a := foo div bar; Check (a = -2);
  vfoo := -42; vbar := -17; cfoo := False; cbar := False; a := foo div bar; Check (a =  2);
  WriteLn ('OK')
end.
