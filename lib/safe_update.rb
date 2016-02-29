# @ToDO - without changing the loadpath here,
# we get errors:
# /lib/safe_update.rb:4:in `require': cannot load such file -- safe_update/version
# See what we can do to resolve this.
lib = File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require "safe_update/version"
require "safe_update/updater"
require "safe_update/outdated_gem"

module SafeUpdate
end
