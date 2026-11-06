# ************** FUNCTIONS ************** %%%1
function cop
    nvim ~/copy.txt
end

function nv
    nvim $argv
end

function par
    cd ~/.cache/LogParser
end
function explain
    gh copilot explain $argv[1]
end

function triage
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
function create_worktree #-a name
    if test (count $argv) != 1
        echo "usage: create_worktree <branch_name>"
        return 1
    end

    set -l branch_name $argv[1]
    set -l repo_root (git rev-parse --show-toplevel); or return
    if git show-ref --verify --quiet refs/heads/$branch_name
        git worktree add (dirname $repo_root)/$branch_name $branch_name
    else
        git worktree add -b $branch_name (dirname $repo_root)/$branch_name
    end
    and cd (dirname $repo_root)/$branch_name
    and mkdir -p .pi
    and ln -s /home/ir/ir-beli/.pi/learnings .pi/learnings
    and git branch -f start_$branch_name
    and tmux rename-window $branch_name
end


function delete_worktree
    argparse f/force -- $argv; or return

    if test (count $argv) != 1
        echo "usage: delete_worktree [-f|--force] <branch_to_merge_into>"
        return 1
    end

    set -l target $argv[1]
    set -l branch_name (git branch --show-current); or return
    set -l wt_root (git rev-parse --show-toplevel); or return
    set -l main_root (dirname (git rev-parse --path-format=absolute --git-common-dir)); or return

    # --- sanity checks ---------------------------------------------------------
    if test "$wt_root" = "$main_root"
        echo "delete_worktree: not inside a linked worktree"
        return 1
    end
    if test -z "$branch_name"
        echo "delete_worktree: detached HEAD, can't determine branch"
        return 1
    end
    if test "$target" = "$branch_name"
        echo "delete_worktree: can't merge $branch_name into itself"
        return 1
    end
    if not git show-ref --verify --quiet refs/heads/$target
        echo "delete_worktree: branch '$target' does not exist"
        return 1
    end

    # Current worktree must be clean (ignoring the .pi/learnings symlink),
    # unless --force was given
    set -l dirty (git status --porcelain --untracked-files=all | string match -v -- '?? .pi/learnings')
    if test -n "$dirty"
        if set -q _flag_force
            echo "delete_worktree: --force given, discarding uncommitted changes in $wt_root:"
            printf '  %s\n' $dirty
        else
            echo "delete_worktree: uncommitted changes in $wt_root (use --force to discard):"
            printf '  %s\n' $dirty
            return 1
        end
    end

    # --- find where $target is checked out (git won't merge into it elsewhere) -
    set -l target_wt
    set -l cur_wt
    for line in (git worktree list --porcelain)
        if string match -q 'worktree *' -- $line
            set cur_wt (string replace 'worktree ' '' -- $line)
        else if test "$line" = "branch refs/heads/$target"
            set target_wt $cur_wt
            break
        end
    end
    if test -z "$target_wt"
        echo "delete_worktree: '$target' isn't checked out in any worktree; check it out somewhere first"
        return 1
    end

    # --- merge -----------------------------------------------------------------
    if not git -C $target_wt merge --no-edit $branch_name
        echo "delete_worktree: merge failed, aborting merge in $target_wt"
        git -C $target_wt merge --abort 2>/dev/null
        return 1
    end
    if not git merge-base --is-ancestor $branch_name $target
        echo "delete_worktree: $branch_name doesn't appear merged into $target, stopping"
        return 1
    end

    # --- tear down -------------------------------------------------------------
    test -L $wt_root/.pi/learnings; and rm $wt_root/.pi/learnings
    rmdir $wt_root/.pi 2>/dev/null

    cd $main_root; or return
    if set -q _flag_force
        git worktree remove --force $wt_root; or return
    else
        git worktree remove $wt_root; or return
    end

    # -D is safe here: we just verified $branch_name is an ancestor of $target
    git branch -D $branch_name
    git show-ref --verify --quiet refs/heads/start_$branch_name
    and git branch -D start_$branch_name

    tmux kill-window
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

# function code
#     cd ~/Dropbox/Code
# end

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

set -U fish_user_paths ~/go/bin ~/Scripts/ ~/.local/bin /opt/homebrew/bin ~/.cargo/bin ~/.fzf/bin ~/.config/emacs/bin ~/.emacs.d/bin ~/perl5/bin ~/.gem/ruby/3.0.0/bin ~/LogParser/target/debug
set -x ARC_API_KEY 179385bb-4d81-4e8a-8679-e9c2fef01e93
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
set -gx RUST_BACKTRACE 1

# ************** PLUGIN CONFIGURATION ************** %%%1
# FOr some reason git_status is being ignored
# fzf_configure_bindings --git_status=\cg
# fzf_configure_bindings --directory=\ct
set fish_greeting
starship init fish | source
source ~/.tokens.fish

# pnpm
set -gx PNPM_HOME /Users/beli/Library/pnpm
if not string match -q -- $PNPM_HOME $PATH
    set -gx PATH "$PNPM_HOME" $PATH
end
# pnpm end

# ************** Garuda New Additions ************** %%%1
## Set values
# Hide welcome message & ensure we are reporting fish as shell
set fish_greeting
set VIRTUAL_ENV_DISABLE_PROMPT 1
set -x SHELL /usr/bin/fish

