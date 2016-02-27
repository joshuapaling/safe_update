require 'spec_helper'

describe SafeUpdate::OutdatedGem do

  it 'parses gem name correctly' do
    the_gem = SafeUpdate::OutdatedGem.new('poltergeist (newest 1.9.0, installed 1.8.1)')
    expect(the_gem.name).to eq('poltergeist')
    expect(the_gem.newest).to eq('1.9.0')
    expect(the_gem.installed).to eq('1.8.1')
    expect(the_gem.requested).to eq(nil)
  end

  it 'parses gem name correctly with no requested' do
    the_gem = SafeUpdate::OutdatedGem.new('rspec-rails (newest 3.4.2, installed 3.4.0, requested ~> 3.4)')
    expect(the_gem.name).to eq('rspec-rails')
    expect(the_gem.newest).to eq('3.4.2')
    expect(the_gem.installed).to eq('3.4.0')
    expect(the_gem.requested).to eq('~> 3.4')
  end
end
