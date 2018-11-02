# frozen_string_literal: true

class Post < ActiveRecord::Base
  include Logux::Model

  track_logux_updates :title, :content
end