# Use bat for man pages
set -xU MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -xU MANROFFOPT -c

## Export variable need for qt-theme
if type qtile >>/dev/null 2>&1
    set -x QT_QPA_PLATFORMTHEME qt5ct
end

## Environment setup
# Apply .profile: use this to put fish compatible .profile stuff in
if test -f ~/.fish_profile
    source ~/.fish_profile
end

## Starship prompt
if status --is-interactive
    source (starship init fish --print-full-init | psub)
end

# Set settings for https://github.com/franciscolourenco/done
set -U __done_min_cmd_duration 10000
set -U __done_notification_urgency_level low

function __history_previous_command_arguments
    switch (commandline -t)
        case "!"
            commandline -t ""
            commandline -f history-token-search-backward
        case "*"
            commandline -i '$'
    end
end

if [ "$fish_key_bindings" = fish_vi_key_bindings ]

    bind -Minsert ! __history_previous_command
    bind -Minsert '$' __history_previous_command_arguments
else
    bind ! __history_previous_command
    bind '$' __history_previous_command_arguments
end

function cleanup
    while pacman -Qdtq
        sudo pacman -R (pacman -Qdtq)
        if test "$status" -eq 1
            break
        end
    end
end

# opencode
fish_add_path /home/bensonli/.opencode/bin

function mp --description "local pi for development"
    lite pi $argv
end
set -gx LITELLM_PROXY_URL https://gpulab.purestorage.com
set -gx CLAUDE_CODE_ENABLE_GATEWAY_MODEL_DISCOVERY 1
set -gx PI_CODING_AGENT_DIR /home/ir/Software/pi/.pi

# ************** PI WORKSPACE ************** %%%1
function hp -d "Spawn pi in a new Herdr tab via hc, attach inside the current terminal"
    if test "$HERDR_ENV" != 1
        echo "pi_workspace: not inside Herdr (HERDR_ENV != 1)" >&2
        return 1
    end

    # Resolve target directory from cwd
    set target_dir (realpath -- $PWD)

    if not test -d "$target_dir"
        echo "pi_workspace: not a directory: $target_dir" >&2
        return 1
    end

    # Derive a sanitised agent name: pi-<dirname>[-<label>], max 32 chars, [a-z0-9_-]
    set ws_label (basename "$target_dir")
    set _name_input "pi-$ws_label"
    if set -q argv[1]
        set _name_input "$_name_input-$argv[1]"
    end
    set agent_name (echo "$_name_input" \
        | tr '[:upper:]' '[:lower:]' \
        | tr -cs 'a-z0-9_-' '-' \
        | string trim --chars='-' \
        | string sub --length 32)

    # ── Idempotency ──────────────────────────────────────────────────────────
    # If a live hc terminal with this name already exists, just reattach.
    set _existing (hc ls --json | python3 -c "
import sys, json
name = '$agent_name'
for t in json.load(sys.stdin)['terminals']:
    if t.get('name') == name and t['state'] == 'live':
        print('found')
        break
" 2>/dev/null)

    if test "$_existing" = found
        echo "pi_workspace: reattaching to existing session '$agent_name'…"
        hc attach "$agent_name"
        return
    end

    # ── Create ───────────────────────────────────────────────────────────────
    # Snapshot all pane IDs before so we can spot the new one after.
    set _before (herdr api snapshot 2>/dev/null | python3 -c "
import sys, json
panes = json.load(sys.stdin)['result']['snapshot'].get('panes', [])
print(' '.join(p['pane_id'] for p in panes))" 2>/dev/null)

    echo "pi_workspace: starting '$agent_name' in $target_dir…"

    # Start pi as an independent, named hc terminal (no-parent keeps it alive
    # if neovim or this shell exits).
    hc run --bg --name "$agent_name" --cwd "$target_dir" --no-parent pi
    if test $status -ne 0
        echo "pi_workspace: hc run failed" >&2
        return 1
    end

    # ── Organise into a Herdr tab ─────────────────────────────────────────────
    # Give Herdr a moment to pick up the new hc terminal as a pane.
    sleep 1

    set _after (herdr api snapshot 2>/dev/null | python3 -c "
import sys, json
panes = json.load(sys.stdin)['result']['snapshot'].get('panes', [])
print(' '.join(p['pane_id'] for p in panes))" 2>/dev/null)

    set _new_pane (python3 -c "
before = set('$_before'.split())
after  = set('$_after'.split())
new = after - before
print(next(iter(new), ''))" 2>/dev/null)

    if test -n "$_new_pane"
        herdr pane move "$_new_pane" --new-tab --label "$ws_label" --no-focus 2>/dev/null
        and echo "pi_workspace: moved pane $_new_pane into new tab '$ws_label'"
        or echo "pi_workspace: note: pane move failed — session is still accessible via hc"
    else
        echo "pi_workspace: note: no new Herdr pane detected — session is still accessible via hc"
    end

    # ── Attach ───────────────────────────────────────────────────────────────
    echo "pi_workspace: attaching (ctrl+\\ to detach)…"
    hc attach "$agent_name"
end
>>>>>>> Stashed changes
