function _install_vsc_extensions
  for line in (cat ./exts.txt)
    code --install-extension $line
  end
end