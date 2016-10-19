$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'safe_update'

outdated_gems = []
outdated_gems << SafeUpdate::OutdatedGem.new(
  gem_name: 'rails',
  newest: '1.2.3',
  installed: '1.2.1',
  requested: '~> 1.2.0',
)

outdated_gems << SafeUpdate::OutdatedGem.new(
  gem_name: 'rspec',
  newest: '1.2.3',
  installed: '1.2.1',
  requested: '~> 1.2.0',
)

outdated_gems << SafeUpdate::OutdatedGem.new(
  gem_name: 'byebug',
  newest: '1.2.3',
  installed: '1.2.1',
  requested: '~> 1.2.0',
)

outdated_gems << SafeUpdate::OutdatedGem.new(
  gem_name: 'bullet',
  newest: '3.2.1',
  installed: '1.2.1',
)

states = [
  SafeUpdate::OutdatedGem::STATUS_PENDING,
  SafeUpdate::OutdatedGem::STATUS_UPDATING,
  SafeUpdate::OutdatedGem::STATUS_TESTING,
  SafeUpdate::OutdatedGem::STATUS_UPDATED,
  SafeUpdate::OutdatedGem::STATUS_UNCHANGED,
  SafeUpdate::OutdatedGem::STATUS_TESTS_FAIL,
]

outdated_gems.map do |outdated_gem|
  outdated_gem.instance_variable_set(
    :@current_status,
    states.sample
  )
end

presenter = SafeUpdate::Presenter.new
Thread.new { presenter.call(outdated_gems) }
20.times do
  sleep 0.25
  outdated_gems.sample.instance_variable_set(
    :@current_status,
    states.sample
  )
end
presenter.stop
