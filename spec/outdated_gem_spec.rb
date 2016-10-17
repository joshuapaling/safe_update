require 'spec_helper'

describe SafeUpdate::OutdatedGem do
  describe '#attempt_update' do
    it 'does not run tests if not asked' do
      the_gem = SafeUpdate::OutdatedGem.new(gem_name: 'rspec-rails')
      expect(the_gem).not_to receive(:system).with('rspec')
      the_gem.attempt_update
    end

    it 'runs tests if asked and commits if tests pass' do
      git_repo = SafeUpdate::GitRepo.new
      the_gem = SafeUpdate::OutdatedGem.new(gem_name: 'rspec-rails', git_repo: git_repo)
      expect(the_gem).to receive(:`).with('bundle update rspec-rails').exactly(1).times
      expect(the_gem).to receive(:system).with('rspec').exactly(1).times.and_return(true)
      expect(git_repo).to receive(:commit_gemfile_lock).with('update gem: rspec-rails')
      expect(git_repo).not_to receive(:discard_local_changes)
      the_gem.attempt_update('rspec')
    end

    it 'runs tests if asked and discards changes if tests fail' do
      git_repo = SafeUpdate::GitRepo.new
      the_gem = SafeUpdate::OutdatedGem.new(gem_name: 'rspec-rails', git_repo: git_repo)
      expect(the_gem).to receive(:`).with('bundle update rspec-rails').exactly(1).times
      expect(the_gem).to receive(:system).with('rspec').exactly(1).times.and_return(false)
      expect(git_repo).not_to receive(:commit_gemfile_lock).with('update gem: rspec-rails')
      expect(git_repo).to receive(:discard_local_changes)
      the_gem.attempt_update('rspec')
    end
  end
end
