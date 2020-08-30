function! clojure#glue#iced#gf()
  if clojure#glue#try('connected?')
    call iced#nrepl#var#get(funcref('s:def_jump_or_gf'))
  else
    normal! gf
  end
endfunction



function! s:def_jump_or_gf(resp)
  if type(a:resp) == v:t_dict && has_key(a:resp, 'file')
    IcedDefJump
  else
    normal! gf
  end
endfunction
