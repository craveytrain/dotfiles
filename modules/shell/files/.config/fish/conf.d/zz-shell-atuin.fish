# shell module - atuin shell history
#
# Named zz- rather than 80- on purpose. Fish loads conf.d alphabetically, and
# fisher plugin fragments (fzf.fish, pisces, puffer) have no numeric prefix, so
# they always sort after 10-/50-/80- ones. Atuin has to bind ctrl-r after
# fzf.fish has installed its bindings, or fzf silently wins.

if status --is-interactive
    # fzf.fish and atuin both want ctrl-r, and they do the same job. Atuin wins;
    # drop fzf's history search and leave its other bindings alone
    # (ctrl-alt-f directory, ctrl-alt-l git log, ctrl-alt-s git status, ...).
    functions --query fzf_configure_bindings; and fzf_configure_bindings --history=

    # --disable-up-arrow: keep fish's own prefix search on up.
    # --disable-ai: atuin binds "?" unconditionally otherwise.
    atuin init fish --disable-up-arrow --disable-ai | source
end
