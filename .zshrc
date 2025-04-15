export KUBECONFIG=$HOME/.kube/config
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
# ZSH_THEME="af-magic"
# ZSH_THEME="headline"
# ZSH_THEME="amuse"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
export NVM_LAZY_LOAD=true
export NVM_COMPLETION=true
plugins=(evalcache git mvn docker kubectl helm jenv nvm npm zsh-autosuggestions ohmyzsh-full-autoupdate)
source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

export GITHUB_USERNAME=rob-64
export XDG_CONFIG_HOME="$HOME/.config"
export EDITOR=vi

toggleJavaAutoBuild() {
  settingsFile="$(pwd)/.vscode/settings.json"
  if [ ! -f "$settingsFile" ]; then
    settingsFile="$(pwd)/../.vscode/settings.json"
  fi
  if [ -f "$settingsFile" ]; then
    if grep -q "java.autobuild.enabled" "$settingsFile"; then
      sed -i "s/\"java.autobuild.enabled.*/\"java.autobuild.enabled\": $1,/" $settingsFile
    else
      sed -i "1 a     \"java.autobuild.enabled\": $1," $settingsFile
    fi
  fi
}

__mci() {
  toggleJavaAutoBuild false
  echo "$MAVEN_ARGS mvn clean install $@"
  sleep 2
  mvn clean install $@
  toggleJavaAutoBuild true
}

mci() {
  __mci -Dmaven.gitcommitid.nativegit=true $@
}

mcip() {
  mci -P build-image -P build-image-no-auth -P gaia -P production $@
}

maven-get-sources-and-docs() {
  mvn dependency:sources -T10 &
  mvn dependency:resolve -T10 -Dclassifier=javadoc &
  wait
}

maven-dep-tree(){
  mvn dependency:tree -Dverbose=true $@
}

maven-check-updates(){
  mvn versions:display-dependency-updates $@
}

alias ll="eza --icons --group-directories-first  --time-style long-iso"
alias ls="ll"
alias _ls="/usr/bin/ls"
alias tp="telepresence"

dockerHubPull(){
  input="$1"
  prefix="docker.io/"
  imageName="${input#$prefix}"
  if [[ $1 != proxy-docker-hub.gaia.gccsj.nn.c2fse.northgrum.com* ]]; then
    echo "pulling $imageName via gaia"
    docker pull proxy-docker-hub.gaia.gccsj.nn.c2fse.northgrum.com/$imageName
    echo "re-tagging $1"
    docker tag proxy-docker-hub.gaia.gccsj.nn.c2fse.northgrum.com/$imageName $1
  else
    docker pull $1
  fi
}

alias dhp="dockerHubPull"

dockerRmAll(){
  docker rm $(docker ps -a -q)
}

dockerVolumeRmAll(){
  docker volume rm $(docker volume ls -q)
}

dockerStopAll(){
  docker stop $(docker ps -a -q)
}

dockerVolumeRmAll(){
  docker volume rm $(docker volume ls -q)
}

delPod(){
  kubectl get pods -oname | grep $1 | xargs kubectl delete
}

delPvc(){
  kubectl get persistentvolumeclaims -oname | grep $1 | xargs kubectl delete
}

listPvc(){
  kubectl get persistentvolumeclaims -oname | grep $1
}

scaleDep(){
  kubectl get deployments -oname | grep $1  | xargs kubectl scale deployment --replicas 0
}

alias del-pod='delPod'
alias del-pvc='delPvc'

alias docker-volume-rm-all='dockerVolumeRmAll'
alias docker-stop-all='dockerStopAll'
alias docker-rm-all='dockerRmAll'
alias k9s_install="curl -sS https://webi.sh/k9s | sh"
alias k9s_full="/home/rob/.local/bin/k9s"
alias k9s="/home/rob/.local/bin/k9s --headless"

function cheatSheet() { curl -m 7 "http://cheat.sh/$1"; }
alias man="cheatSheet"

alias ctop="docker run --rm -ti --name=ctop --volume /var/run/docker.sock:/var/run/docker.sock:ro quay.io/vektorlab/ctop:latest"
alias glances="docker run --rm -e TZ="${TZ}" -v /var/run/docker.sock:/var/run/docker.sock:ro -v /run/user/1000/podman/podman.sock:/run/user/1000/podman/podman.sock:ro --pid host --network host -it nicolargo/glances:latest-full"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH="$HOME/.jenv/bin:$PATH"
# eval "$(jenv init -)"
_evalcache jenv init -

export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

PATH=~/.console-ninja/.bin:$PATH

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh


function run-dive() {
 docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock proxy-docker-hub.gaia.gccsj.nn.c2fse.northgrum.com/wagoodman/dive:latest $@ 
}

alias dive="run-dive"