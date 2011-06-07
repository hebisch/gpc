  valf:=False;
  run1:=run1+1;
  run2:=0;
  White:=whitespace;
{$undef get} {$define get(X) begin Read(infile,X); tempint:=GetIOResult; ReadLn(infile); SetInOutRes(tempint) end}
{$undef get2}{$define get2(X,Y) begin Read(infile,X); tempint:=GetIOResult; Read(infile,Y); if GetIOResult<>0 then begin ReadLn(infile); Err('unexpected I/O error in ReadLn') end; ReadLn(infile); SetInOutRes(tempint) end}
  TestAll;
{$if not defined (Classic) and not defined (Borland)}
{$undef get} {$define get(X) begin ReadLn(infile,instr);readstr(instr,X) end}
{$undef get2}{$define get2(X,Y) begin ReadLn(infile,instr);readstr(instr,X,Y) end}
  TestAll;
{$undef get} {$define get(X) begin ReadLn(infile,inbuf);readstr(inbuf,X) end}
{$undef get2}{$define get2(X,Y) begin ReadLn(infile,inbuf);readstr(inbuf,X,Y) end}
  TestAll;
{$endif}
{$ifndef Standard}
  White:=False;
{$undef get} {$define get(X) begin ReadLn(infile,instr);Val(instr,X,tempint);SetInOutRes(tempint) end}
{$undef get2}{$define get2(X,Y)
                begin
                  ReadLn(infile,instr);
                  Val(instr,X,tempint2);
                  Val(Copy(instr,1,tempint2-1),X,tempint);SetInOutRes(tempint);
                  if GetInOutRes=0 then Val(Copy(instr,tempint2,Length(instr)-tempint2+1),Y,tempint);SetInOutRes(tempint)
                end}
  valf:=True;
  TestOnlyNum;
{$endif}
