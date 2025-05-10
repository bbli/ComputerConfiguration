# ************** FUNCTIONS ************** %%%1
function cop
    nvim ~/copy.txt
end
function par
    cd ~/.cache/LogParser
end
function explain
    gh copilot explain $argv[1]
end

function tr
    triage build $argv[1] artifacts --fetch
end

function chk -d "Checkout local git branch, sorted by recent"
    git branch -vv | read -z branches
    set branch (echo "$branches" | fzf +m)
    git checkout (echo "$branch" | awk '{print $1}' | sed "s/.* //")
end
# Assumes you have already created a new tmux window which opens in the same directory as the previous pane
# Also if no number given -> just chekout as regular worktree [DONE]

# BENSON: remember to check out locally first ->> so don't create "nested" directories
function create_worktree #-a name number
    if test (count $argv) = 2
        set -l branch_name $argv[1]
        set -l number $argv[2]

        and cd (git rev-parse --git-dir)/..
        and git worktree add ../$branch_name HEAD
        and cd ../$branch_name
        and gh pr checkout $number
        and tmux rename-window (string join "" "[pr_" $branch_name "]")
    else if test (count $argv) = 1
        set -l branch_name $argv[1]

        and cd (git rev-parse --git-dir)/..
        and git worktree add ../$branch_name $branch_name
        and cd ../$branch_name
        and tmux rename-window $branch_name

    else
        print "First argument is branch name. Second(optional) is the pull request number"
    end
end

# BENSON: has to be manually since (git rev-parse --git-dir)/.. will just go to original repo
function delete_worktree
    # 1. first cd to proj root
    cd (git rev-parse --git-dir)/..
    git worktree remove .
    # 2. now exit the tmux window
    # tmux kill-window
end
# ************** COMMAND ALIASES ************** %%%1
function j
    z $argv
end

function rm
    env rm -i $argv
end

function df
    env df -h $argv
end

function du
    env du -h $argv
end

function nv
    nvim $argv
end

function vi
    vim $argv
end

function psf
    procs --tree | fzf
end

function ptree
    procs --tree
end

function rdb
    cgdb -d rust-gdb
end

function pac
    sudo pacman -S $argv
end

function yao
    yaourt -S $argv
end
function ff
    fg
end

function attach
    tmux a -t $argv
end

# ************** EXA ************** %%%1
function ls
    exa --icons $argv
end

function ll
    exa --icons --header --long -H -m $argv
end

function tree
    exa --icons --tree $argv
end

# ************** PYTHON VIRTUAL ENV ************** %%%1
function act
    source activate $argv
end

function deact
    source deactivate $argv
end

function py
    python3 $argv
end

# ************** DIRECTORIES ************** %%%1
function cop
    nvim ~/copy.txt
end

function code
    cd ~/Dropbox/Code
end

function dot
    cd ~/Dropbox/Code/dotfiles
end

function org
    cd ~/Dropbox/Org
end

function proj
    cd (git rev-parse --show-toplevel)
end

function snip
    cd ~/.vim/my-snippets/UltiSnips
end

function pack
    cd ~/.local/share/nvim/site/pack/packer/start
end
# ************** VARIABLES ************** %%%1
# set SPACEFISH_PROMPT_ADD_NEWLINE false
# set SPACEFISH_PROMPT_SEPARATE_LINE true
# set SPACEFISH_DIR_COLOR cyan
# set SPACEFISH_PACKAGE_SHOW false
# set SPACEFISH_RUST_SHOW false
# set SPACEFISH_GOLANG_SHOW false

set -U fish_user_paths ~/Scripts/ ~/.local/bin /opt/homebrew/bin ~/.cargo/bin ~/.fzf/bin ~/.config/emacs/bin ~/.emacs.d/bin ~/perl5/bin ~/.gem/ruby/3.0.0/bin ~/Software/comma-community-2022.01.0/bin ~/Software/cmake-3.26.3-linux-x86_64/bin ~/LogParser/target/debug
# ************** SOURCE ************** %%%1
switch (uname)
    case Linux
        if [ -f '/opt/miniconda3/etc/fish/conf.d/conda.fish' ]
            source /opt/miniconda3/etc/fish/conf.d/conda.fish
        end
    case Darwin
    case '*'
end

# The next line updates PATH for the Google Cloud SDK.
if [ -f '~/Software/cloud-sdk-stuff/google-cloud-sdk/path.fish.inc' ]
    . '~/Software/cloud-sdk-stuff/google-cloud-sdk/path.fish.inc'
end
# Make Ctrl-T see hidden files too(since my dotfiles repo will have a lot of hidden files)
set -gx FZF_CTRL_T_COMMAND "rg --hidden --glob '!.git' -l ''"

# ************** PERL STUFF ************** %%%1
set -x PERL5LIB ~/perl5/lib/perl5
set -x PERL_LOCAL_LIB_ROOT ~/perl5
set -x PERL_MB_OPT --install_base\ \"~/perl5\"
set -x PERL_MM_OPT INSTALL_BASE=~/perl5

# ************** PLUGIN CONFIGURATION ************** %%%1
# FOr some reason git_status is being ignored
# fzf_configure_bindings --git_status=\cg
# fzf_configure_bindings --directory=\ct
set fish_greeting
starship init fish | source
source ~/.tokens.fish
