novy
====

The Novy programming suite

**Welcome to Novy!  The New Black is here!**


What does "novy" mean?
----

If my genealogy and understanding of a few words in other languages is correct, "novy" should be the Slavic word for "new".

The idea was to make something that stood out. It turns out "Charney" is the Slavic word for the color "Black" when translated into Polish ("czarny"), Czech ("černý"). Slovak ("čierny"), Russian ("черный"), Ukranian ("чорний"), and several other dialects of languages stemming from Slavic roots.

So why not come up with some cool name for all my "new" programs? "nowy" (.pl), "nový" (.cz), "nový" (.sk), "новый" (.ru), "новий" (.ua) seemed to have pointed to the same Romanization: Novy.


So what is "novy"?
----
Novy is a text-based set of bash scripts that generate files automatically.  It is very intuitive.

The first time you use novy, you create a file called .novyrc with novyrc.sh. It will ask you a few questions to insert your name and email address as well as set up the fields for adding dates and date formats for header documentation.

The next time you use novy, you can use it to generate Java, C/C++, even scripts with the header documentation set up for you.  The script that generates the documentation is called novy_doc.sh.  But you don't really need to run novy_doc.sh directly as it is part of the main script simply called novy.sh.

But Novy doesn't just set up header documentation.  It also establishes templates.  As of this writing, novy_java.sh sets up four common templates for class construction: main, class, abstract class, and interface.  It's something I hope to establish with other languages in the future and eventually down the road user-defined templates.

Depending on what language you ask novy to write for you, based on the file extension you give for your file, novy.sh will run one of three scripts once it is done checking to see if .novyrc exists and writing the file header information.

If you intend on making a .java file, novy.sh will call upon novy_java.sh.  If you intend on making a .c, .cpp, .h, or .hpp file, novy_c.sh will be called upon.  For most scripting languages like Bash (.sh), Perl (.pl), Python (.py), and Ruby (.rb), novy_script.sh will be the program of choice.

In a near future version of Novy, I also plan to include Haskell (.hs, .lhs), Scala (.scala), Lisp (.lisp, .el, .cl), LaTeX (.tex), PostScript (.ps), HTML, JavaScript, CSS, SQL, and PHP though my primary goal is to make Novy work for Java, C++, and Ruby (including JRuby) for the moment.


So why use "novy" instead of a IDE like Eclipse or Netbeans?  Why do you like Vim?
----
IDEs (Integrated Development Enviroments) are sort of like the inside joke between friends.  Unless you understand what the joke is about, you won't understand why it is so funny.

The folks who make IDEs have made a big business of telling their inside jokes to each other that unless you pay into classes, seminars, webinars, conferences, expositions, timeshare sales pitiches, even CRUISES, you're complete understanding of this capitalist comedy circuit is like trying to look at a Magic Eye poster and not understanding how to see the sailboat in the picture that looks like marble art and also having nobody tell that there IS a sailboat in the picture.

In other words, the IDE industry has their own lingo and milk a good fortune from programmers each year just to make one special feature work that they didn't know about.

Novy doesn't have surprises.  Novy also doesn't make explaining how it all works by needing to take trip to San Jose, Boston, or Raleigh every few months or paying through the nose for some Skype webinar.

It just helps you write programs, be you a student, a teacher, a hacker, or a professional.

But Novy just isn't some program that you run.  It's a project that explains without difficulty how to make Vim behave like an IDE.  The essential stuff that's been built in all along but you were probably too timid to alter.  Believe me, I've been there, espeically since there isn't someone to lead the way to help you make the big step from editing files with Vim to creating programs with Vim.

Novy's Wiki will be put to good use for that.  Pointing out the important stuff that is in the Vim Wikia that's buried under a bunch of how-tos that you may never use, and putting them into interactive scripts that are painless and at the same time bold.

