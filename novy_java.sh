#!/bin/bash
# File: novy_java.sh
# Date:  8 Nov 2013
# Author: Jason Charney (jrcharneyATgmailDOTcom)
# Info: Create a new java file


# The first argument is the filename
# If the second argument is "main" use the main template.
# If the second argumetn is "class" use the class template.
# If "main" or "class" is not used at all, the default response will be to create a main template.

# usage
# import "path1.path2.file1 path3.path4.file2"

# [-file] file_name [-switch] [-assign value]

# Note: When we say "map" we mean "associative array". Map is just another name, much like "hash" or "hash array"

# Fetch personal preferences from .novyrc
# If .novyrc does not exists, run novy_rc.sh first.
[[ ! -f .novyrc ]] && bash novy_rc.sh
source .novyrc

usage(){
 local helpdoc="novy_help_java.txt"
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

docopts="-cs c"		# The list of options that will be passed to novy_doc.sh
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
 [[ $1 =~ .java$ ]] && file[full]="${1}" || file[full]="${1}.java"				# Full file name. Append ".java" if it hasn't been done.
 file[ext]=${file[full]##*.}         # File extension.

 file[path]=${file[full]%/*}									# File path.  If not path, returns the string as it is.
 file[name]=${file[full]##*/}									# File name. Strip out the path
 [[ ${file[path]} == ${file[name]} ]] && file[path]=""						# This should help prevent directory creation later.
 file[name]=${file[name]^}									# Capitalize the file name
 [[ -n ${file[path]} ]] && file[full]=${file[path]}/${file[name]} || file[full]=${file[name]}	# Avoid leading file names with no paths with '/'
 file[class]=${file[name]%.java}                                                             	# Class name. Strip out the extension
 # file[class]=${file[class]^}                                               			# Capitalize the class name (customary in Java)
 docopts=" -fn ${file[full]} ${docopts}"
}

template="main"		# by default, we create a main-style template
# TODO: file[type]="main";	# Depending on what template we use we could consider the files's real type
# package=
# import=()		# This should declare an array

while [[ $# -gt 0 ]]; do
 case $1 in
  --help|-h) usage ;;	# Using thsi will end the program
  --file|--file-name|-f|-fn) shift; file_map "$1" ;;
  --template|-t)
   shift;
   # file[template]=$1
   case $1 in
    main|class|interface)    template="$1" ;;
    abstract|abstract-class) template="abstract" ;;
    none)                    template="none" ;;
   *)
     echo "$0 ERROR: Invalid template type: $template"
     echo "Use 'main', 'class', 'abstract[-class]', 'interface', 'none' (to use no template) or omit a template value to use a main template."
     echo "Aborting."
     exit 1
     ;;
   esac ;;
  -tm) 	  template="main" ;;
  -tc)	  template="class" ;;
  -tca)	  template="abstract" ;;
  -ti)	  template="interface" ;;
  -tn)    template="none" ;;

  # TODO: These three arguments should be used ONLY after the template is defined.
  # TODO: When useing these three options becomes possible, make it show that it could be used more than once.
  --extends|-x) shift; extends=$1 ;; # Class inheritance
  --implements|-m) shift; implements=$1 ;; # Interface implementation

  # TODO: I'm going to assume that I can use import two ways by doing this.
  #	1. quoting a long string with space separated import files (which would be wise)
  #	2. using the import tag more than once. (which is OK too.)
  # NOTE: This will NOT check for file existance. Let's the JVM point out what files do not exist.
  --import|-i)	# When and if we can do this, make it so that it can be used more than once
   shift
   imports=$1
   for i in ${imports[@]}; do import+=(${i%[,;]}); done	# clean up any commas or semicolons
   ;;

  # NOTE: This will NOT check for file existance. Let's the JVM point out what files do not exist.
  # NOTE: package is only used once.  If you use it again, it will overwrite the previous value.
  --package|-z) shift; package="$1";;

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

# Check if the file already exists. If so, don't run this program.
if [[ -f ${file[full]} ]]; then
 echo "$0 ERROR: ${file[full]} already exists."
 echo "Aborting."
 exit 1
fi

# If path is not zero length AND does not exist THEN make the directory
# TODO: This next line hasn't been tested yet. Try it out!
[[ -n ${file[path]} ]] && [[ ! -d ${file[path]} ]] && mkdir -p ${file[path]}

