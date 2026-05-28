# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

require "bundler/audit/task"
Bundler::Audit::Task.new

task default: %i[spec standard bundle:audit:update bundle:audit]
