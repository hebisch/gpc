{ Has to compare actual schema size at runtime before assignment. }

program BugDemop;


type
  CClass    = set of Char;
  CClassPtr = ^CClass;
  IntSet(max_elems: Integer)= array [0..max_elems] of Integer;
    { word 0 is size }
  IntSetPtr = ^IntSet;

const
  max_trans =  100;

type
  TransTableEntry = record
                      cc : CClassPtr;
                      { characters of transition }
                      follow_pos      : IntSetPtr;
                      { follow positions (positions of next state) }
                      next_state      : Integer;
                      { next state }
                    end;

  TransTable = array [1..max_trans] of TransTableEntry;

var
  trans_table : ^TransTable;      { DFA transition table }
  i           :  Integer;


begin
  New (trans_table);
  New (trans_table^[1].follow_pos, 42);
  trans_table^[1].follow_pos^ := trans_table^[1].follow_pos^;
  WriteLn ('OK')
end.
