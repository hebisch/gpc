{$extended-pascal}
program ProtectVarParameterTest(input, output);

var
  globalInt : Integer;

function GetInteger: Integer;
begin
GetInteger := 1;
end;

procedure DoSomethingProtectedVar(protected var anInt : Integer);
begin
globalInt := anInt;
end;

procedure DoSomethingVar(var anInt : Integer);
begin
globalInt := anInt;
end;

var b:Cardinal;
begin
globalInt := 0;
DoSomethingVar(GetInteger); {WRONG}
writeln('FAIL');
end.
