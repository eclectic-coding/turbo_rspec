# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "standard/rake"

require "bundler/audit/task"
Bundler::Audit::Task.new

task default: %i[bundle:audit:update bundle:audit spec standard]
