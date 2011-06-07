program dimwit2(output);
var JNTJ, ZJ: integer;
    A : array [1..20] of char;
    ILINE : array [1..20] of integer;
function ALFNUM(i : integer): boolean;
begin
  ALFNUM := true
end;
procedure p;
  function q: boolean;
  begin
    q := true
  end;
  function q: boolean; { WRONG }
  begin
    begin
      WHILE (JNTJ < ZJ) AND NOT ALFNUM(ILINE[JNTJ]) DO
        A := '          ';
    end;
  end;
begin
  if q then writeln('failed2')
end;
begin
  p
end
.
