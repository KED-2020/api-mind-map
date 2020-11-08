# frozen_string_literal: true

require 'hirb'
require 'hirb-unicode'

Hirb.enable output: {
  'Array' => { class: :auto_table, ancestor: true },
  'Hash' => { class: :auto_table, ancestor: true }
}
