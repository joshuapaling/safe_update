require 'spec_helper'

describe SafeUpdate do
  it 'has a version number' do
    expect(SafeUpdate::VERSION).not_to be nil
  end
end
