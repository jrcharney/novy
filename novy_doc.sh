#!/bin/bash
# File: novy_doc.sh
# Date:  6 Nov 2013
# Author: Jason Charney, BSCS
# Email: jrcharneyATgmailDOTcom
# Info: Establish documentation in the header of a file created with the novy programs.
# Requirements: sed, less, bash
# TODO: Documentation style for scripts that use octothorpe commenting.
# TODO:  This file needs to be tested!

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


usage(){
 # NOTE: The Help documentation go a bit long. So I put it somwhere else.
 local helpdoc="novy_help_doc.txt"
 if [[ -f $helpdoc ]]; then
  # cat $helpdoc
  sed -n '/^#/!p' $helpdoc | less -eFMXR
  exit 0
 else
  echo "$0 ERROR: $helpdoc, not found."
  exit 1
 fi
}

if [[ $# -eq 0 ]]; then
 echo "$0 ERROR: this program need arguments to work."
 echo "Try $0 --help for a list of options."
 exit 1
fi

if [[ $# -eq 1 ]]; then
 case $1 in
 -h|--help|help) usage ;;
 *) ;;	# do nothing, just get out of this block.
 esac
fi

if [[ ! -f .novyrc ]]; then
 echo "$0 ERROR: It looks like .novyrc does not exist yet."
 ask_yn "Would you like to create the .novyrc file?"
 bash novy_rc.sh	# This will happen if you answer yes to the previous question.
fi
source .novyrc	# get self and fecha data if it is not established.

# TODO: Consider comment style
# 	[ ] /* C-Style */  (Which will be used by default for novy_c and novy_java)
#	[ ] # script style (Which we won't mess around with at this time.)

declare -A file		# Information about a file.
declare -A book		# Information about a file that is based on a book example.
declare -A use		# Determine if the header should use certain fields.

# 0 for no, 1 for yes
use[self]=1
use[fecha]=1
use[file]=1
use[book]=1
use[style]="c"		# Comment style "c" = C-style (used in C, C++, Java, and PHP), "h" = Hash style (used in Bash, Perl, Ruby)

# NOTE: Book fields are added for citing book information for examples that were used from books.
#	Only the filled out fields will be written.
# TODO: If a book database is ever esablish, make calling other book fields easy by calling up the ISBN number using book[isbn].
# NOTE: Even if you don't use the file-info option, an Info field will be added to the header unless nofile is used.
while :; do
 case $1 in
  --file-name|-fn)			shift; file[name]=$1 ;;		# The name of this file, definintely required.
  --file-version|-fv)			shift; file[version]=$1 ;;	# Version of this file
  --file-date|-fd)			shift; file[date]=$1;;		# Use a date other than the one provided by fecha[string]
  --file-author|-fa)			shift; file[author]=$1 ;;	# Use this author instead of the one provided by self[name]
  --file-author-email|-fae)		shift; file[email]=$1 ;;	# Use this email address instead of the one provided by self[email]
  --file-website|-fw)			shift; file[site]=$1 ;;		# The website of the author or the project 
  --file-requirements|-fr)		shift; file[reqs]=$1 ;;		# Indicate what software is required for this program to work effectively
  --file-info|"-fi")			shift; file[info]=$1 ;;		# The info for the file.
  --book-title|-bt)			shift; book[title]=$1 ;;	# title of a book
  --book-author|-ba) 			shift; book[author]=$1 ;;	# author of a book
  --book-publisher|-bp)			shift; book[publisher]=$1 ;;	# publisher of a book
  --book-publisher-location|-bpl)	shift; book[location]=$1 ;;	# The location of the publisher's main offices.
  --book-edition|-be)			shift; book[edition]=$1 ;;	# edition of a book
  --book-year|-by)			shift; book[year]=$1 ;;		# The year the book was published
  --book-isbn|-bi)			shift; book[isbn]=$1 ;;		# The ISBN number of the book.
  --book-website|-bw)			shift; book[site]=$1 ;;		# The website this example/figure can be found
  --book-webiste-accessed|-bwa)		shift; book[accessed]=$1 ;;	# Whe the website was accessed.
  --book-figure|-bfn)			shift; book[figure]=$1 ;;	# figure number from a book
  --book-page|-bfp)			shift; book[page]=$1 ;;		# the page number a book example/figure is on
  --noself)				       use[self]=0 ;;		# don't use the self fields from .newrc
  --nodate)             	  	       use[fecha]=0 ;;		# don't use the fecha field from .newrc
  --nofile)				       use[file]=0 ;;		# don't use any of the file fields other than the file[name] field.
  --nobook)				       use[book]=0 ;;		# don't use the book fields even if any of the were filled out.
  --comment-style|-cs)			shift; use[style]=${1,,} ;;	# Indicate which comment style to use.
 esac
 shift
 [[ $# -eq 0 ]] && break
done

# NOTE: Normally I would use a for loop to out put maps, however, when you use a for loop on maps, the data is output by the alphabetical order of the map keys.
#	To enforce certain values in a specific order, we have to be explictly literal.

# This program won't run without a file name
# TODO: ./novy_java's ${file[full]} should become ./novy_doc's ${file[name]}, in theory.
if [[ -z ${file[name]} ]]; then
 echo "$0 ERROR: No File name. Include '-fn FILENAME' to make this script work."
 echo "Aborting this script."
 exit 1
fi

# Comment style
declare -A com
case ${use[style]} in
 c|java)   com[s]="c"; com[b]="/* "; com[m]=" * "; com[e]=" */" ;;
 h|"hash") com[s]="h"; com[b]="# ";  com[m]="# ";  com[e]="" ;;
 *) echo "$0 ERROR: Invalid comment style. Aborting the script."; exit 1 ;;
