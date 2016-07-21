require 'spec_helper'

describe SafeUpdate::OutdatedGem do
  it 'parses gem name correctly' do
    line = 'poltergeist (newest 1.9.0, installed 1.8.1)'
    the_gem = SafeUpdate::OutdatedGem.new(line)
    expect(the_gem.name).to eq('poltergeist')
    expect(the_gem.newest).to eq('1.9.0')
    expect(the_gem.installed).to eq('1.8.1')
    expect(the_gem.requested).to eq(nil)
  end

  it 'parses gem name correctly with no requested' do
    line = 'rspec-rails (newest 3.4.2, installed 3.4.0, requested ~> 3.4)'
    the_gem = SafeUpdate::OutdatedGem.new(line)
    expect(the_gem.name).to eq('rspec-rails')
    expect(the_gem.newest).to eq('3.4.2')
    expect(the_gem.installed).to eq('3.4.0')
    expect(the_gem.requested).to eq('~> 3.4')
  end

  it 'raises error on unexpected lines' do
    # Unknown switches '--parseable'
    # is what you'll get for `bundle update --parseable`
    # on earlier versions

    expect { SafeUpdate::OutdatedGem.new('bundle update --parseable') }
      .to raise_error(RuntimeError)
  end

  describe '#attempt_update' do
    it 'does not run tests if not asked' do
      line = 'rspec-rails (newest 3.4.2, installed 3.4.0, requested ~> 3.4)'
      the_gem = SafeUpdate::OutdatedGem.new(line)
      expect(the_gem).not_to receive(:system).with('rspec')
      the_gem.attempt_update
    end

    it 'runs tests if asked and commits if tests pass' do
      line = 'rspec-rails (newest 3.4.2, installed 3.4.0, requested ~> 3.4)'
      git_repo = SafeUpdate::GitRepo.new
      the_gem = SafeUpdate::OutdatedGem.new(line, git_repo)
      expect(the_gem).to receive(:`).with('bundle update rspec-rails').exactly(1).times
      expect(the_gem).to receive(:system).with('rspec').exactly(1).times.and_return(true)
      expect(git_repo).to receive(:commit_gemfile_lock).with('update gem: rspec-rails')
      expect(git_repo).not_to receive(:discard_local_changes)
      the_gem.attempt_update('rspec')
    end

    it 'runs tests if asked and discards changes if tests fail' do
      line = 'rspec-rails (newest 3.4.2, installed 3.4.0, requested ~> 3.4)'
      git_repo = SafeUpdate::GitRepo.new
      the_gem = SafeUpdate::OutdatedGem.new(line, git_repo)
      expect(the_gem).to receive(:`).with('bundle update rspec-rails').exactly(1).times
      expect(the_gem).to receive(:system).with('rspec').exactly(1).times.and_return(false)
      expect(git_repo).not_to receive(:commit_gemfile_lock).with('update gem: rspec-rails')
      expect(git_repo).to receive(:discard_local_changes)
      the_gem.attempt_update('rspec')
    end
  end
end
