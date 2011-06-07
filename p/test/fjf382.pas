{ This bug only occurs for c >= 5 (on 32 bit machines) }

program fjf382;

const c = 5;

type
  ta = array [1 .. c] of Char;
  tb = record
    a : ta
  end;

procedure foo (const a : ta);
begin
  WriteLn (a [1 .. 2])
end;

procedure bar (const b : tb);
begin
  foo (b.a)
end;

var
  b : tb;

begin
  b.a := 'OK';
  bar (b)
end.
