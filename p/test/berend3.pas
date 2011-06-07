{ BUG: see contourbug }

Program Berend3 ( Output );

Type
  String255 = String ( 255 );

Var
  result: String255;

function addExt(filename, ext : String) : String255;
{ implemented with goto for maximum efficiency }
{ PG: This must be a joke! :-(Or does anybody really believe this???) }
Var
  i : Integer;
label
  1{Exit}, 2{x};
begin
  addExt := filename;
  for i := length(filename) downto 1 do
    case filename[i] of
      '.': goto 1{exit};              { #1 }
      '\','/': goto 2;
      otherwise ;
    end;
  2{x}: addExt := filename+'.'+ext;   { #2 }
  1{exit}:
end{addExt};

{ At #2, a temporary variable of non-constant size   }
{ is created on the stack.  Therefore, the `goto' at }
{ #1 must adjust the stack.  :-(                     }

begin
  result:= addExt ( 'foo', 'bar' );
  if result = 'foo.bar' then
    writeln ( 'OK' )
  else
    writeln ( 'failed: ', result );
end.
