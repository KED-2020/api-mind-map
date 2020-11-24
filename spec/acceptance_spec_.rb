# frozen_string_literal: true

require_relative 'helpers/spec_helper'
require_relative 'helpers/database_helper'
require_relative 'helpers/vcr_helper'
require 'headless'
require 'watir'

homepage = 'http://localhost:9292'

describe 'Acceptance Tests' do
  DatabaseHelper.setup_database_cleaner

  before do
    # DatabaseHelper.wipe_database    # Kept as test data
    # @headless = Headless.new    # need optionally install Xvfb on Mac 
    # @headless.start
    @browser = Watir::Browser.new
    # @browser = Watir::Browser.new :safari
  end

  after do
    @browser.close
    # @headless.destroy
  end

  describe 'Homepage' do

    it '(HAPPY) should see some basic elements on homepage' do
        # GIVEN: user is on the home page without any projects
        @browser.goto homepage

        # THEN: user should see basic headers, no projects and a welcome message
        _(@browser.a(id: 'home.link').text).must_equal 'Mind Map'
        _(@browser.input(id: 'inbox-id').placeholder).must_equal 'e.g 12345'
        _(@browser.button(id: 'inbox-submit').text).must_equal 'Find Inbox'
        _(@browser.a(id: 'guest-inbox').text).must_equal 'Continue as Guest'
        _(@browser.a(id: 'new-inbox').text).must_equal 'Create New Inbox'
    end

    it '(HAPPY) should be able to request a Test Inbox (e.g. /inbox/12345)' do
        # GIVEN: user is on the home page
        @browser.goto homepage

        # WHEN: they add an inbox URL and submit
        inbox_url = 'inbox'
        good_inbox_id = "12345"
        @browser.text_field(id: 'inbox-id').set(good_inbox_id)
        @browser.button(id: 'inbox-submit').click

        # THEN: they should find themselves on the inbox page
        _(@browser.url.include? inbox_url).must_equal true
        _(@browser.url.include? good_inbox_id).must_equal true
    end

    it '(HAPPY) should be able to request a Guest Inbox (e.g. /inbox/guest-inbox)' do
        # GIVEN: user is on the home page
        @browser.goto homepage

        # WHEN: they add an inbox URL and submit
        inbox_url = 'inbox'
        good_inbox_id = 'guest-inbox'
        @browser.element(id: 'guest-inbox').click

        # THEN: they should find themselves on the inbox page
        _(@browser.url.include? inbox_url).must_equal true
        _(@browser.url.include? good_inbox_id).must_equal true
    end

    it '(HAPPY) should be able to request a New Inbox (e.g. /inbox/)' do
        # GIVEN: user is on the home page
        @browser.goto homepage

        # WHEN: they add an inbox URL and submit
        inbox_url = 'inbox'
        @browser.element(id: 'new-inbox').click

        # THEN: they should find themselves on the inbox page
        _(@browser.url.include? inbox_url).must_equal true
    end

    it '(SAD) should not be able to add valid but non-existent inbox URL' do
        # GIVEN: user is on the home page
        @browser.goto homepage

        # WHEN: they add an inbox URL and submit
        inbox_url = 'inbox'
        sad_inbox_id = '54321'
        @browser.text_field(id: 'inbox-id').set(sad_inbox_id)
        @browser.button(id: 'inbox-submit').click

        # THEN: they should not redirect & should see a warning message
        _(@browser.url.include? sad_inbox_id).must_equal false
        _(@browser.div(id: 'flash_bar_danger').present?).must_equal true
        _(@browser.div(id: 'flash_bar_danger').text.downcase).must_include "doesn't exist"
    end

  end

end
