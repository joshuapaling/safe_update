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
end
