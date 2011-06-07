{ BUG: Probably the same issue as contourbug }

Program TCS_Test1;
Label 1;

Var Line:String(255);
    Fseed:Text;
    s:String(10);

Begin
  s:='failed';
  Line:='ABC';
  If Line[3] <>'C' then Goto 1;
  s:='OK';
  If s='dummy' then Reset(Fseed,Line+'seed');
1:WriteLn(s)
End.
