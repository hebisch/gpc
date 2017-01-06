{$define tst(wr)
  wr,c,c:w0,'x',c:1,c:2,c:3);
  wr,'a',c0,'b',c0:3,'c');
  wr,True,False,True:2,False:2,True:10,False:10);
  wr,s);
  wr,s,s:4,s2);
  wr,s:30,s2:30,s3,s3:30,s3:4);
  wr,cs,cs:4,cs:30);
  wr,cs,';',cs2,';;',s2,';',q,'...');
  wr,cs:1,';':1,cs2:1,';;':1,s2:1,';':1,q:1,'...':1);
  wr,cs:80,';':80,cs2:80,';;':80,s2:80,';':80,q:80,'...':80);
  wr,i8,' ',i16,' ',i32,' ',im,' ',i64);
  wr,c8,' ',c16,' ',c32,' ',cm,' ',c64);
  wr,i8,i16,i32,im,i64);
  wr,c8,c16,c32,cm,c64);
  wr,i8:1,' ',i16:1,' ',i32:1,' ',im:1,' ',i64:1);
  wr,c8:1,' ',c16:1,' ',c32:1,' ',cm:1,' ',c64:1);
  wr,i8:30,' ',i16:30,' ',i32:30,' ',im:30,' ',i64:30);
  wr,c8:30,' ',c16:30,' ',c32:30,' ',cm:30,' ',c64:30);
  wr,sr,' ',r,' ',lr);
  wr,sr:5,' ',r:15,' ',lr:40);
  wr,sr:5:p0,' ',r:20:2,' ',lr:40:8);
  wr,-sr,' ',-r,' ',-lr);
  wr,-sr:5,' ',-r:15,' ',-lr:40);
  wr,-sr:5:p0,' ',-r:20:2,' ',-lr:40:8);
  wr,si,' ',d,' ',ex);
  wr,si:5,' ',d:15,' ',ex:40);
  wr,si:5:p0,' ',d:20:2,' ',ex:40:8);
  wr,-si,' ',-d,' ',-ex);
  wr,-si:5,' ',-d:15,' ',-ex:40);
  wr,-si:5:p0,' ',-d:20:2,' ',-ex:40:8);
}

procedure w(q:xstring);
begin
  {$i writesub.inc}
  {$write-capital-exponent}
  {$write-clip-strings}
  {$write-real-blank}
  {$i writesub.inc}
  {$field-widths}
  {$i writesub.inc}
  {$field-widths=21:42:8:44:88}
  {$i writesub.inc}
  {$no-write-capital-exponent}
  {$no-write-clip-strings}
  {$no-write-real-blank}
  {$i writesub.inc}
  {$no-field-widths}
  {$i writesub.inc}
end;

{$gnu-pascal}

type tstr=string(2000);

var
  sfoo:tstr;
  OK:Boolean;
  i,j:Integer;

function sp(n:Integer):tstr;
var
  i:Integer;
  s:tstr;
begin
  setlength(s,n);
  for i:=1 to n do s[i]:=' ';
  sp:=s
end;

procedure err(s:string);
begin
  if run=0 then write(dialect,': ') else write('Run #',run,': ');
  WriteLn(s);
  OK:=False
end;

