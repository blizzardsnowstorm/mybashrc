#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

#my shit, i added below-
#usage: seach 5 example videos
search() {
    if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
        echo "Usage: search [count] [query]"
        echo "Example: search 5 arch linux tutorials"
        return 0
    fi

    count=$1
    shift
    query="$*"
    yt-dlp "ytsearch$count:$query" --get-id --get-title
}
#used for watching youtube mpv
youtube() {
    if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
        echo "Usage: youtube [video_id]"
        return 0
    fi
    mpv --ytdl-format="bestvideo[height<=720]+bestaudio/best" "https://www.youtube.com/watch?v=$1"
}
#used for watching twitch via mpv
twitch() {
    if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
        echo "Usage: twitch [streamer_name]"
        return 0
    fi
    streamlink --player mpv "twitch.tv/$1" 720p60
}
# usage: islive xqc
islive() {
    if [[ "$1" == "--help" || "$1" == "-h" ]]; then
        echo "Usage: islive [streamer1] [streamer2] ..."
        return 0
    fi

    for streamer in "$@"; do
        # We try to get the stream URL. If it returns text, they are live.
        # --stream-url is faster and more reliable for status checks.
        if streamlink --twitch-disable-ads "twitch.tv/$streamer" best --stream-url >/dev/null 2>&1; then
            echo -e "\e[32m●\e[0m $streamer is live"
        else
            echo -e "\e[31m○\e[0m $streamer is offline"
        fi
    done
}
#used for getting youtube video information. ytinfo xyzabc
ytinfo() {
    if [[ -z "$1" ]]; then
        echo "Usage: ytinfo [video_id/url]"
        return 0
    fi
    yt-dlp --get-title --get-duration --get-description "https://www.youtube.com/watch?v=$1"
}
reddit() {
    if [ -z "$1" ]; then
        reddittui --subreddit archlinux+linuxquestions+masterhacker+linuxmint+learnpython+BlizzardOfLInux+linuxmemes+computerhelp+linux4noobs+HowToHack+Piracy+computerviruses+LinuxCirclejerk+desktops+cachyos+pchelp+youtubedl+Hacking_Tutorials+Craptopgamingadvice+pcmasterrace+linux+TrueAnon
    else
        reddittui --subreddit "$1"
    fi
}

redditdl() {
    # USAGE: redditdl url.png (must be an actual image file, not a preview or video or whatever other nonsense reddit tries to display)
    if [ -z "$1" ]; then
        echo "Usage: redditdl <URL>"
        return 1
    fi

    local filename=$(basename "$1")

    echo "Downloading $filename..."

    # 3. Download (Silent mode, follow redirects)
    curl -sL "$1" -o "$filename"

    echo "Done! Saved as $filename"
}
translatesocial() {
    if [ -z "$1" ]; then
        echo "Usage: translatesocial <post-id>"
        return 1
    fi
    toot status "$1" | trans :en -b
}

googler() {
    # Replace spaces with + for the URL
    local query=$(echo "$@" | tr ' ' '+')
    
    curl -sL -A "Mozilla/5.0" "https://duckduckgo.com/lite/?q=${query}" | \
    grep -A 1 "result-snippet" | \
    sed 's/<[^>]*>//g; s/&#x27;/'\''/g; s/&quot;/"/g; s/&amp;/\&/g' | \
    sed '/^--$/d' | \
    awk '{$1=$1}1' | \
    fmt -w $(tput cols)
}

export TOOT_TUI_MEDIA_VIEWER="mpv --vo=drm"

alias xfce='startx ~/.xinitrc xfce4'
alias cinnamon='startx ~/.xinitrc cinnamon'
alias gnome='export XDG_SESSION_TYPE=wayland; export XDG_CURRENT_DESKTOP=GNOME; dbus-run-session gnome-shell --display-server --wayland'
alias kde='startplasma-wayland'
alias mate='startx ~/.xinitrc mate'
alias lxqt='startx ~/.xinitrc lxqt'
alias budgie='startx /usr/bin/budgie-desktop'
alias enlightenment='startx ~/.xinitrc e17'
