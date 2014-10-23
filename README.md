#Cars Custom foodcritic rules
==========================
Contained herein are custom foodcritic rules I have written for use on our cookbook at cars.com.  We also use several comminity rules. 

## CARS001 - Remote file resource called without sanity check
This searches `remote_file` resources and checks to see if they contain either only_if or not_if guards.

While the content of the guard is not examined, the intent is that this guard should perform some generic check to ensure the file being downloaded is valid.  This would typically involve some form of content check to avoid replacing a nessesary config file with an unintended file (such as an error page recieved from a http call).

````
remote_file '/etc/sudoers' do
  source 'https://github.com/nobody/example-sudoers.txt?raw'
  action :create
  only_if "curl -sl https://github.com/nobody/example-sudoers.txt?raw|grep -iE '\# Generated by Chef'"
end
````

## CARS002 - Missing CHANGELOG entry for current version
A companion to CINK001, this pulls the cookbook version from metadata.rb and searches for an entry in CHANGELOG.md which matches it.  While not perfect as it passes on any string that matches the version string, it does help ensure this "incredibly important" document is updated with the current changes.

## CARS003 - OS Support not specified
This simply checks that a supports entry is made in metadata.rb.  The idea being that in an environment of multiple platforms it is helpful to know which coookbooks have been designed for and tested with which platforms.