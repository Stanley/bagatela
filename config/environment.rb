require File.join(File.dirname(__FILE__), 'exceptions')
require './lib/bagatela'

# Git repo home
git = File.join File.dirname(__FILE__), '..', '.git'
# Current git revision
rev = File.read File.join(git, 'refs', 'heads', 'master')    
REVISION = rev[0..5]
