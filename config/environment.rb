require File.join(File.dirname(__FILE__), 'exceptions')
require './lib/bagatela'

git = File.join File.dirname(__FILE__), '..', '.git'
# Current git revision
rev = File.read File.join(git, 'refs', 'heads', 'master')    
# Latest tag name
tag = `git tag --contains master | head -n 1`                
# Tag name if master is tagged, commit hash otherwise
VERSION = tag != '' && File.read(File.join(git, 'refs', 'tags', tag)) == rev ? tag : rev[0..5]
