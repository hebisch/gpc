module m_generic_sort interface;

export generic_sort = (do_the_sort, max_sort_index,
                       protected current_pass => number_of_passes,
                       protected swap_occurred_during_sort);

type
   max_sort_index =  1..maxint;

procedure do_the_sort(element_count : max_sort_index; function
greater(e1, e2 : max_sort_index) : boolean; procedure swap(e1,e2 :
max_sort_index) );

var
   current_pass              : 0..maxint value 0;
   swap_occurred_during_sort : boolean value false;

end.

module m_generic_sort implementation;

procedure do_the_sort;
var
   swap_occurred_this_pass : boolean;
   n                       : max_sort_index;

begin
   current_pass := 0;
   swap_occurred_during_sort := false;
   repeat
      swap_occurred_this_pass := false;
      current_pass := current_pass + 1;
      for n := 1 to element_count - 1 do
         if greater(n, n + 1) then begin
            swap(n, n + 1);
            swap_occurred_this_pass := true;
         end;
      swap_occurred_during_sort := swap_occurred_during_sort or swap_occurred_this_pass;
   until not swap_occurred_this_pass;
end; { do_the_sort }

end.
