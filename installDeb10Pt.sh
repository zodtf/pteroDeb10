#!/bin/bash

# zod.tf pterodactyl installation script
# based on https://pterodactyl.io/community/installation-guides/panel/debian10.html
# - debian 10
# - zodsuper's [`.bashrc` for Debian](https://gist.github.com/zudsniper/e5bbdb7d3384a2b5f76277b52d103e59)

# FLAGS 
# 	[source](https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash)

POSITIONAL_ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    -y|--Yes)
      SKIP_PROMPTS_YES="Y"
      shift # past argument
      ;;
    -n|--No)
      SKIN_PROMPTS_NO="n"
      shift # past argument
      ;;
    -P|--root_password)
      ROOT_PASSWORD="$2"
      shift # past argument
      shift # past value!
      ;;
      -D|--domains_file)
      DOMAINS_FILE="$2"
      shift # past argument
      shift # past value!
      ;;
      -m|--panel)
      PANEL_DOMAIN="$2"
      shift # past argument
      shift # past value!
      ;;
      -r|--redis)
      USE_REDIS=1
      shift # past argument
      ;;
    -*|--*)
      echo -ne "${A_RED}Unknown option${A_RESET} $1\n";
      exit 1
      ;;
    *)
      POSITIONAL_ARGS+=("$1") # save positional arg
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL_ARGS[@]}" # restore positional parameters

echo -ne "${A_GREEN}${A_BOLD}let's get this show on the road.${A_RESET}\n";
echo -ne "${A_WHITE}INSTALLING PTERODACTYL PANEL FOR DEBIAN 10${A_RESET}\n\n";

ecjo -ne "${A_BOLD}${A_GREEN}Flags${A_RESET}\n";
if [[ SKIP_PROMPTS_YES -ne "Y" ]]; then
	echo -ne "${A_BOLD}${A_WHITE}	SKIP WITH ${A_RESET}${A_GREEN}YES!${A_RESET}\n"; 	
fi

if [[ SKIP_PROMPTS_NO -ne "n" ]]; then
	echo -ne "${A_BOLD}${A_WHITE}	SKIP WITH ${A_RESET}${A_RED}no.${A_RESET}\n"; 	
	#if [[ SKIP_PROMPTS_YES -eq "Y" ]]; then
	#	echo -ne "${A_BOLD}${A_RED}	Cannot have -Y & -n flag.${A_RESET}\n"; 	
	#	exit 1;
	#fi
fi

if [[ -z $(sudo) ]]; then
	apt install sudo
fi

# genuinely don't know at this point 
export PT_NUMSTEPS=6;

echo -ne "\n";

# MariaDB

echo -ne "${A_YELLOW}${A_BOLD}Maria${A_BLACK}${A_INVERSE}DB${A_RESET}...\n";

apt install -y software-properties-common curl apt-transport-https ca-certificates

## Get apt updates
apt update

## Install MariaDB
apt install -y mariadb-common mariadb-server mariadb-client

## Start mariadb
systemctl start mariadb
systemctl enable mariadb

echo -ne "${A_INVERSE}------------------------------------------------${A_RESET}...\n";

# PHP 8.1 

echo -ne "${A_PURPLE}${A_BOLD}PHP 8.1${A_RESET}...\n";

# Add repository for PHP
curl https://packages.sury.org/php/apt.gpg -o /etc/apt/trusted.gpg.d/php.gpg
echo "deb https://packages.sury.org/php/ buster main" | tee /etc/apt/sources.list.d/php.list

## Get apt updates
apt update

## Install PHP 8.1
apt install -y php8.1 php8.1-{cli,common,gd,mysql,mbstring,bcmath,xml,fpm,curl,zip}

echo -ne "${A_INVERSE}------------------------------------------------${A_RESET}...\n";

# NGiNX

echo -ne "${A_GRAY}${A_BOLD}NGiNX${A_RESET}...\n";

apt install -y nginx

echo -ne "${A_INVERSE}------------------------------------------------${A_RESET}...\n";

# Redis

echo -ne "${A_RED}REDIS${A_RESET}...\n";

apt install -y redis-server

systemctl start redis-server
systemctl enable redis-server

