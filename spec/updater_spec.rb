require 'spec_helper'

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
end
