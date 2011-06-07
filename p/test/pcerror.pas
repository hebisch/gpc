{ From the old testsuite. Various individual tests moved to pcerror?.pas
  as indicated in the comments. }

{$W no-identifier-case}

program errs(input,output,junk,locked);

uses GPC;

procedure ExpectError;
begin
  if ExitCode = 0 then
    WriteLn ('failed')
  else
    begin
      WriteLn ('OK');
      Halt (0) {!}
    end
end;

label   99;

type
etype = (ECHR, EHALT, ENILPTR, ECASE, EOUTOFMEM, ECTSNG,
ESTLIM, EARGV, EPACK, EUNPACK, EASRT, ELLIMIT, ETRASHHEAP, EPASTEOF,
EREFINAF, ENOFILE, ENAMESIZE, EBADINUM, EBADFNUM, ENUMNTFD, ENAMRNG,
EFMTSIZE, ESEEK, ECREATE, EREMOVE, EOPEN, EREADIT, EWRITEIT, ESQRT,
ELN, ERANGE, ESUBSC, EGOTO, ECLOSE, EWRITE, ECTLWR, ECTUPR, xxx);
biggie = array[1..15000] of integer;

var
ch :char;
{chs :packed array [1..10] of char;
ch1 :array[1..10] of char;}
ptr, ptr1 :^char;
ptr2 :^biggie;
junk, locked, other :file of char;
variant :record
        case boolean of
        true:(val :1..100);
        false:(name :etype)
        end;
s :set of 1..4;
i :integer;
r :real;
err :etype;

begin
AtExit (ExpectError);

{writeln('Want a list of error names?');readln(ch);}
ch:='n';
if ch = 'y' then begin
        for err:=ECHR to pred(xxx) do begin
                write(ord(err):15);
                if ord(err) mod 5 = 4 then
                        writeln;
                end;
        writeln;
        end;
{writeln('enter an error name');readln(err);}
err:=EASRT;
case err of
ESEEK, EGOTO, ECLOSE, EWRITE, xxx: begin
        writeln(ord(err), ': error cannot be simulated');
        goto 99;
        end;
ECHR: ch:=chr(128);  { no bug with charsets bigger than ASCII }
EHALT: halt;  { not an error }
ENILPTR: begin ptr:=nil; write (ptr^); writeln ('failed') end;  { pcerrorc.pas }
ECASE: case 4 of 1:; end;  { pcerrord.pas }
EOUTOFMEM: while true do begin  { this could take a while and hog the OS memory;
                                  not really a good idea for the test suite }
                new(ptr2);
                writeln('alloc successful');
                end;
ECTLWR: begin  { pcerrore.pas }
        i:=0;
        s:=[i..2];
        end;
ECTUPR: begin  { pcerrorf.pas }
        i:=5;
        s:=[1..i];
        end;
ECTSNG: begin  { pcerrorg.pas }
        i:=0;
        s:=[i];
        end;
ESTLIM: {stlimit(0)};  { Non-standard feature not supported by GPC }
EARGV: {argv(100,chs)};  { Non-standard feature not supported by GPC }
EPACK: {pack(ch1,2,chs)};  { pcerrora.pas }
EUNPACK: {unpack(chs,ch1,2)};  { pcerrorb.pas }
EASRT: assert(false);  { tested here }
ELLIMIT: begin
         {linelimit(output,1);}  { Non-standard feature not supported by GPC }
         writeln('This only should print');
         writeln;
         writeln('ERROR');
         end;
ETRASHHEAP: begin
            new(ptr);
            ptr1:=ptr;
            dispose(ptr1);
            dispose(ptr);
            end;
EPASTEOF: begin  { pcerrorh.pas }
          rewrite(junk);
          reset(junk);
          get(junk);
          get(junk);
          write(junk^);
          end;
EREFINAF: ch:=junk^;  { pcerrori.pas }
ENOFILE: ch:=other^;  { pcerrorj.pas }
ENAMESIZE: rewrite(junk,
'thisisaverylongandconvolutedfilenamewhichexceedsalllimitsofreasonablenessandgoodtaste');  { Hardly so. -- lFrank }
EBADINUM: begin  { cf. read*.pas }
          writeln('Enter a letter');
          read(i);
          end;
EBADFNUM: begin  { cf. read*.pas }
          writeln('Enter a letter');
          read(r);
          end;
ENUMNTFD: begin  { pcerrork.pas }
          writeln('Enter your name');
          {read(err);}
          end;
ENAMRNG:  begin  { pcerrorl.pas }
          variant.val:=100;
          {writeln(variant.name);}
          end;
EFMTSIZE: begin  { pcerrorm.pas }
          i:=-1;
          writeln(1.0:i);
          end;
ECREATE: rewrite(locked);  { Why should this be an error? -- Frank }
EREMOVE: {remove('none')};  { Non-standard feature not supported by GPC }
EOPEN: reset(locked);  { Why should this be an error? -- Frank }
EREADIT: read(output,ch);  { pcerrorn.pas }
EWRITEIT: write(input,ch);  { pcerroro.pas }
ESQRT: r:=sqrt(-1.0);  { pcerrorp.pas }
ELN: r:=ln(0);  { pcerrorq.pas }
ERANGE: ch:=succ(chr(127));  { no bug with charsets bigger than ASCII }
ESUBSC: {ch:=ch1[127 + 1]};  { pcerrorr.pas }
end;
writeln('*** ERROR NOT DETECTED ***');
99:end.
