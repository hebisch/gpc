{ This feature was once discussed, but found unnecessary and confusing.
  Frank and Peter, 20030324 }

Program CstPtr1;

Var
  p: ^Integer = @79;  { WRONG }
  q: ^Integer = @75;

begin
  writeln ( 'failed ', chr ( p^ ), chr ( q^ ) );
end.
