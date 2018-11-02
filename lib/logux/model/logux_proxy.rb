# frozen_string_literal: true

module Logux
  module Model
    class LoguxProxy
      def initialize(model)
        @model = model
      end

      def update(meta, attributes)
        updater = LoguxUpdater.new(@model, meta, attributes)
        @model.update_attributes(updater.updated_attributes)
      end

      def updated_at(field)
        @model.logux_fields_updated_at[field.to_s]
      end
    end
  end
end
