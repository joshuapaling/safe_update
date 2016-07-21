require 'spec_helper'

describe SafeUpdate::GitRepo do
  it 'Exits if there are staged changes' do
    git_repo = SafeUpdate::GitRepo.new
    allow(git_repo).to(
      receive(:`).with('git diff --name-only --cached')
      .and_return('some/file.rb')
    )
    expect { git_repo.perform_safety_checks }.to raise_error(RuntimeError)
  end

  it 'Exits if there are gemfile.lock changes (staged or unstaged)' do
    git_repo = SafeUpdate::GitRepo.new
    allow(git_repo).to receive(:`).and_return('')
    allow(git_repo).to(
      receive(:`).with('git diff --name-only').and_return('Gemfile.lock')
    )
    expect { git_repo.perform_safety_checks }.to raise_error(RuntimeError)
  end
end
