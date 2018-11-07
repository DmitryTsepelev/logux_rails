# frozen_string_literal: true

require 'configurations'
require 'rest-client'
require 'rails/engine'
require 'active_support'
require 'hashie/mash'
require 'logux/engine'
require 'nanoid'
require 'colorize'

module Logux
  extend ActiveSupport::Autoload
  include Configurations

  class WithMetaError < StandardError
    attr_reader :meta

    def initialize(msg, meta: nil)
      @meta = meta
      super(msg)
    end
  end

  UnknownActionError = Class.new(WithMetaError)
  UnknownChannelError = Class.new(WithMetaError)
  UnauthorizedError = Class.new(StandardError)

  autoload :Client, 'logux/client'
  autoload :Meta, 'logux/meta'
  autoload :Actions, 'logux/actions'
  autoload :Auth, 'logux/auth'
  autoload :BaseController, 'logux/base_controller'
  autoload :ActionController, 'logux/action_controller'
  autoload :ChannelController, 'logux/channel_controller'
  autoload :ClassFinder, 'logux/class_finder'
  autoload :ActionCaller, 'logux/action_caller'
  autoload :PolicyCaller, 'logux/policy_caller'
  autoload :Policy, 'logux/policy'
  autoload :Add, 'logux/add'
  autoload :Node, 'logux/node'
  autoload :Response, 'logux/response'
  autoload :Stream, 'logux/stream'
  autoload :Process, 'logux/process'
  autoload :Logger, 'logux/logger'
  autoload :Version, 'logux/version'
  autoload :Test, 'logux/test'
  autoload :ErrorRenderer, 'logux/error_renderer'
  autoload :Model, 'logux/model'

  configurable :logux_host, :verify_authorized,
               :password, :logger,
               :on_error, :auth_rule

  configuration_defaults do |config|
    config.logux_host = 'localhost:1338'
    config.verify_authorized = true
    config.logger = ActiveSupport::Logger.new(STDOUT)
    if defined?(Rails) && Rails.respond_to?(:logger)
      config.logger = Rails.logger
    end
    config.on_error = proc {}
    config.auth_rule = proc { false }
  end

  def self.add(type, meta: {})
    logux_add = Logux::Add.new
    logux_meta = Logux::Meta.new(meta)
    logux_add.call(type, meta: logux_meta)
  end

  def self.undo(meta: Logux::Meta.new({}), reason: nil)
    Logux::Add.new.call(
      { type: 'logux/undo', id: meta.id, reason: reason },
      meta: meta
    )
  end

  def self.verify_request_meta_data(meta_params)
    if Logux.configuration.password.nil?
      logger.warn(%(Please, add password for logux server:
                          Logux.configure do |c|
                            c.password = 'your-password'
                          end))
    end
    auth = Logux.configuration.password == meta_params&.dig(:password)
    raise Logux::UnauthorizedError, 'Incorrect password' unless auth
  end

  def self.process_batch(stream:, batch:)
    Logux::Process::Batch.new(stream: stream, batch: batch).call
  end

  def self.generate_action_id
    Logux::Node.instance.generate_action_id
  end

  def self.logger
    Logux::Logger
  end
end
