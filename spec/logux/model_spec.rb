# frozen_string_literal: true

require 'spec_helper'
require 'rails_helper'

describe Logux::Model do
  subject(:model) do
    create(
      :post,
      logux_fields_updated_at: {
        title: initial_meta.comparable_time,
        content: initial_meta.comparable_time
      }
    )
  end

  let(:older_update_meta) do
    create(
      :logux_meta,
      time: Time.parse('01-11-2018 12:05').to_datetime.strftime('%Q')
    )
  end

  let(:initial_meta) do
    create(
      :logux_meta,
      time: Time.parse('01-11-2018 12:10').to_datetime.strftime('%Q')
    )
  end

  let(:newer_update_meta) do
    create(
      :logux_meta,
      time: Time.parse('01-11-2018 12:15').to_datetime.strftime('%Q')
    )
  end

  let(:latest_update_meta) do
    create(
      :logux_meta,
      time: Time.parse('01-11-2018 12:20').to_datetime.strftime('%Q')
    )
  end

  describe '#update' do
    it 'updates newer attribute' do
      model.logux.update(newer_update_meta, content: 'newer')
      expect(model.content).to eq('newer')
    end

    it 'keeps attribute updated later' do
      model.logux.update(older_update_meta, content: 'older')
      expect(model.content).to eq('initial')
    end

    # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
    it 'updates multiple fields' do
      model.logux.update(latest_update_meta, content: 'latest')
      expect(model.title).to eq('initial')
      expect(model.content).to eq('latest')

      model.logux.update(
        newer_update_meta,
        title: 'newer',
        content: 'newer'
      )
      expect(model.title).to eq('newer')
      expect(model.content).to eq('latest')
    end
    # rubocop:enable RSpec/MultipleExpectations, RSpec/ExampleLength
  end
end
