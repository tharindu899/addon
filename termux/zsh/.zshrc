ZSH_THEME="xiong-chiamiov-plus"

export ZSH=$HOME/.oh-my-zsh

plugins=(git)

source $ZSH/oh-my-zsh.sh



# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
source ~/../usr/etc/.plugin/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/../usr/etc/.plugin/zsh-autosuggestions/zsh-autosuggestions.zsh
alias a='apt install'
alias g='git clone'
alias t='termux-open'
alias ai='apt install'
alias py='python'
alias py2='python2'
alias py3='python3'
alias g='git clone'
alias t='termux-open'
alias m='micro'
#alias ls='lsd -F -A'
alias ls='logo-ls -A'
alias r='termux-reload-settings'
alias storage='termux-setup-storage'
alias repo='termux-change-repo'
alias pi='pkg install'
alias pup='pkg update'
alias pug='pkg upgrate'
alias aup='apt update'
alias apg='apt upvarde'
alias c='cd ..'
alias etc='cd /data/data/com.termux/files/usr/etc'
alias n='nano'
alias g='git clone'
alias p='pip install'
alias d='rm -rf'
alias ex ='unzip'
alias f='mkdir'
alias z='m ~/.zshrc'
alias cdd='/data/data/com.termux/files/home/storage/downloads'
alias ax='acodeX-server'
alias rr='source ~/.zshrc'
