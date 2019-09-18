# frozen_string_literal: true

require 'rubygems'
require 'bundler/setup'
require 'yaml'
require 'discourse_api'
require 'loofah'
require 'word_wrap'

require_relative './machine'

creds = YAML.load_file("discourse.yml")

api = DiscourseApi::Client.new(creds['url'])
api.api_key = creds['api_key']
api.api_username = creds['api_username']

machine = Machine.new(api)
machine.run
