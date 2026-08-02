set fish_greeting
set OH_MY_POSH "$HOME/.config/oh-my-posh"
set FASTFETCH "$HOME/.config/fastfetch"

if test -r "$FASTFETCH/config.jsonc"
    fastfetch
end

if test -r "$OH_MY_POSH/doomslayer-info-util.omp.json"
    oh-my-posh init fish --config "$OH_MY_POSH/doomslayer-info-util.omp.json" | source
end
