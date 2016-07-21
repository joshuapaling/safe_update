require 'spec_helper'
require 'safe_update/outdated_gem'
require 'safe_update/git_repo'

describe SafeUpdate::Updater do
  it 'Performs safety checks' do
    git_repo = SafeUpdate::GitRepo.new
    expect(git_repo).to receive(:perform_safety_checks)
    updater = SafeUpdate::Updater.new(git_repo)
  end

  it 'Runs git push if the push option is specified' do
    git_repo = SafeUpdate::GitRepo.new
    updater = SafeUpdate::Updater.new(git_repo)
    # I don't feel totally comfortable with just stubbing everything
    # but I'm not sure what alternative approach there is, given
    # all the methods run a bunch of shell commands that we don't
    # want to run in the tests themselves.
    allow(updater).to receive(:bundle_outdated_parseable).and_return("1\n2\n3\n4\n5\n")
    SafeUpdate::OutdatedGem.any_instance.stub(:initialize).and_return(true)
    SafeUpdate::OutdatedGem.any_instance.stub(:attempt_update).and_return(true)
    # expect git push 3 times - twice at lines 2 and 4 (based on telling
    # it to push every 2 commits), then once after
    # all lines are finished, at the very end
    expect(git_repo).to receive(:push).exactly(3).times
    updater.run(push: '2')
  end
end