esac

# REMEMBER: If you do not forward the output of this data to a file it will print to standard output.
echo "${com[b]}File: ${file[name]}"			# This should make the file name field first. Open our heading Java comments
if [[ ${use[file]} -ne 0 ]]; then
   [[ -n ${file[version]} ]] && echo "${com[m]}Version: ${file[version]}"
   if [[ ${use[fecha]} -ne 0 ]]; then
     if [[ -n ${file[date]} ]]; then 	#  && ds=${file[date]} || ds=${fecha[string]}
      echo "${com[m]}Date: "$(date -d "${file[date]}" +"${fecha[format]}")
     else
      echo "${com[m]}Date: "$(date -d "${fecha[string]}" +"${fecha[format]}")
     fi
   fi
   if [[ ${use[self]} -ne 0 ]]; then
    [[ -n ${file[author]} ]] && echo "${com[m]}Name: ${file[author]}" || echo "${com[m]}Name: ${self[name]}"
    if [[ -n ${file[email]} ]]; then
     file[email]=${file[email]//@/AT}
     file[email]=${file[email]//./DOT}
     echo "${com[m]}Email: ${file[email]}"
    else
     echo "${com[m]}Email: ${self[email]}"
    fi
    [[ -n ${file[site]} ]] && echo "${com[m]}Website: ${file[site]}"
   fi
fi	# file block
if [[ ${use[book]} -ne 0 ]]; then
	# title, author, publisher, location, edition, year, isbn, site, accessed, figure, page
   [[ -n ${book[title]} ]] && echo "${com[m]}Title: ${book[title]}"
   [[ -n ${book[author]} ]] && echo "${com[m]}Author: ${book[author]}"
   [[ -n ${book[publisher]} ]] && echo "${com[m]}Publisher: ${book[publisher]}"
   [[ -n ${book[location]} ]] && echo "${com[m]}Pub. Loc.: ${book[location]}"
   [[ -n ${book[edition]} ]] && echo "${com[m]}Edition: ${book[edition]}"
   [[ -n ${book[year]} ]] && echo "${com[m]}Published: ${book[year]}"
   [[ -n ${book[isbn]} ]] && echo "${com[m]}ISBN: ${book[isbn]}"
   [[ -n ${book[site]} ]] && echo "${com[m]}Website: ${book[site]}"
   [[ -n ${book[accessed]} ]] && echo "${com[m]}Accesed: "$(date -d "${book[accessed]}" +"${fecha[format]}")
   [[ -n ${book[figure]} ]] && echo "${com[m]}Fig.: ${book[figure]}"
   [[ -n ${book[page]} ]] && echo "${com[m]}Page: ${book[page]}"
fi	# book block

# I like having my requirements and info at the ned.
if [[ ${use[file]} -ne 0 ]]; then
   [[ -n ${file[reqs]} ]] && echo "${com[m]}Reqs: ${file[reqs]}"
   [[ -n ${file[info]} ]] && echo "${com[m]}Info: ${file[info]}" || echo "${com[m]}Info:"
fi	# file block (part 2)
[[ ${com[s]} == "c" ]] && echo " */"
# echo ""		# Add a blank line for good measure
