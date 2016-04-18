# SafeUpdate

This automates the tedious but important process of updating your gems, one at a time.

When I first started ruby, I was told 'Never run `bundle update`'. The reality is, we should be keeping our gems as up to date as possible - but `bundle update` just isn't a great way to do it. It does everything in one hit, and it's hard to figure out the cause when things go wrong.

This gem does `bundle update` in a safer way. It takes the output of `bundle outdated`, and, for each outdated gem, it:

- runs `bundle update <gem_name>`
- commits to git with the message: `update gem: <gem_name>`

Once you've got each gem updated, with one commit per gem, you can run your tests, and check everything is working. If something is broken, you can use `git bisect` to easily figure out the problem gem.

## Installation

    $ gem install safe_update

And then, from your project's root directory, execute:

    $ safe_update

Since this gem is not a dependency of your application, per se, there's no need to add it to your gemfile.

## Usage

1. `cd /path/to/project`
2. `safe_update`
3. Watch your gems get updated and committed, one at a time. The output looks like this:

```
(... more goes here)
-------------
OUTDATED GEM: sprockets-rails
   Newest: 3.0.3.
Installed: 3.0.0.
Running `bundle update sprockets-rails`...
committing changes (message: 'bundle update sprockets-rails')...
-------------
OUTDATED GEM: uniform_notifier
   Newest: 1.10.0.
Installed: 1.9.0.
Running `bundle update uniform_notifier`...
committing changes (message: 'bundle update uniform_notifier')...
-------------
-------------
FINISHED
```

### Options

Run `safe_update -h` to view all options:

```
Usage: safe_update [options]
    -v, --version                    Show version
    -p, --push N                     git push every N commits
```

### Recommended workflow

**Step 1**

Checkout a new branch and run safe-update, pushing every commit so your CI builds can run:

```
git checkout -b run-safe_update && git push -u origin run-safe_update && safe_update -p 1
```

**Step 2**

Once everything is good, merge the branch back into master and delete the branch:

```
git checkout master && git merge run-safe_update && git branch -d run-safe_update && git push origin --delete run-safe_update
```

## Future

I've knocked this up really quickly, and it's pretty MVP-ish. Ideas for future include:

- run your tests each update, and don't update problem gems.
- specify what update sizes you want to apply (major, minor, patch); for now you need to rely on the [Gemfile version specifiers](http://bundler.io/gemfile.html).
- summary of what's happened at the end (eg. 2 major updates ignored, 5 minor updates applied, etc).
- other ideas? Open an issue.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/joshuapaling/safe_update.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