ehco -ne "${A_INVERSE}------------------------------------------------${A_RESET}...\n";


if   [ -z ${SKIP_PROMPTS_YES}  ] &&  [ -z ${SKIP_PROMPTS_NO} ] ; then
	echo -ne "Install certbot? (Y/n) \n";
	select ctbt in Yes No 
	do
		if [[ $ctbt -eq "Y" ]]; then
			PKG_OK=$(dpkg-query -W -f='${Status}' curl 2>/dev/null | grep -c "ok installed")
			if [[ $PKG_OK -eq 0 ]]; then
			  apt install curl;
			fi
			apt install -y certbot
			if [ "$ctbt" != "" ]
              then
                  break
              fi
		else
		  if [ "$ctbt" != "" ]
              then
                  break
              fi
		fi
	done

	echo -ne "\nInstall composer? (Y/n) ";
	select compo in Yes No 
	do
		if [[ $compo -eq "Y" ]]; then
			curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
		fi
		if [ "$compo" != "" ]
            then
                break
            fi
	done
elif [[  SKIP_PROMPTS_YES -eq "Y" ]]; then
	apt install -y certbot curl
	curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
fi

echo -ne "${A_BLUE}${BOLD}STATUS ${A_RESET}(1/${PT_NUMSTEPS})...\n";
echo -ne "${A_INVERSE}${A_BLUE}------------------------------------------------${A_RESET}\n\n";

echo -ne "${A_RED}${A_BOLD}MANUAL FOR AWHILE${A_RESET}\n";

# Set root password? [Y/n] Y
# Remove anonymous users? [Y/n] Y
# Disallow root login remotely? [Y/n] Y
# Remove test database and access to it? [Y/n] Y
# Reload privilege tables now? [Y/n] Y

if [[ ${SKIP_PROMPTS_YES} -eq "Y" ]]; then
	yes | mysql_secure_installation
else
	mysql_secure_installation
fi

echo -ne "${A_INVERSE}------------------------------------------------${A_RESET}...\n";
echo -ne "${A_YELLOW}Adding users${A_RESET}...\n ${A_ITALIC}this will REQUIRE your root password!${A_RESET}\n";

echo -ne "${A_RED}${A_BOLD}PRETTY SURE THE AUTOMATION IS BROKEN, FINISH MANUALLY! ${A_RESET}\n";
echo -ne "${A_BOLD}https://pterodactyl.io/tutorials/mysql_setup.html${A_RESET}";

select stopRN in Yes No
	do
		if [[ ${stopRN} -eq "Y" ]]; then
			echo -ne "${A_BOLD}${A_RED}${A_INVERSE}QUITTING now :C${A_RESET}\ngo to that link, and finish those stes manually! \n";
			exit 1; 
		fi
		if [ "$stopRN" != "" ]
            then
                break
            fi
	done 

 EOF > "./temp"; # rest file

## Remember to change 'somePassword' below to be a unique password specific to this account.
printf "CREATE USER 'pterodactyl'@'127.0.0.1' IDENTIFIED BY 'pogPassword'\n" >> ./temp 

printf "CREATE DATABASE panel\n"  >> ./temp 

printf "GRANT ALL PRIVILEGES ON panel.* TO 'pterodactyl'@'127.0.0.1' WITH GRANT OPTION\n" >> ./temp 

# You should change the username and password below to something unique.
printf  "CREATE USER 'pterodactyluser'@'127.0.0.1' IDENTIFIED BY 'pogpassword'\n"  >> ./temp 

printf "GRANT ALL PRIVILEGES ON *.* TO 'pterodactyluser'@'127.0.0.1' WITH GRANT OPTION\n" >> ./temp  


#TODO: this requires root password!
#		also its just super weird...
mysql -u root -p < ./temp


#cat './temp' | mysql -u root -p ${ROOT_PASSWORD}

# ALLOW EXTERNAL ACCESS

# get the first result
{ read CFG_FIRST; } < "$(find /etc -iname my.cnf)"

# write external stuff to this file
echo -ne "\n\n[mysqld]\n\nbind-address = 0.0.0.0\n" > "${CFG_FIRST}"

