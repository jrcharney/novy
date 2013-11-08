#!/bin/bash
# File: novy_rc.sh
# Author: Jason Charney, BSCS
# Email: jrcharneyATgmailDOTcom
# Date:  7 Nov 2013
# Info:  Create a personal preference file called ".novyrc" if it does not exists.
# Software License: MIT LICENSE (free to use, free to share, free to alter, but acknowledge the original creator.)

usage(){
 echo "$0 does not use any arguments."

 cat << HELP
novy_rc.sh - create a personal preference file to use with novy programs

This program asks a few questions to create .newrc to store the preferences.
HELP
}

ask_yn(){
 # Note: this script will abort if a proper answer is not given after three tries.
 local question=$1
 local tries=0
 local ans=
 while : ; do
  read -p "$question (y or n) " ans
  case ${ans,,} in
   y|yes) break ;;
   n|no)
    echo "Script aborted."
    exit 1
    ;;
   *)
     ((tries++))
     if [[ $tries -lt 3 ]]; then
      echo "Invalid entry. Please try again."
     else
      echo "Invalid entry  after three tries. Aborting."
      exit 1
     fi
     ;;
  esac
 done
}

disclaimer(){
 local disdoc="DISCLAIMER.txt"
 if [[ -f $disdoc ]]; then
  # cat $disdoc
  sed -n '/^#/!p' $disdoc | less -eFMXR
 else
  echo "$0 ERROR: $disdoc, not found."
  exit 1
 fi
}

create_novyrc(){
 if [[ -f .novyrc ]]; then
  echo "It looks like .novyrc already exists."
  ask_yn "Would you like to replace it?"
  rm .novyrc
 fi

 cat << MSG

It looks like this is your first time running ${0}.
For this program to work, I need to set up a preference file
which will be stored in .novyrc and can be altered in a text editor
like vim.  I will need to ask ONLY FOUR questions.
This data will NOT be sent anywhere, but it will be used
to automatically write your data to any script you
want to create using Novy programs.

MSG

ask_yn "Would you like to continue?"

 disclaimer

 echo "With that said, we can begin creating .novyrc."
 ask_yn "Would you like to continue running this script?"
 echo ""

 while :; do
  cat << MSG

The first three questions will ask for your name as well as
any suffix (or major if you prefer) that will be used
to insert your name in any file you create with the new_ programs.
If parts of your name are multiple parts or has characters that
may conflict with this program (i.e. apostrophies), It would be wise
to encapsulate that part of your name in double quotes so that
the input is taken in as a string.

MSG

  local fn=
  local ln=
  local sn=
  local email=

  read -p "What is your first name? " fn
  read -p "What is your last name?  " ln
  name="$fn $ln"
  echo ""
  echo "For this next question, just press ENTER for no answer."
  read -p "Do you have a suffix or degree title you would like to add? " sn
  [[ -n $sn ]] && name+=", $sn"

  cat << MSG

For this next question, I will ask for your email address.
The email address will be altered replacing the '@' and '.'
characters for your security so that if you ever post your code
on the web or on a pastebin site, it won't be picked up by
spam programs that look for email addresses to spam.

MSG

  read -p "What is your email address? " email
  email=${email//@/AT}
  email=${email//./DOT}

  echo ""
  echo "Your name will be stored as '$name'."
  echo "Your email will be stored as '$email'."
  echo ""
 
  local tries=0
  local ans=
  local outer=

  while :; do
   read -p "Are you satisified with your responses? (y or n) " ans
   case ${ans,,} in
    y|yes) 
     echo "Great! Creating .novyrc should only take a split second."
     echo ""
     outer="yes"
     break ;;	# break out of the inner while loop
    n|no) 
     echo "I'll ask the questions again. So you can apply changes."
     echo ""
     outer="no"
     break ;;	# break out of the inner while loop
    *)
     ((tries++))
     if [[ $tries -lt 3 ]]; then
      echo "Invalid entry. Please try again."
     else
      echo "Invalid entry after three tries. Aborting."
      exit 1
      fi
      ;;
   esac
  done

  case $outer in
   yes) break ;;	# break out of the outer while loop
   no) ;;		# repeat the while loop
   *) echo "ERROR! You shouldn't be here! Aborting!"
      exit 1 ;;		# You shouldn't reach this case EVER!
  esac
 done 

 # Creating the file.
 cat > .novyrc << EOF
# File: .novyrc
# Info: This file stores personal preferences for Novy programs.
#	Unless you know what you are doing, don't make any changes to this file.
declare -A self		# This map holds your name and email
declare -A fecha	# This map holds date format. Fecha is spanish for "date"

self[name]="$name"
self[email]="$email"
fecha[string]="now"
fecha[format]="%e %b %Y"		# Use this for the date format. ('man date' for options)

EOF

 cat << MSG

That's it. There are a few other preferences that are part of .newrc
that effect how dates are generated in header information for the new_ programs.
Unless you delete .newrc, you will never be asked these questions again.

Have fun, and thank you for using my programs!

MSG
}

[[ $# -eq 0 ]] && create_novyrc || usage
