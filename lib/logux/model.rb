# frozen_string_literal: true

require_relative 'model/logux_updater'
require_relative 'model/logux_proxy'

module Logux
  module Model
    def self.included(base)
      base.extend(Module.new do
        def track_logux_updates(*fields)
          @logux_tracked_fields = fields
        end

        def logux_tracked_fields
          @logux_tracked_fields ||= []
        end
      end)
    end

    def logux
      LoguxProxy.new(self)
    end
  end
end
