program fjf1099;

uses GPC;

var
  a, r: String (10);
  b: ConstAnyString;
  f: Text;

begin
  a := 'XOKY';
  StringTFDD_Reset (f, b, a[2 .. 3]);
  Read (f, r);
  WriteLn (r)
end.
