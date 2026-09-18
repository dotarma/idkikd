set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
fish_add_path ~/.local/bin
fish_add_path ~/.cargo/bin
fish_add_path ~/go/bin

function fish_greeting
end

function fish_prompt
    set -l last_status $status

    # Colors
    set -l c_reset  (set_color normal)
    set -l c_border (set_color brblack)
    set -l c_user   (set_color cyan)
    set -l c_host   (set_color brblue)
    set -l c_path   (set_color yellow)
    set -l c_git    (set_color green)
    set -l c_err    (set_color red)

    # User and host
    set -l host (string trim (hostname -s 2>/dev/null; or echo $hostname; or echo "localhost"))
    set -l user_str $c_user$USER$c_reset$c_border@$c_reset$c_host$host$c_reset

    # Shorten path
    set -l dir (string replace -r "^$HOME" "~" $PWD)

    # Git branch
    set -l git_str ""
    if command -sq git
        set -l branch (git branch --show-current 2>/dev/null)
        if test -n "$branch"
            set git_str $c_border"--["$c_reset$c_git$branch$c_reset$c_border"]"$c_reset
        end
    end

    # Status indicator (only on error)
    set -l status_str ""
    if test $last_status -ne 0
        set status_str $c_border"--["$c_reset$c_err$last_status$c_reset$c_border"]"$c_reset
    end

    # Top line
    echo -ns $c_border"+-["$c_reset $user_str $c_border"]--["$c_reset $c_path$dir$c_reset $c_border"]"$c_reset
    if test -n "$git_str"
        echo -ns $git_str
    end
    if test -n "$status_str"
        echo -ns $status_str
    end
    echo -s $c_border"-+"$c_reset

    # Bottom prompt
    echo -ns $c_border"+->"$c_reset " "
end

function fish_right_prompt
    set_color brblack
    date "+%H:%M:%S"
    set_color normal
end

alias ls    "ls --color=auto"
alias ll    "ls -lh --color=auto"
alias la    "ls -lAh --color=auto"
alias ..    "cd .."
alias ...   "cd ../.."
alias grep  "grep --color=auto"
alias mkdir "mkdir -p"
alias cp    "cp -iv"
alias mv    "mv -iv"
alias rm    "rm -iv"

# Git shortcuts
alias g  "git"
alias ga "git add"
alias gc "git commit"
alias gp "git push"
alias gs "git status"
alias gl "git log --oneline --graph --decorate"

# Ctrl+F: accept autosuggestion word-by-word
bind \cf forward-word

if command -sq fzf
    set -gx FZF_DEFAULT_OPTS "--height 40% --layout=reverse --border=sharp"
end

if command -sq zoxide
    zoxide init fish | source
end

if command -sq direnv
    direnv hook fish | source
end
