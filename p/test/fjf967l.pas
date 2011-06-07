program fjf967l;

type
  t = packed record
        i: 0 .. 19;
        q: 2 .. 3;
      case c: 0 .. 5 of
        3: (x: packed array [1 .. 200] of 0..7)
        otherwise (y: Integer)
      end value [i: 4; q: 2; case c: 3 of [x: [1, 4 .. 177: 5; 182: 4 otherwise 2]]];

var
  v: ^t;

procedure p (a: t);
var
  OK: Boolean;
  i, j: Integer;
begin
  OK := True;
  if (a.i <> 4) or (a.c <> 3) or (a.q <> 2) then
    begin
      WriteLn ('failed 1');
      OK := False
    end;
  for i := 1 to 200 do
    begin
      case i of
        1, 4 .. 177: j := 5;
        182: j := 4;
        else j := 2
      end;
      if a.x[i] <> j then
        begin
          WriteLn ('failed 2 ', i, ' ', a.x[i], ' ', j);
          OK := False
        end
    end;
  if OK then WriteLn ('OK') else WriteLn ('failed')
end;

begin
  New (v);
  p (v^)
end.
