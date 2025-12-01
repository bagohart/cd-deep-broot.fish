function cd_deep_broot --description 'cd into any deep directory, falling back to invoking broot if no or multiple matches are found'
    argparse --exclusive 'D,d,f,F' --name=cd_deep_broot\
            'H/hidden' 'I/ignored' 'max-depth=' 'min-depth=' 'D/show-dirs-only' 'd/search-dirs-only' 'f/search-files-and-dirs' 'F/search-files-only' -- $argv
    or return

    # 1. set options for fd and broot
    set --local fd_options
    set --local broot_options

    if test -n "$_flag_F"
        set --append fd_options --type f
    else if test -n "$_flag_f"
        set --append fd_options --type f --type d
    else if test -n "$_flag_D"
        set --append fd_options --type d
        set --append broot_options "--only-folders"
    else # -d is the default
        set --append fd_options --type d
    end

    # Confusingly, the (short-form!) flags for fd and broot are incompatible and (partly!) contradictory m(
    if test -n "$_flag_hidden"
        # include hidden directories
        set --append fd_options "--hidden"
        set --append broot_options "--hidden"
    else
        # omit hidden directories
        set --append fd_options "--no-hidden"
        set --append broot_options "--no-hidden"
    end

    if test -n "$_flag_ignored"
        # include ignored directories (git and whatever else fd ignores)
        set --append fd_options "--no-ignore"
        set --append broot_options "--git-ignored"
    else
        # omit ignored directories (git and whatever else fd ignores)
        # rely on the default for fd, there is no explicit option to set this
        set --append broot_options "--no-git-ignored"
    end

    if test -n "$_flag_max_depth"
        set --append fd_options --max-depth $_flag_max_depth
    end

    if test -n "$_flag_min_depth"
        set --append fd_options --min-depth $_flag_min_depth
    end

    # echo "Run:" # printf debugging
    # echo fd $fd_options -- $argv[1] # printf debugging

    # 2. Find possible paths
    set paths $(fd $fd_options -- $argv[1])

    # remove filenames from paths
    for i in $(seq $(count $paths))
        if test -f "$paths[$i]"
            set paths[$i] $(path dirname $paths[$i])
        end
    end

    # Remove duplicates and the current directory, they can show up here if -f or -F is set
    set paths $(string join \n $paths | path normalize | sort --unique | string match --invert --regex '^\.$')

    # echo "final paths: #= $(count $paths) : $paths" # printf debugging

    # 3. cd or invoke broot
    switch $(count $paths)
        case 1
            cd -- $paths[1]
        case '*'
            br $broot_options --cmd $argv[1]
    end
end
