# cd-deep-broot.fish
A fish plugin to cd deep into any directory, invoking broot as a fallback

## Elevator pitch: Yet another alternative cd command?
Tons of alternative cd commands exist, such as z (or its clones), various implementations of bookmarks, fzf, broot and many others.
But in the following use case, I found all of them to be unsuitable:\
Assume that you are in some directory `~/project/` and you want to cd into a directory `foo_things` which is somewhere below the current directory.

* Shell globs, i.e. `cd **/*foo*` are annoying to type and fail if the directory isn't unique
* bookmarks are useless if this isn't a directory you want to bookmark.
* `z` is useless if you haven't visited this directory before. Without additional options, `z foo` may also jump to any other matching location outside of `~/project/`.
* `fzf` works fine, but its view of the filesystem isn't terribly helpful. Also, invoking fzf without an initial search string will flood you with irrelevant matches, which can be irritating.
* `broot` works great, but invoking it introduces a context switch that is overkill if the search string `foo` is sufficient to uniquely identify that directory.

This plugin aims to solve this particular use case. Just type 
```
cd_deep_broot foo
```
to `cd` into `foo_things` if it is a unique match with `foo` below `~/project/`.
Otherwise (in the case of several or no matches), it invokes broot prepopulated with the search string `foo` to give you an overview of the filesystem and let you choose the directory manually.

Additionally, instead of the directory name you can use a filename if it's unique. For example, starting from `~`
```
cd_deep_broot -F config.fish
```
will cd directly into `~/.config/fish`, unless there is another `config.fish` file below `~`.
For more details on search modes, see Configuration/Options below.

## Requirements
Uses [fd](https://github.com/sharkdp/fd) to search the directory and [broot](https://dystroy.org/broot/) (actually its shell function `br`) as a fallback.\
Also uses the `cd` function (not the cd builtin) to not break navigation `prevd` and `nextd`.

## Installation
### Using fisher:
```
fisher install bagohart/cd-deep-broot.fish
```

### Manually:
Copy the file `cd_deep_broot.fish` into `$XDG_CONFIG_HOME/fish/functions/` (probably `~/.config/fish/functions`).

## Configuration/Options
`cd_deep_broot` is an intentionally long name to prevent clashes with other plugins. Add a line to your `fish.config` file to alias it, and optionally add some arguments, for example:
```
alias cdd 'cd_deep_broot --min-depth=2 --hidden'
```
`cd_deep_broot` accepts a number of options most of which are passed to both `fd` and `broot`.
(Note that options for `broot` and `fd` are partly incompatible, so they are translated internally.)

### `H/hidden`
Include hidden directories (and files) in the search.

### `I/ignored`
Include (fd/git-ignored) directories (and files) in the search.

### `max-depth`, `min-depth`
Limit the min and max depth of the search (only passed to `fd`).

### Different search modes: `D/show-dirs-only`, `d/search-dirs-only`, `f/search-files-and-dirs`, `F/search-files-only`
Choose exactly one of those (default `d/search-dirs-only`):
* `D`: Search only for directories, show only directories in broot
* `d`: Search only for directories, show both directories and files in broot
* `f`: Search for both directories and files, show both directories and files in broot
* `F`: Search only for files, show both directories and files in broot

## Related
If you want to cd up instead of down, check out [cd-upwards.fish](https://github.com/bagohart/cd-upwards.fish).