procedure str(s:string);
begin
  if (s <> '') and ((length(sfoo)<length(s)) or ne(sfoo[1..length(s)],s)) then
    err('Expected string `'+s+''' not found, but `'+sfoo[1..min(length(s),length(sfoo))]+'''');
  Delete(sfoo,1,length(s))
end;

procedure scl(s:string;w:Integer;n:string);
var
  full:Boolean;
  clipflag:Boolean;
begin
  if w>length(s) then w:=length(s);
  if (w <> 0) and ((length(sfoo)<w) or ne(sfoo[1..w],s[1..w])) then
    err('Expected string `'+s[1..w]+''' not found, but `'+sfoo[1..min(w,length(sfoo))]+'''');
  full:=(length(sfoo)>=length(s)) and eq(sfoo[1..length(s)],s);
  if full then Delete(sfoo,1,length(s)) else Delete(sfoo,1,w);
  clipflag:=(clipstr or eq(n,'Boolean')) and ne(n,'Integer');
  if full and clipflag then
    err(n+' `'+s+''' was not clipped, but should be.');
  if not full and not clipflag then
    err(n+' `'+s+''' was clipped, but should not be.')
end;

procedure sf(s:string;w:Integer;n:string);
var
  c:Integer;
  t:tstr;
begin
  c:=1;
  while (c<length(sfoo)) and (sfoo[c]=' ') do inc(c);
  dec(c);
  Delete(sfoo,1,c);
  if (c<>0) and (w=0) then
    begin
      writestr(t,n,' `',s,''' was indented with field width ',c+length(s),', but should not be.');
      err(t)
    end
  else if (c=0) and (w>length(s)) then
    begin
      writestr(t,n,' `',s,''' was not indented, but should be.');
      err(t)
    end
  else if c<>max(w-length(s),0) then
    begin
      writestr(t,n,' `',s,''' was indented with field width ',c+length(s),', but should be with field width ',w,'.');
      err(t)
    end;
  str(s)
end;

procedure l;
begin
  if ne(sfoo,'') then err('Additional output `'+sfoo+'''');
  if eof(foo) then
    begin
      err('Premature end of output.');
      halt(1)
    end;
  ReadLn(foo,sfoo)
end;

procedure sl(s:string);
begin
  str(s);
  l
end;

procedure ints(spaces:Boolean;w:Integer);
var s:string(1);

  procedure sti(s:string;l:Boolean);
  begin
    case w of
      0:if l
          then sf(s,flint,'LongInt')
          else sf(s,fint,'Integer');
      1:scl(s,1,'Integer');
      2:sf(s,30,'Integer')
    end
  end;

begin
  if spaces then s:=' ' else s:='';
  sti('123',False);
  str(s);
  sti('12345',False);
  str(s);
  sti('1234567890',False);
  str(s);
  sti('1234567899', SizeOf (MedInt) > SizeOf (Integer));
  str(s);
  sti('-7890123456789012345', SizeOf (Integer) < 8);
  l;
  sti('234',False);
  str(s);
  sti('23455',False);
  str(s);
  sti('2345678901',False);
  str(s);
  sti('2345678902',SizeOf (MedCard) > SizeOf (Cardinal));
  str(s);
  sti('12345678901234567890', SizeOf (Integer) < 8);
  l;
end;

procedure reals(negative:Boolean);
var i,fr:Integer;

  procedure rn(n1,n2:Integer;r:Real;ebl:Boolean);
  var
    c1,c2:Integer;
    r2:Real;
    t:tstr;
    bl:Boolean;
  begin
    ebl:=ebl and not (negative or noblank);
    if negative then str('-');
    bl:=ne(sfoo,'') and (sfoo[1]=' ');
    if bl then Delete(sfoo,1,1);
    if bl and not ebl then
      err('Real blank found, but not expected.')
    else if ebl and not bl then
      err('Real blank not found, but expected.');
    c1:=1;
    while (c1<=length(sfoo)) and (sfoo[c1] in ['0'..'9']) do inc(c1);
    dec(c1);
    if c1<>n1 then
      begin
        writestr(t,'Real number ',r,' has ',c1,' digits before the decimal point, but ',n1,' were expected.');
        err(t)
      end;
    c2:=c1;
    if n2<>0 then
      begin
        inc(c2);
        if not ((c2<=length(sfoo)) and (sfoo[c2]='.')) then
          err('Decimal point missing.');
        inc(c2);
        while (c2<=length(sfoo)) and (sfoo[c2] in ['0'..'9']) do inc(c2);
        dec(c2);
        if c2-c1-1<>n2 then
          begin
            writestr(t,'Real number ',r,' has ',c2-c1-1,' digits after the decimal point, but ',n2,' were expected.');
            err(t)
          end
      end;
    ReadStr(sfoo[1..c2],r2);
    Delete(sfoo,1,c2);
    if abs(r/r2-1)>1e-8 then
      begin
        writestr(t,'Real number ',r,' was output as ',r2);
        err(t)
      end
  end;

  procedure exp;
  begin
    if eq(sfoo,'') or not (sfoo[1] in ['e','E'])
      then err('Exponent `e'' not found.')
      else
        begin
          if capexp and (sfoo[1]='e') then
            err('Exponent should be capitalized.')
          else if not capexp and (sfoo[1]='E') then
            err('Exponent should not be capitalized.');
          Delete(sfoo,1,1)
        end
  end;

  procedure sv(lrf:Boolean);
  var cfr:Integer;
  begin
    if negative or not noblank then i:=1 else i:=0;
    if lrf then cfr:=flreal else cfr:=freal;
    if cfr=0 then fr:=15 else fr:=cfr-i-6
  end;

begin
  sv(False);
  rn(1,fr,sr/1e9,True);
  exp;
  str('+09 ');
  rn(1,fr,rc/1e9,True);
  exp;
  str('+09 ');
  sv(True);
  rn(1,fr,rc/1e9,True);
  exp;
  str('+09');
  l;
  sv(False);
  rn(1,1,trunc(sr/1e8)/10,True);
  exp;
  str('+09 ');
  rn(1,9-i,rc/1e9,True);
  exp;
  str('+09 ');
  sv(True);
  rn(1,34-i,rc/1e9,True);
  exp;
  str('+09');
  l;
  sv(False);
  rn(10,p0,sr,False);
  str(sp(8-ord(negative)));
  rn(10,2,rc,False);
  str(sp(22-ord(negative)));
  sv(True);
  rn(10,8,rc,False);
  l;
end;

procedure test;
begin
  OK:=True;
  if s[14..16]<>'ld!' then
    begin
      WriteLn('Initialized strings with a #0 in them are cut after the #0.');
      OK:=False;
      s[14..16]:='ld!'
    end;
  assign(foo,'write.dat');
  rewrite(foo);
  w(s);
  WriteLn(foo);
  reset(foo);
  ReadLn(foo,sfoo);
  for run:=0 to 5 do
    begin
      case run of
        1:begin capexp:=True;  clipstr:=True;  noblank:=False end;
        2:begin fint:=11; freal:=23; fbool:=6; flint:=21; flreal:=29 end;
        3:begin fint:=21; freal:=42; fbool:=8; flint:=44; flreal:=88 end;
        4:begin capexp:=False; clipstr:=False; noblank:=True  end;
        5:begin fint:=0;  freal:=0;  fbool:=0; flint:=0;  flreal:=0  end;
      end;
      for i:=1 to 1 {$if not defined (Classic) and not defined (Borland)} + 1 {$endif}
                    {$if not defined (Standard) and not defined (Borland)} + 1 {$endif} do
        begin
          str('a');
          if w0=0 then scl('a',0,'Char') else str('a');
          sl('xa a  a');
          sl('a'+Chr(0)+'b  '+Chr(0)+'c');
          sf('True',fbool,'Boolean');
          sf('False',fbool,'Boolean');
          scl('True',2,'Boolean');
          scl('False',2,'Boolean');
          sl('      True     False');
          sl(sc);
          str(sc);
          scl(sc,4,'String');
          sl(sc4);
          str(sp(14)+sc+sp(18)+sc4+sc5+sp(20)+sc5);
          scl(sc5,4,'Array of char');
          l;
          str(sc2);
          scl(sc2,4,'CString');
          sl(sp(19)+sc2);
          sl(sc2+';'+sc3+';;'+sc4+';'+sc+'...');
          scl(sc2,1,'CString');
          str(';');
          scl(sc3,1,'PChar');
          scl(';;',1,'Constant string');
          scl(sc4,1,'String');
          str(';');
          scl(sc,1,'String');
          scl('...',1,'Constant string');
          l;
          sl(sp(69)+sc2+sp(79)+';'+sp(74)+sc3+sp(78)+';;'+sp(68)+sc4+sp(79)+';'+sp(64)+sc+sp(77)+'...');
          ints(True,0);
          ints(False,0);
          ints(True,1);
          ints(True,2);
          for j:=0 to 3 do reals(odd(j));
          l
        end
    end;
  if not eof(foo) then
    begin
      WriteLn('Too much output.');
      OK:=False
    end;
  if OK then WriteLn('OK')
end;
