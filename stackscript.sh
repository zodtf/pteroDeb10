#!/bin/bash
# let's begin. I want some color!
# by zudsniper@github

# ANSI COLOR ENVIRONMENT VARS
export A_RESTORE='\033[0m'
export A_RESET='\033[0m'

export A_BOLD='\033[1m'
export A_UNDERLINE='\033[4m'
export A_INVERSE='\033[7m'
export A_ITALIC='\033[3m'  #not always supported...

export A_RED='\033[00;31m'
export A_GREEN='\033[00;32m'
export A_YELLOW='\033[00;33m'
export A_BLUE='\033[00;34m'
export A_PURPLE='\033[00;35m'
export A_CYAN='\033[00;36m'
export A_LIGHTGRAY='\033[00;37m'

export A_LRED='\033[01;31m'
export A_LGREEN='\033[01;32m'
export A_LYELLOW='\033[01;33m'
export A_LBLUE='\033[01;34m'
export A_LPURPLE='\033[01;35m'
export A_LCYAN='\033[01;36m'
export A_WHITE='\033[01;37m'
# end ANSI COLOR CODES

function start () {
  sudo npm run preInstall-labels && pm2 save;
  sudo npm run installAptPkgs && pm2 save;
#  sp="/-\|";
#  echo -n ' ';
#  for i in 1; do  # left as a silly loop in case we expand
#    (
#
#    ) &
#  done
}

# prefunctions for compilation order
function updateProgress () {
    #this provides an illusion of hardworking.
    sleep 10;
}

# start spinner & installation threads

function installAptPkgs () {
      appts=0;

      #sudo su root; # be root
      sudo apt install -yg vim; appts++;
      sudo apt install -yg nginx; appts++;
      sudo apt intall -yg shadowsocks; appts++;
      sudo apt install -yg openSSL; appts++;
      sudo apt install -yg certbot; appts++;
      sudo apt install -yg letsencrypt; appts++;
      sudo apt install -yg net-tools; appts++;
      sudo apt install -yg cpanel; appts++;

      sudo apt install -yg javascript; appts++;
      sudo apt install -yg nodejs@16.17.1; appts++;
      sudo apt install -yg typescript; appts++;
      sudo npm install dotenv -g; appts++;
      sudo npm install dontenv-cli -g; appts++;

      sudo apt install postgresql -g; appts++;

      sudo apt install gh; appts++;
      sudo apt install git; appts++;

      # check if gh signed in
      STATUS="cmd $(gh auth status 2>&1)";
      echo -ne "STATUS: ${STATUS}\n\n\n";
      # shellcheck disable=SC2002
      if [[ $(echo -ne "${STATUS}" | grep 'Logged in') -ne 1 ]]; then
        echo -ne "${A_RED}${A_BOLD}gh cli is not logged in. Run ${A_RESET}${A_INVERSE}gh auth login${A_RESET}${A_RED}${A_BOLD} and try again. ${A_RESET}\n";
        exit 1;
      else
        echo -ne "${A_BLUE}${A_UNDERLINE}Time to log in to your GitHub honey${A_RESET}\n";
        sudo gh login auth;
      fi
      ## next step time, return number of total 1st level installs
      export INSTALLATIONS_PERFORMED="${appts}";
      return;
}




#this function will print a pretty summary spring to stdin,
function preInstall-labels () {
# expose environment variables if they can be set
export NGINX_PATH=$("${process.env.NGINX_PATH}" || /usr/sbin/nginx);

# build / install begins

echo -ne "${A_LCYAN}${A_BOLD}build stf-deb-base.${A_RESET}\n";
echo -ne "${A_INVERSE}Operating System${A_RESET}: Debian 11\n";
echo -ne "${A_BOLD}NETWORK${A_RESET}: \n";
echo -ne "  NGiNX@latest\n"
echo -ne "  shadowsocks@latest\n";
echo -ne "  openSSL@latest\n";
echo -ne "  cerbot@latest\n";
echo -ne "  letsencrypt@latest\n";
echo -ne "  openSSH@latest\n";
echo -ne "  sshd@latest\n";
echo -ne "  net-tools@latest\n";
echo -ne "  cpanel@latest\n";
echo -ne "  ${A_RED}${A_BOLD}[X] fail2ban@latest NOT INSTALLED${A_RESET} by default.\n\n";

echo -ne "${A_BOLD}GENERAL${A_RESET}: \n";
echo -ne "  JavaScript@latest\n";
echo -ne "  NodeJS@16.x...\n";
echo -ne "  TypeScript@latest\n";
echo -ne "  dotenv@latest, dotenv-cli@latest\n\n";
echo -ne "  ";

echo -ne "${A_BOLD}DATABASE${A_RESET} \n";
echo -ne "  PostgreSQL@latest\n\n";

echo -ne "${A_BOLD}DEPLOYMENT${A_RESET} \n";
echo -ne "  gh_cli@latest\n";
echo -ne "  git@latest\n\n";
}