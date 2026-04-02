# dev-tools module - direnv environment switcher activation

if status --is-interactive
    direnv hook fish | source
end
