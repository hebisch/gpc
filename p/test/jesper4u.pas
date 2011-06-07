unit u4;   { Note the start-up code }

interface

type
  procType = procedure (var x : Integer);

var
  y3, y4: Integer value 42;

procedure proc3 (procedure f (var x : Integer));
procedure proc4 (f : procType);


implementation

{ Example with Procedural parameter (Standard Pascal) }
procedure proc3 (procedure f (var x : Integer));
var
  y : Integer;

begin
  f(y);
  { WriteLn (y); } y3:= y;
end; { proc3 }

{ Example with Procedural Types (Borland-like) }
procedure proc4 (f : procType);
var
  y : Integer;

begin
  f(y);
  { WriteLn (y); } y4:= y;
end; { proc4 }


procedure Test (var b : Integer);
begin
  b := 2003;
end;


begin
  { Both of these call compile and work.  Note that the procedure   }
  { "Test" which is passed as argument is in the same unit.  Hence, }
  { there is no need for a typecast (as in the main program).       }

  proc3 (Test);  { Procedural parameter example }
  proc4 (Test);  { Procedural type example }
end.
