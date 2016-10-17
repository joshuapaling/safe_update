require 'spec_helper'

sample_output = <<eot
The git source `git://github.com/ianfleeton/paypal-express.git` uses the `git` protocol, which transmits data without encryption. Disable this warning with `bundle config git.allow_insecure true`, or switch to the `https` protocol to keep your data secure.
some other example line that should be discarded

Fetching git://github.com/activerecord-hackery/ransack.git
Fetching gem metadata from https://rubygems.org/..........
Fetching version metadata from https://rubygems.org/...
Fetching dependency metadata from https://rubygems.org/..
Resolving dependencies...................................

Outdated gems included in the bundle:
  * rails-footnotes (newest 4.1.8 4e6f69f, installed 4.1.8 a179ce0)
  * rspec-rails (newest 3.4.2, installed 3.4.0, requested ~> 3.4)
  * poltergeist (newest 1.9.0, installed 1.8.1)
  * unf_ext (newest 0.0.7.2, installed 0.0.7.1)
eot

describe SafeUpdate::GitRepo do
  it 'Gets rid of irrelevant lines' do
    parser = SafeUpdate::BundleOutdatedParser.new
    allow(parser).to(
      receive(:`).with('bundle outdated')
      .and_return(sample_output)
    )

    outdated_gems = parser.call
    # Just check two results... if it works for those two,
    # safe to assume it works for the others with slightly different formats

    expect(outdated_gems[0].gem_name).to eq('rails-footnotes')
    expect(outdated_gems[0].newest).to eq('4.1.8 4e6f69f')
    expect(outdated_gems[0].installed).to eq('4.1.8 a179ce0')
    expect(outdated_gems[0].requested).to eq(nil)

    expect(outdated_gems[1].gem_name).to eq('rspec-rails')
    expect(outdated_gems[1].newest).to eq('3.4.2')
    expect(outdated_gems[1].installed).to eq('3.4.0')
    expect(outdated_gems[1].requested).to eq('~> 3.4')
  end
end
