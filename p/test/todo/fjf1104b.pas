program fjf1104b (Output);

type
  MyString (i: Integer) = packed array [1 .. i] of Char;
  TString = MyString (100);

function f: TString;
begin
  f := 'OK this is not'
end;

var
  s: MyString (2) = f;

begin
  WriteLn (s)
end.
