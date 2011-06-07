Unit BO4_15w;

Interface

uses
  BO4_14v;

Var
  O: record
    K: pString;  { WRONG }
  end { OK };

Implementation

end.
