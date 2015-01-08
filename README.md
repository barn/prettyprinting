# prettyprinting
Take an email from mutt (or whatever) and print it to PDF on OSX.

Uses URL2PDF which takes a URL, throws it in Automator and prints it to PDF via the system rendering. Output is much nicer than LaTeX.

# Requirements

* URL2PDF - https://github.com/scottgarner/URL2PDF
* ripmime - http://www.pldaniels.com/ripmime/

# Mutt config

print_decode has to be off.

```
set print_command="prettymuttprint.sh"
set print_decode=no
```

