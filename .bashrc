# Custom aliases (commands)
alias ls='ls -A --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias realpath='realpath -e'
alias sublime='/opt/sublime_text/sublime_text'
alias t='ifconfig | grep tun0 -A 1 | tail -1 | tr -s " " | cut -d " " -f 3'
alias venv2='source ~/venv2/bin/activate' # virtual environment python2
alias venv3='source ~/venv3/bin/activate' # virtual environment python3
alias venv2_new='virtualenv -p python2 venv2; source venv2/bin/activate' # fresh virtual environment python2
alias venv3_new='virtualenv -p python3 venv3; source venv3/bin/activate' # fresh virtual environment python3
function getip() { grep -P " $1$" /etc/hosts | cut -d " " -f 1; } # Usage: getip <hostname>
function gob() { # Example usage: gob box1 80
    cmd="gobuster dir -u http://$1:$2 -w ~/web/urls.txt -o $1:$2.gobuster"
    echo $cmd; eval $cmd
}
function nik() { # Example usage: nik box1 80
    cmd="nikto -host $1:$2 -output $1:$2.nikto -Format txt"
    echo $cmd; eval $cmd
}
function ff() { # Example usage: ff box1 80
    cmd="ffuf -w ~/web/urls.txt -u http://$1:$2/FUZZ 2>&1 | tee $1:$2.ffuf"
    echo $cmd; eval $cmd
}
function uscan() { # Example usage: uscan box1 80
    cmd="sudo uniscan -u $1:$2 -qweds; firefox /usr/share/uniscan/report/$1.html"
    echo $cmd; eval $cmd
}

# Custom aliases (cd)
alias nse='cd /usr/share/nmap/scripts'
alias sec='/usr/share/seclists'
alias msf='/usr/share/metasploit-framework/modules'
alias box100='cd /home/kali/boxes/exam2/box100'
alias box101='cd /home/kali/boxes/exam2/box101'
alias box102='cd /home/kali/boxes/exam2/box102'
alias box110='cd /home/kali/boxes/exam2/box110'
alias box111='cd /home/kali/boxes/exam2/box111'
alias box112='cd /home/kali/boxes/exam2/box112'
alias lp1='cd /home/kali/boxes/pwk/lp1'
alias lp2='cd /home/kali/boxes/pwk/lp2'
alias lp3='cd /home/kali/boxes/pwk/lp3'
alias lp4='cd /home/kali/boxes/pwk/lp4'
alias lp5='cd /home/kali/boxes/pwk/lp5'
alias lp6='cd /home/kali/boxes/pwk/lp6'
alias lp7='cd /home/kali/boxes/pwk/lp7'
alias lp8='cd /home/kali/boxes/pwk/lp8'
alias lp9='cd /home/kali/boxes/pwk/lp9'
alias lp10='cd /home/kali/boxes/pwk/lp10'
alias lp11='cd /home/kali/boxes/pwk/lp11'
alias compromised='cd /home/kali/boxes/compromised'
alias photographer='cd /home/kali/boxes/photographer'
alias graph='cd /home/kali/boxes/graph'
alias wheels='cd /home/kali/boxes/wheels'
alias fanatastic='cd /home/kali/boxes/fanatastic'

# Custom alias (record everything)
# Note: This one must be at the END of the .bashrc file.
mkdir -p ~/script; [[ -z $(ps -ef | grep $PPID | grep script) ]] && script ~/script/$(date +%F-%T)
