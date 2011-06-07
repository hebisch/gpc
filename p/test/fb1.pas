program FB1;

type

char_arr = array[1..30] of char;

smallrec = RECORD
  arr : char_arr;
END;

largerec = packed RECORD
  one_rec     : smallrec;
  many_rec    : array[1..5] of smallrec;
  one_array   : char_arr;
  many_arrays : array[1..5] of char_arr;
END;

VAR
  r:largerec;
  c:char_arr;


BEGIN

  c := 'This is just a test, whatever.';

  r.one_array :=c;
  r.one_rec.arr :=c;
  r.many_arrays[1] :=c;

  r.many_rec[1].arr:=c;  { cannot take address of packed record field `many_rec' }

  r.many_rec[1].arr[1]:=#0;

  if (r.one_array =c)
     and (r.one_rec.arr = c)
     and (r.many_arrays[1] = c)
     and (r.many_rec[1].arr = #0'his is just a test, whatever.') then
    WriteLn ('OK')
  else
    WriteLn ('failed')

END.
