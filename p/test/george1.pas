program why;

var t: Text;
var Look: char;              { Lookahead Character }

procedure GetChar;
begin
   Read(t, Look);
end;

begin
  Rewrite (t);
  WriteLn (t);
  WriteLn (t, '.');
  Reset (t);
  GetChar; if Look <> ' ' then begin WriteLn ('failed 1'); Halt end;
  GetChar; if Look <> '.' then begin WriteLn ('failed 2'); Halt end;
  WriteLn ('OK')
end.