# Reminder: Classes can't throw exceptions only methods.
{
bash novy_doc.sh $docopts > ${file[full]}

[[ -n $package ]] && echo "package $package;"	# add the package that this file belongs to if it is part of one.

if [[ ${#import[@]} -gt 0 ]]; then
 [[ -n $package ]] && echo ""		# insert a line break between the package and the imports if a package exists.
 for i in "${import[@]}"; do echo "import $i;"; done
fi

case $template in
 main)
   first="public class ${file[class]}"
   [[ -n $extends ]] && first+=" extends ${extends^}"		# From what I can tell, java classes can only extend from one other class.
   if [[ -n $implements ]]; then				# Interfaces on the other hand are not limited
     first+=" implements "
     for i in "${implements[@]}"; do first+="${i^}, "; done
     first="${first%, }"	# remove the last comma and space
   fi
   cat >> ${file[full]} <<EOF

$first
{
 public static void main( String[] args )
 {
  // code
 } // end main
} // end class ${file[class]}
EOF
       ;;
 class)
   first="public class ${file[class]}"
   [[ -n $extends ]] && first+=" extends ${extends^}"		# From what I can tell, java classes can only extend from one other class.
   if [[ -n $implements ]]; then				# Interfaces on the other hand are not limited
     first+=" implements "
     for i in "${implements[@]}"; do first+="${i^}, "; done
     first="${first%, }"	# remove the last comma and space
   fi
   cat >> ${file[full]} << EOF

$first
{
 public ${file[class]}()
 {
  // code
 } // end constructor ${file[class]}
} // end class ${file[class]}
EOF
       ;;
 # Notes:
 # * Advantages of an abstract class:
 #	- An abstract class can use instance variables and constants as well as static variables and constants.
 #		Interfaces can only use static constants.
 #	- An abstract class can include regular methods that contain code as well as abstract methods that don't contain code.
 #		Interfaces can only define abstract methods.
 #	- An abstract class can define static methods.
 #		An interface cannot.
 # * Advantages of an interface:
 #	- A class can only directly inherit one other class, but it can directly implement multiple interfaces.
 #	- Any object created from a class that implements an interface can be used wherever the interface is accepted.
 abstract)
   first="public abstract class ${file[class]}"
   [[ -n $extends ]] && first+=" extends ${extends^}"		# From what I can tell, java classes can only extend from one other class.
   if [[ -n $implements ]]; then				# Interfaces on the other hand are not limited
     first+=" implements "
     for i in "${implements[@]}"; do first+="${i^}, "; done
     first="${first%, }"	# remove the last comma and space
   fi
   cat >> ${file[full]} << EOF

$first
{
 // abstract code
} // end abstract class ${file[class]}
EOF
     ;;
  # Notes:
  # * Declaring an interface is similar to declare a class, except you use the interface keyword instead of the class keyword.
  # * In an interface
  #	- all methods are automatically declared "public abstract",
  #	- all fields (constants) are automatically declared "public static final"
  # * Although you can code the "public" (for all), "abstract" (for methods), and "final" (for fields) keywords, they're optional.
  # * Interface methods can NOT be "static".
  # * Interfaces can be extended with one or more other interfaces
  # * Interfaces generally end with -able or -ible
  # * Interfaces are like abstract virtual classes in C++, in that you
  #	- define constants
  #	- declare (but do not define) methods
  # * Interfaces can NOT inherit classes.
  # * A class that implements an interface MUST implement (define) all those methods declared the interface
  #	as well as all the methods declared by any inherited interfaces
  #	unless the class is defined as abstract.
  # * Classes that implement an interface can use any of the constants declared in the interface
  #	as well as any constants declared by any inherited interface
  interface)
   first="public interface ${file[class]}"
   # [[ -n $extends ]] && first+="extends $extends"		# From what I can tell, java classes can only extend from one other class.
   if [[ -n $extends ]]; then				# Interfaces on the other hand are not limited
     first+="extends "
     for i in "${extends[@]}"; do first+="${i^}, "; done
     first="${first%, }"	# remove the last comma and space
   fi
   # NOTE: As far as I can tell, you can't implement other interfaces on an interface, but you can extend them.
   cat >> ${file[full]} << EOF

$first
{
 // Constants (fields) and methods
 // type CONST_NAME = value;		// field declaration
 // type methodName([parameterList]);	// method declaration
} // end interface ${file[class]}
EOF
       ;;
  none) ;;	# Use no template in this case. Foolish, but somebody will want it anyway.
  *)  # You should never get to this case!
    echo "$0 ERROR: How did you get here? You shouldn't be here!"
    echo "Aborting."
    exit 1
    ;;
esac
}
