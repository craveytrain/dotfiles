# p10k instant prompt (MUST be near top)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Source conf.d fragments (numeric order)
for conf in "$HOME/.zsh/conf.d/"*.sh(N); do
  [[ ${DOTFILES_DEBUG:-0} == 1 ]] && echo "sourcing: $conf"
  source "$conf"
done

# Local overrides (machine-specific, not a module)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# Completion
autoload -Uz compinit && compinit

# Fish-like features (after compinit)
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Prompt
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Syntax highlighting (MUST be last)
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
