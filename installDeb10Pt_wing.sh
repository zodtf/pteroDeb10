#!/bin/bash

# I would NOT run this without running the first script...

echo -ne "------------------------------------------------${A_RESET}\n";
echo -ne "              ${A_GRAY}${A_BOLD}INSTALLING WINGS${A_RESET}\n";
echo -ne "------------------------------------------------${A_RESET}\n\n";

echo -ne "${A_BOLD}VISIT: ${A_RESET}https://pterodactyl.io/wings/1.0/installing.html#installing-wings-2\n";

# prepare for wings
mkdir -p /etc/pterodactyl
curl -L -o /usr/local/bin/wings "https://github.com/pterodactyl/wings/releases/latest/download/wings_linux_$([[ "$(uname -m)" == "x86_64" ]] && echo "amd64" || echo "arm64")"
chmod u+x /usr/local/bin/wings

# install wings daemon
curl https://gist.github.com/zudsniper/863d01f8c4b45b8556e7e3dea3aa707b#file-wings-service -o /etc/systemd/system/wings.service

# enable this new service on boot
systemctl enable --now wings

echo -ne "------------------------------------------------${A_RESET}\n";
echo -ne "              ${A_GREEN}${A_BOLD}HOLY FUCK${A_RESET}\n";
echo -ne "          ${A_GREEN}${A_BOLD}YOU MADE IT! ${A_RESET}\n";
echo -ne "                ${A_GREEN}He's... He's alive!!!${A_RESET}\n";
echo -ne "------------------------------------------------${A_RESET}\n\n";