# restart
systemctl restart mariadb

echo -ne "${A_BLUE}${BOLD}STATUS ${A_RESET}(2/${PT_NUMSTEPS})...\n";
echo -ne "${A_INVERSE}${A_BLUE}------------------------------------------------${A_RESET}\n\n";
echo -ne "Setting up ${A_PURPLE}${A_BOLD}PHP 8.1${A_RESET}...\n";

systemctl enable php8.1_fpm
systemctl start php8.1-fpm


# assuming we use `ufw`
echo -ne "   ${A_GRAY}${A_ITALIC}opening port 80 for http challenge!${A_RESET}\n";

if which ufw >/dev/null; then
	sudo apt update
	sudo apt install -y ufw
fi

ufw allow 80/tcp
ufw reload

systemctl restart ufw
systemctl restart nginx


# generate our SSL certificates!
echo -ne "   ${A_GRAY}${A_ITALIC}adding ca-certificates!${A_RESET}\n";

if which certbot >/dev/null; then
	sudo apt update
	sudo apt install -y certbot
fi

DOMAINS=""
if [[ -z ${DOMAINS_FILE} ]]; then
	while IFS="" read -r p || [ -n "$p" ]
	do
	  DOMAINS="$(printf '-d %s %s' "$p" "${DOMAINS}")";
	done < DOMAINS_FILE
else
	DOMAINS="-d zod.tf -d www.zod.tf -d panel.zod.tf -d www.panel.zod.tf -d mge.zod.tf -d trade.boo.tf -d boo.tf -d zod.mge.tf"
fi

# https://pterodactyl.io/tutorials/creating_ssl_certificates.html

echo -ne "   Trying to renew ${A_YELLOW}${A_BOLD}ca-certificates${A_RESET}...\n";
echo -ne "   AUTORENEWAL with crontab: ${A_ITALIC}https://pterodactyl.io/tutorials/creating_ssl_certificates.html${A_RESET}...\n";

certbot certonly --nginx --expand "${DOMAINS}";

# SSL certificates (hopefully) done! 
echo -ne "${A_BLUE}${BOLD}STATUS ${A_RESET}(3/${PT_NUMSTEPS})...\n";
echo -ne "${A_INVERSE}${A_BLUE}------------------------------------------------${A_RESET}\n\n";

# add SSL servers to NGiNX config
touch /etc/nginx/conf.d/ssl.conf;

# get my gist of the conf file
curl https://gist.githubusercontent.com/zudsniper/863d01f8c4b45b8556e7e3dea3aa707b/raw/97aca8dda4826e02ac4af496a60d5c8db6e40001/ssl.conf -o /etc/nginx/conf.d/ssl.conf;

# move the file to name it correctly
mv "/etc/nginx/conf.d/ssl.conf" "/etc/nginx/conf.d/${PANEL_DOMAIN}.conf"

# replace the instances of "<domain>" in file with the appropriate panel domain.
sed -i -e "`s/\<domain\>/${PANEL_DOMAIN}/g`" "/etc/nginx/conf.d/${PANEL_DOMAIN}.txt"



# this is truly a guess
chmod 644 /etc/nginx/conf.d/ssl.conf;

# SSL certificates (hopefully) done! 
echo -ne "${A_BLUE}${BOLD}STATUS ${A_RESET}(4/${PT_NUMSTEPS})...\n";
echo -ne "${A_INVERSE}${A_BLUE}------------------------------------------------${A_RESET}\n\n";
echo -ne "${A_GREEN}${A_BOLD}INSTALLING PANEL. MADE IT THIS FAR!${A_RESET}\n";

# making panel dirs
mkdir -p /var/www/pterodactyl
cd /var/www/pterodactyl || (echo -ne "${A_RED}${A_BOLD}How did you do this? /var/www/pterodactyl doesn't exist, RIGHT after creation.{A_RESET}\n"; exit 1)

