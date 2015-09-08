#!/bin/bash

#get name param is set
NAME=$1

# Colors
#neutral
N=$(tput sgr0)
#red
R=$(tput setaf 1)
#green
G=$(tput setaf 2)
#yellow
Y=$(tput setaf 3)
#cyan
C=$(tput setaf 6)

#Current time
T=`date +%s`

#functions
askcontinue() {
  read -r -p "Continue (Y/N)? " answer;
  if [[ $answer = [Nn] ]]; then
    exit
  fi
}

createdb() {
  MYSQL=`which mysql`

  read -s -p "Please enter mysql root user password " pass; 
  Q1="CREATE DATABASE IF NOT EXISTS $1 CHARACTER SET utf8 COLLATE utf8_general_ci;"
  Q2="GRANT USAGE ON *.* TO $1@localhost IDENTIFIED BY '$1';"
  Q3="GRANT ALL PRIVILEGES ON $1.* TO $1@localhost;"
  Q4="FLUSH PRIVILEGES;"
  SQL="${Q1}${Q2}${Q3}${Q4}"

  $MYSQL -uroot -p"$pass" -e "$SQL"
  if [ $? != "0" ];
  then
    printf "%s\n" $R"FAILED"$N
    askcontinue
  else
    printf "%s\n" $G"Database created!"$N
  fi
}

# Check project name.
if [ -z "${NAME}" ]; then
  read -p $R"Please enter project/folder name: "$N
  if [ $REPLY != "" ]; then
      NAME=$REPLY
  fi
fi

WWWDIR="/var/www/" 

read -e -p $C"Change sites location dir if neede: "$N -i "${WWWDIR}" WWW
if [ $WWW != $WWWDIR ]; then
  if [ -d $WWW ]; then
    WWWDIR="${WWW}"
  else
      printf "%30s\n" $R"Location is not exist, fallback to : ${WWWDIR}"$N
      askcontinue
  fi
  
  printf "%30s\n" $Y"Location dir set to: ${WWWDIR}"$N
fi

dest="${WWWDIR}${NAME}"
#make destintion
mkdir -p $dest
printf "%s\n" $G"Folder \"${dest}\" created."$N

printf "%s\n" $G"Creating apache2 config... "$N
cp default.conf /etc/apache2/sites-available/${NAME}.conf

cd /etc/apache2/sites-available/

#replace $NAME by entered name
sed -i -e "s|\$NAME|$NAME|g" ${NAME}.conf
sed -i -e "s|\$WWWDIR|$WWWDIR|g" ${NAME}.conf

#sylmink
cd ../sites-enabled/
if [ ! -L "${NAME}.conf" ]; then
  ln -s /etc/apache2/sites-available/$NAME.conf $NAME.conf
  printf "%30s\n" $C"New sylmink created"$N
else
  printf "%30s\n" $Y"Sylmink alredy set"$N
fi
printf "%s\n" $G"Done"$N

# set hosts
printf "%s\n" $G"Setting host..."$N
if ! grep -Fxq "127.0.0.1        ${NAME}.local" /etc/hosts 
then
  printf "%30s\n" $C"New Host created"$N
  echo -e "127.0.0.1        ${NAME}.local" >> /etc/hosts
else
  printf "%30s\n" $Y"Host alredy set"$N
fi
printf "%s\n" $G"Done"$N

printf "%s\n" $G"Restarting apache..."$N
#service apache2 restart
printf "%s\n" $G"Done"$N

read -e -p $R"Want to create a database (y/n): "$N -i "y" DB
if [ $DB == "y" ]; then
  printf "%s\n" $G"This will create a empty database [${NAME}] with user: ${NAME} and password: ${NAME}"$N
  askcontinue
  createdb $NAME
fi

read -e -p $R"Want to create the site with drush? (y/n): "$N -i "y" DRUSH
if [ $DRUSH == "y" ]; then
  printf "%s\n" $G"Checking directory for profile... "$N
  if [ -d "${dest}/profiles/projects" ]; then
    printf "%s\n" $G"Profile exist"$N
  else
    printf "%s\n" $C"Profile not exist"$N
    read -p $R"Please specify a git repo with profile: "$N GIT
    if ! git clone $GIT "${dest}/profiles/project"
    then
      printf "%s\n" $R"FAILED"$N
    else
      printf "%s\n" $G"Profile created!"$N
    fi
  fi
fi
# summary output
echo $Y"Summary time, [$(((`date +%s`-$T)))] sec"$N
