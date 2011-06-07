{ `=' comparison of records. Do we want/need that?

  I don't think any standard or dialect supports this.
  But it can be achieved via operator overloading, as inserted here.
  -- Frank, 20030324 }

program rec(output);
type
        alfa = packed array[1..10] of char;
        status = (married, widowed, divorced, single);
        date = record
                mo: (jan, feb, mar, apr, may, jun,
                        july, aug, sept, Oct, nov, dec);
                day: 1..31;
                year: integer
                end;
        person = record
                name: record
                        first, last: alfa
                        end;
                ss: integer;
                sex: (male, female);
                birth: date;
                depdts: integer;
                case ms: status of
                        married, widowed: (
                                mdate: date);
                        divorced: (
                                ddate: date;
                                firstd: boolean);
                        single: (
                                indepdt: boolean)
                end;

operator = (const a, b: date) c: boolean;
begin
  c := (a.mo = b.mo) and (a.day = b.day) and (a.year = b.year)
end;

operator = (const a, b: person) c: boolean;
begin
  if (a.name.first = b.name.first)
     and (a.name.last = b.name.last)
     and (a.ss = b.ss)
     and (a.sex = b.sex)
     and (a.birth = b.birth)
     and (a.depdts = b.depdts)
     and (a.ms = b.ms) then
    case a.ms of
      married, widowed: c := a.mdate = b.mdate;
      divorced: c := (a.ddate = b.ddate) and (a.firstd = b.firstd);
      single: c := a.indepdt = b.indepdt;
      else c := False
    end
  else
    c := False
end;

var
        pp: person;
        p: ^person;
begin
        pp.name.last := 'woodyard';
        pp.name.first := 'edward';
        pp.ss := 845680539;
        pp.sex := male;
        pp.birth.mo := aug;
        pp.birth.day := 30;
        pp.birth.year := 1941;
        pp.depdts := 1;
        pp.ms := single;
        pp.indepdt := true;

        new(p);
        p^.name.last := 'woodyard';
        p^.name.first := 'edward';
        p^.ss := 845680539;
        p^.sex := male;
        p^.birth.mo := aug;
        p^.birth.day := 30;
        p^.birth.year := 1941;
        p^.depdts := 1;
        p^.ms := single;
        p^.indepdt := true;
        if pp = p^ then
                writeln('OK');
end.
