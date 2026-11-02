using terms from application "Terminal"
tell application "Terminal"
  set nerdFont to "JetBrainsMonoNerdFontMono-Regular"
  set profileNames to name of every settings set
  repeat with profileName in profileNames
    set font name of settings set profileName to nerdFont
  end repeat
end tell
end using terms from
