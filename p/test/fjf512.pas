program fjf512;

label
  l1, l2, l3;

procedure g1;
begin
  goto l1;
  WriteLn ('failed g1');
  Halt
end;

procedure g2;
begin
  goto l2;
  WriteLn ('failed g2');
  Halt
end;

procedure g3;
begin
  goto l3;
  WriteLn ('failed g3');
  Halt
end;

var
  i : Integer = 0;

begin
  g2;
  WriteLn ('failed 0');
  Halt;
l1:
  Inc (i);
  case i of
     2: begin
          g3;
          WriteLn ('failed 1');
          Halt
        end;
     7: begin
          g1;
          WriteLn ('failed 2');
          Halt
        end;
     8: begin
          g3;
          WriteLn ('failed 3');
          Halt
        end;
    else
      WriteLn ('failed 4');
      Halt
  end;
l2:
  Inc (i);
  case i of
     1: begin
          g1;
          WriteLn ('failed 5');
          Halt
        end;
     4: begin
          g2;
          WriteLn ('failed 6');
          Halt
        end;
     5: begin
          g3;
          WriteLn ('failed 7');
          Halt
        end;
    else
      WriteLn ('failed 8');
      Halt
  end;
l3:
  Inc (i);
  case i of
     3: begin
          g2;
          WriteLn ('failed 9');
          Halt
        end;
     6: begin
          g1;
          WriteLn ('failed 10');
          Halt
        end;
     9: begin
          g3;
          WriteLn ('failed 11');
          Halt
        end;
    10: WriteLn ('OK');
    else
      WriteLn ('failed');
      Halt
  end
end.
