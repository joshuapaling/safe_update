require 'spec_helper'
require 'safe_update/outdated_gem'

describe SafeUpdate::Updater do
  it 'Exits if there are staged changes' do
    updater = SafeUpdate::Updater.new
    allow(updater).to(
      receive(:`).with('git diff --name-only --cached')
      .and_return('some/file.rb')
    )
    expect { updater.run }.to raise_error(SystemExit)
  end

  it 'Exits if there are gemfile.lock changes (staged or unstaged)' do
    updater = SafeUpdate::Updater.new
    allow(updater).to receive(:`).and_return('')
    allow(updater).to(
      receive(:`).with('git diff --name-only').and_return('Gemfile.lock')
    )
    expect { updater.run }.to raise_error(SystemExit)
  end

  it 'Runs git push if the push option is specified' do
    updater = SafeUpdate::Updater.new
    # I don't feel totally comfortable with just stubbing everything
    # but I'm not sure what alternative approach there is, given
    # all the methods run a bunch of shell commands that we don't
    # want to run in the tests themselves.
    allow(updater).to receive(:check_for_staged_changes)
    allow(updater).to receive(:check_for_gemfile_lock_changes)
    allow(updater).to receive(:bundle_outdated_parseable).and_return("1\n2\n3\n4\n5\n")
    allow(updater).to receive(:update_gem)
    # expect git push 3 times - twice at lines 2 and 4 (based on telling
    # it to push every 2 commits), then once after
    # all lines are finished, at the very end
    expect(updater).to receive(:`).with('git push').exactly(3).times
    updater.run(push: '2')
  end
end
