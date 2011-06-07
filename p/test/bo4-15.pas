Unit BO4_15u;

Interface

Type
  pString = ^String;

Implementation

end.


Unit BO4_15v;

Interface

uses
  BO4_15u;

Const
  Bla: pString = Nil;

Implementation

end.


Unit BO4_15w;

Interface

uses
  BO4_15v;

Var
  O: record
    K: pString;  { WRONG }
  end { OK };

Implementation

end.


Program BO4_15;

uses
  BO4_15w;

begin
  O.K:= @'failed';
  writeln ( O.K^ );
end.