# downloading, uncompressing, and setting permissions
curl -Lo panel.tar.gz https://github.com/pterodactyl/panel/releases/latest/download/panel.tar.gz
tar -xzvf panel.tar.gz
chmod -R 755 storage/* bootstrap/cache/

# copy env settings + other stuff, use artisan to generate first part of panel
cp .env.example .env
cp .env .env.backup
composer install --no-dev --optimize-autoloader

# Only run the command below if you are installing this Panel for
# the first time and do not have any Pterodactyl Panel data in the database.
php artisan key:generate --force

# CONFIGURE ENVIRONMENT


php artisan p:environment:setup
php artisan p:environment:database

# To use PHP's internal mail sending (not recommended), select "mail". To use a
# custom SMTP server, select "smtp".
php artisan p:environment:mail

# database setup
php artisan migrate --seed --force

# add the first user
php artisan p:user:make

# run ownership command for this OS
# If using NGINX or Apache (not on CentOS):
chown -R www-data:www-data /var/www/pterodactyl/*


echo -ne "${A_BLUE}${BOLD}STATUS ${A_RESET}(5/${PT_NUMSTEPS})...\n";
echo -ne "${A_INVERSE}${A_BLUE}------------------------------------------------${A_RESET}\n\n";
echo -ne "${A_PURPLE}setting QueueWorker crontab job${A_RESET}...\n";

# write crontab via bash script

crontab -l > mycron

echo "* * * * * php /var/www/pterodactyl/artisan schedule:run >> /dev/null 2>&1" >> mycron

crontab mycron
rm mycron

# create queue worker service within systemd

curl https://gist.githubusercontent.com/zudsniper/863d01f8c4b45b8556e7e3dea3aa707b/raw/988256e6b8db2c64307ff6660e6345f96d0a0162/pteroq.service -o /etc/systemd/system/pteroq.service

# if we are to use Redis, make sure it starts on boot. 
if [[ -z ${USE_REDIS} ]]; then
	systemctl enale --now redis-server
fi

# enable our service
systemctl enable --now pteroq.service

echo -ne "${A_BLUE}${BOLD}STATUS ${A_RESET}(6/${PT_NUMSTEPS})...\n";
echo -ne "${A_INVERSE}${A_BLUE}------------------------------------------------${A_RESET}\n\n";
echo -ne "${A_GREEN}${A_BOLD}INSTALLING WEBSERVER CONFIGURATION${A_RESET}...\n";


# remove default NGiNX
rm /etc/nginx/sites-enabled/default

# enable the current conf 
ln -s /etc/nginx/sites-available/pterodactyl.conf /etc/nginx/sites-enabled/pterodactyl.conf

# You need to restart nginx regardless of OS.
systemctl restart nginx

echo -ne "${A_BLUE}${A_BOLD}STATUS ${A_RESET}(7/${PT_NUMSTEPS})...\n";
echo -ne "${A_INVERSE}${A_BLUE}------------------------------------------------${A_RESET}\n\n";
echo -ne "${A_GREEN}${A_BOLD}${A_INVERSE}PTERODACTYL BASE IS INSTALLED!!${A_RESET}\n\n";


echo -ne "${A_YELLOW}Installing Dependencies${A_RESET}...\n";

# install docker but not apt???
curl -sSL https://get.docker.com/ | CHANNEL=stable bash

# enable dcoker
systemctl enable --now docker

# check for swap
echo -ne "${A_RED}I hope we support swapping:@1${A_RESET}...\nif the following includes ${A_INVERSE}WARNING: No swap limit support${A_RESET}\n";

docker info;

echo -ne "${A_BOLD}${A_RED}Continue on & install Wings?${A_RESET} (y/N) ";
# unskippable
select stopNow in Yes No 
	do
		if [[ $stopNow -ne "Y" ]]; then
			echo -ne "${A_RED}${A_BOLD}go fix ur swap! C:${A_RESET}\n";
			exit 1; 
		fi

		if [ "$stopNow" != "" ]
                then
                    break
                fi
	done

echo -ne "${A_YELLOW}${A_BOLD}Good luck!${A_RESET}\n";

# get part 2 ... fuck man
curl https://gist.githubusercontent.com/zudsniper/863d01f8c4b45b8556e7e3dea3aa707b/raw/36b64071e5be01fd778e44cbe0fe656e05efa6f5/installDeb10Pt_wings.sh | bash;


