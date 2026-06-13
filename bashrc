#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '
#things needed (most come with your distro but some require you to install via whatever method you prefer/can): curl, jq, mpv, yt-dlp, streamlink, reddittui, toot, trans, sed, awk, tr, grep, wc, fmt, ncurses
#my shit, i added below-
#usage: seach 5 example videos
#used to search youtube via tty
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
#used for watching youtube via mpv from tty
youtube() {
    if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
        echo "Usage: youtube [video_id]"
        return 0
    fi
    mpv --ytdl-format="bestvideo[height<=720]+bestaudio/best" "https://www.youtube.com/watch?v=$1"
}
#wiki maybe
#usage: wiki kernel
#another example: wiki united states of america
wiki() {
    if [ -z "$1" ]; then
        echo "Usage: wiki [search term]"
        return 1
    fi
    local search_query=$(echo "$@" | sed 's/ /%20/g')
    local search_list=$(curl -s "https://en.wikipedia.org/w/api.php?action=opensearch&format=json&search=${search_query}&limit=5" | jq -r '.[1][]')
    if [ -z "$search_list" ]; then
        echo "No results found for '$*'"
        return 1
    fi
    local total_lines=$(echo "$search_list" | wc -l)
    local selection=""
    #menu
    if [ "$total_lines" -eq 1 ]; then
        selection="$search_list"
    else
        echo "Select an article:"
        local i=1
        while IFS= read -r line; do
            echo -e "  \e[32m[$i]\e[0m $line"
            local option_$i="$line"
            i=$((i + 1))
        done <<< "$search_list"
        echo ""
        local choice
        read -r -p "Enter number (or press Enter to cancel): " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -lt "$i" ] && [ "$choice" -gt 0 ]; then
            local var_name="option_$choice"
            selection="${!var_name}"
        else
            return 0
        fi
    fi
    # Fetching nonesense
    if [ -n "$selection" ]; then
        local final_query=$(echo "$selection" | sed 's/ /%20/g')
        local response=$(curl -s "https://en.wikipedia.org/w/api.php?action=query&prop=extracts&exintro=1&explaintext=1&titles=${final_query}&redirects=1&format=json")
        local extract=$(echo "$response" | jq -r '.query.pages | to_entries[0].value.extract // empty')
        echo -e "\n\e[1;34m=== $selection ===\e[0m\n"
        if [ -n "$extract" ]; then
            echo "$extract" | fmt -w $(tput cols)
        else
            echo "Could not retrieve summary for $selection."
        fi
        echo ""
    fi
}
#used for watching twitch via mpv
#usage: twitch ohnepixel
twitch() {
    if [[ "$1" == "--help" || "$1" == "-h" || -z "$1" ]]; then
        echo "Usage: twitch [streamer_name]"
        return 0
    fi
    streamlink --player mpv "twitch.tv/$1" 720p60
}
# usage: islive xqc ohnepixel caseoh_
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
#used for getting youtube video information. ytinfo xyzabc. mostly useless due to affiliate links
ytinfo() {
    if [[ -z "$1" ]]; then
        echo "Usage: ytinfo [video_id/url]"
        return 0
    fi
    yt-dlp --get-title --get-duration --get-description "https://www.youtube.com/watch?v=$1"
}
#reddit, used to load reddittui with the subreddit flag. Customize/edit the subreddits to your liking
reddit() {
    if [ -z "$1" ]; then
        reddittui --subreddit archlinux+linuxquestions+masterhacker+linuxmint+learnpython+linuxmemes+computerhelp+linux4noobs+HowToHack+Piracy+computerviruses+LinuxCirclejerk+desktops+cachyos+pchelp+youtubedl+Hacking_Tutorials+Craptopgamingadvice+pcmasterrace+linux+TrueAnon
    else
        reddittui --subreddit "$1"
    fi
}
#used to download image from reddit
redditdl() {
    # USAGE: redditdl url (must be an actual image file, not a preview or video or whatever other nonsense reddit tries to display)
    if [ -z "$1" ]; then
        echo "Usage: redditdl <URL>"
        return 1
    fi

    local filename=$(basename "$1")

    echo "Downloading $filename..."

    #Download w curl
    curl -sL "$1" -o "$filename"

    echo "Done! Saved as $filename"
}
#used specifically to translate posts from mastedon social, requires the post idea which I get from post details within toot tui, the tui for mastedon social i personally use
translatesocial() {
    if [ -z "$1" ]; then
        echo "Usage: translatesocial <post-id>"
        return 1
    fi
    toot status "$1" | trans :en -b
}
#shitty google command my bad yall
googler() {
    #wiki is better than this in my experience, but i will keep messing with it
    local query=$(echo "$@" | tr ' ' '+')
    
    curl -sL -A "Mozilla/5.0" "https://duckduckgo.com/lite/?q=${query}" | \
    grep -A 1 "result-snippet" | \
    sed 's/<[^>]*>//g; s/&#x27;/'\''/g; s/&quot;/"/g; s/&amp;/\&/g' | \
    sed '/^--$/d' | \
    awk '{$1=$1}1' | \
    fmt -w $(tput cols)
}
#for toot tui media viewer, obv
export TOOT_TUI_MEDIA_VIEWER="mpv --vo=drm"
#mainly useless if you are here from my video. i was just launching into DE's to try them. Do not worry about this nonsense. I apologize if you had to see this ridiculous cornucopia of DEs
alias xfce='startx ~/.xinitrc xfce4'
alias cinnamon='startx ~/.xinitrc cinnamon'
alias gnome='export XDG_SESSION_TYPE=wayland; export XDG_CURRENT_DESKTOP=GNOME; dbus-run-session gnome-shell --display-server --wayland'
alias kde='startplasma-wayland'
alias mate='startx ~/.xinitrc mate'
alias lxqt='startx ~/.xinitrc lxqt'
alias budgie='startx /usr/bin/budgie-desktop'
alias enlightenment='startx ~/.xinitrc e17'
