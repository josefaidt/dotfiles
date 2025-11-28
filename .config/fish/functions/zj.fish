function zj
  set session_name (basename $PWD)
  set sessions (zellij list-sessions 2>/dev/null)
    
  if string match -q "*$session_name*" $sessions
    zellij attach $session_name
  else
    zellij --layout dev attach --create $session_name
  end
end
