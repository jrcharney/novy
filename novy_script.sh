#!/bin/bash
# File: novy_script.sh
# Date:  8 Nov 2013
# Name: Jason Charney, BSCS
# Email: jrcharneyATgmailDOTcom
# Info:  Automatically generate files for several types fo files.

# Fetch personal preferences from .novyrc
# If .novyrc does not exists, run novy_rc.sh first.
[[ ! -f .novyrc ]] && bash novy_rc.sh
source .novyrc

usage(){
 local helpdoc="novy_help_script.txt"
 if [[ -f $helpdoc ]]; then
  # cat $helpdoc
  sed -n '/^#/!p' $helpdoc | less -eFMXR
  exit 0
 else
  echo "$0 ERROR: $helpdoc, not found."
  exit 1
 fi
}

[[ $# -eq 0 ]] && usage

docopts= # "-cs h"		# The list of options that will be passed to novy_doc.sh
declare -A file		# File path map
file_map(){
 # file_map SHOULD fill in the necessary values for the file map.
 # NOTE: All information about the file itself is now in its own map.
 # Note: If the file does not begin with a capital letter, this program will rename it such that it does.
 if [[ -z $1 ]]; then
  echo "$0 ERROR: no file name given."
  echo "Aborting."
  exit 1
 fi
 file[full]=${1}
 file[ext]=${file[full]##*.}									# File extension
 case ${file[ext],,} in
  sh|rb|pl|py) docopts+=" -cs h" ;;
  ps) docopts+=" -cs p" ;;
  *)
    echo "$0 ERROR: Invalid file type ${file[ext]}"
    echo "Aborting."
    exit 1  
    ;;
 esac
 file[path]=${file[full]%/*}									# File path.  If not path, returns the string as it is.
 file[name]=${file[full]##*/}									# File name. Strip out the path
 [[ ${file[path]} == ${file[name]} ]] && file[path]=""						# This should help prevent directory creation later.
 # file[name]=${file[name]^}									# Capitalize the file name
 [[ -n ${file[path]} ]] && file[full]=${file[path]}/${file[name]} || file[full]=${file[name]}	# Avoid leading file names with no paths with '/'
 # file[class]=${file[name]%.java}                                                             	# Class name. Strip out the extension
 # file[class]=${file[class]^}                                               			# Capitalize the class name (customary in Java)
 docopts=" -fn ${file[full]} ${docopts}"
}

while [[ $# -gt 0 ]]; do
 case $1 in
  --help|-h) usage ;;	# Using thsi will end the program
  --file|--file-name|-f|-fn) shift; file_map "$1" ;;
  # --template|-t)	# No templates...yet. (There could be for Ruby in the near future.)
  #  shift;
  --file-version|--file-date|--file-author|--file-author-email|--file-website|--file-requirements|--file-info|--book-title|--book-author|--book-publisher|--book-publisher-location|--book-edition|--book-year|--book-isbn|--book-website|--book-website-accessed|--book-figure|--book-page|-fv|-fd|-fa|-fae|-fw|-fr|"-fi"|-bt|-ba|-bp|-bpl|-be|-by|-bi|-bw|-bwa|-bfn|-bfp)
   local dk=$1
   # local dv=
   shift
   if [[ -n $1 ]]; then
    local dv=$1
   else
    echo "$0 ERROR: $dk needs a value to be used for documentation."
    echo "Aborting."
    exit 1 
   fi
   docopts+=" $k $v"	# TODO: Hopefully quoted $v values will be honored when they are passed to novy_doc.sh, otherwise escape them in.
   ;;

  --noself|--nodate|--nofile|--nobook) docopts+=" $1" ;;
  *) 
    echo "$0 ERROR: Invalid Option or File Argument: $1"
    echo "Aborting."
    exit 1 
 esac
 shift
done

case ${file[ext],,} in
 sh)     docopts+=" -f1 #!/bin/bash" ;;		# Bash
 rb)     docopts+=" -f1 #!/usr/bin/ruby" ;;	# Ruby
 pl)     docopts+=" -f1 #!/usr/bin/perl" ;;	# Perl
 ps)     docopts+=" -f1 %!PS" ;;		# PostScript
 py)     docopts+=" -f1 #!/usr/bin/python" ;;	# Python
 *)
    echo "$0 ERROR: Invalid file type."
    echo "Aborting."
    exit 1 
    ;;
esac


# Check if the file already exists. If so, don't run this program.
if [[ -f ${file[full]} ]]; then
 echo "$0 ERROR: ${file[full]} already exists."
 echo "Aborting."
 exit 1
fi

# If path is not zero length AND does not exist THEN make the directory
# TODO: This next line hasn't been tested yet. Try it out!
[[ -n ${file[path]} ]] && [[ ! -d ${file[path]} ]] && mkdir -p ${file[path]}

# echo "${docopts}"
bash novy_doc.sh ${docopts} > ${file[full]}
