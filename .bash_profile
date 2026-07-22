
### aliases
alias ls='ls --color=tty'
alias ll='ls -Fltrh'
alias la='ls -aFd .*'
alias Head='head'
alias Less='less'
alias pgrep='grep -P'
alias ssh='ssh -Y'
alias gits='git fetch && git status -uno'

#############################
# add_dir - add a directory to any of the directory requiring shell variables
# eg. $MANPATH $PERL5LIB $LD_LIBRARY_PATH
# usage add_dir variablename [ first ] <path>
# optional 'first' option adds to the beginning of the list,
#   otherwise it gets added to the end.
##############################
function add_dir {
    if [ "X$1" = "X" ] ; then
        echo "Usage: add_dir <variablename> [ first ] <path>"
        return 1
    else
        local var=$1
        shift
    fi

    if [ "X$1" = "Xfirst" ] ; then
        local pathcmd="$2:${!var}"
        local pathadd=$2
    else
        local pathcmd="${!var}:$1"
        local pathadd=$1
    fi
    if echo ${!var} | perl -pe 's/:/\n/g' | grep "^$pathadd$" > /dev/null; then
        > /dev/null
    else
        if [ -d $pathadd ]; then
            if [ "X${!var}" = "X" ] ; then  # just set the var if var is empty
                eval "$var=\"$pathadd\""
            else
                eval "$var=\"$pathcmd\""
                export $var
            fi
        else
            echo "could not add '$pathadd' to \$$var because it was not found"
        fi
    fi
} ### add_dir

##############################
# add_path - add a directory to the path if it isn't already there
# usage: add_path [ first ] <path>
# optional 'first' option adds to the beginning of the list,
#   otherwise it gets added to the end.
##############################
function add_path {
    add_dir PATH $@
}            

##############################
# tabjoin - print tab-delimited data
# usage: tabjoin [--] <arg1> <arg2> <arg3>
# -n does not print newline at end
##############################
tabjoin() {
    if [ $# -eq 0 ] && [ -t 0 ]; then
        printf '\ntabjoin - joins arguments with tab characters and prints the result\nfollowed by a carriage return\nUsage: tabjoin [--] <arg1> <arg2> <arg3>\nPrints: <arg1>\\t<arg2>\\t<arg3>\\n\n\nuse -n to suppress trailing \\n\nuse -- to suppress option handling for any parameters after that\n'
        return 1
    fi

    local term=$'\n'
    local got_doubledash=0
    local args=()

    for arg in "$@"; do
        if [ $got_doubledash -eq 0 ] && [ "$arg" = "-n" ]; then
            term=""
            continue
        elif [ $got_doubledash -eq 0 ] && [ "$arg" = "--" ]; then
            got_doubledash=1
            continue
        fi
        args+=("$arg")
    done

    local IFS=$'\t'
    printf "%s%s" "${args[*]}" "$term"
}


### environment variables
# history
export HISTFILESIZE=100000
export HISTSIZE=100000
export HISTIGNORE="&:ls:ll:[bf]g:q[srw]"
export HISTTIMEFORMAT="%d/%m/%y %T "

# editor
export VISUAL=vim

# R
R_HISTSIZE=32768  # make history file big

# path
add_path first "$HOME/bin"
add_path "$HOME/.iterm2"

# HOST is used below (may be altered below)
HOST=$HOSTNAME

### prompt
if [ -n "$PROMPT_COLOR" ]
then
    export PROMPT_COLOR='0;0m'
fi

if [ -n "$PS1" ]
then
    PROMPT_COMMAND='
    TRIMMED_PWD=${PWD: -42};
    TRIMMED_PWD=${TRIMMED_PWD:-$PWD} '";$PROMPT_COMMAND"

    PS1='\! \
${HOST}\
:$TRIMMED_PWD> '
    if [ -e ~/.iterm2_shell_integration.`basename $SHELL` ]
    then
        source ~/.iterm2_shell_integration.`basename $SHELL`
    fi
fi

# for z.sh directory navigation aid
source $HOME/bin/z.sh
add_dir MANPATH ~/man

# for my standard perl modules
add_dir PERL5LIB $HOME/lib/perl5
