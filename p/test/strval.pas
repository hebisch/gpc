Program StrVal;

Var
  S: String [ 42 ];
  O: Byte;
  K: LongInt;
  Code: Integer;

begin
  Str ( ord ( 'O' ), S );
  Code:= 137;
  Val ( S, O, Code );
  if Code = 0 then
    begin
      Code:= 42;
      Val ( '75', K, Code );
      if Code = 0 then
        writeln ( chr ( O ), chr ( K ) )
      else
        writeln ( 'failed: "75" ', Code );
    end { if }
  else
    writeln ( 'failed: "', S, '" ', Code );
end.
