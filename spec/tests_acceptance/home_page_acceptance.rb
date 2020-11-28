# frozen_string_literal: true

require_relative '../helpers/acceptance_helper'
require_relative 'pages/home_page'

describe 'Homepage Acceptance Tests' do
  include PageObject::PageFactory
  
  DatabaseHelper.setup_database_cleaner

  before do
    # DatabaseHelper.wipe_database    # Kept as test data
    @browser = Watir::Browser.new :chrome, headless: true    # need optionally install Xvfb on Mac 
  end

  after do
    @browser.close
  end

  describe 'Visit Home page' do

    it '(Happy) should see some basic elements on homepage' do
      # GIVEN: nothing
      # WHEN: user goes to the homepage
      visit HomePage do |page|
        # THEN: user should see some basic elements & should not see a warning message 
        _(page.all_elements_present?).must_equal true
        # THEN: these basic elements should be correct (Not decoupled if we test the textfield!?)
        _(page.all_elements_has_correct_text?).must_equal true
      end
    end

    it '(HAPPY) should be able to request a Test Inbox (e.g. /inbox/12345)' do
      # GIVEN: an 'inbox 12345' exists in the database

      # WHEN: user goes to the homepage
      visit HomePage do |page|
        # WHEN: user adds an existent inbox URL and submit
        good_inbox_id = '12345'
        page.request_inbox(good_inbox_id)
        # THEN: user should be redirected to the 'inbox 12345'
        _(page.in_inbox_page?).must_equal true
        _(page.in_this_inbox_page?(good_inbox_id)).must_equal true
      end
    end

    it '(HAPPY) should be able to request a Guest Inbox (e.g. /inbox/guest-inbox)' do
      # GIVEN: a 'guest inbox' exists in the database

      # WHEN: user goes to the homepage
      visit HomePage do |page|
        # WHEN: user clicks the guest inbox button
        page.request_guest_inbox
        # THEN: user should be redirected to the 'guest inbox'
        _(page.in_inbox_page?).must_equal true
        _(page.in_guest_inbox_page?).must_equal true
      end
    end

    it '(HAPPY) should be able to request a New Inbox (e.g. /inbox/)' do
      # GIVEN: a 'new inbox' exists in the database

      # WHEN: user goes to the homepage
      visit HomePage do |page|
        # WHEN: user clicks the new inbox button
        page.request_new_inbox
        # THEN: user should be redirected to the 'new inbox'
        _(page.in_inbox_page?).must_equal true
      end
    end

    it '(SAD) should not be able to redirect to valid but non-existent inbox URL' do
      # GIVEN: 'inbox 12345' is the only inbox exists in the database

      # WHEN: user goes to the homepage
      visit HomePage do |page|
        # WHEN: user adds a nonexistent inbox URL (e.g. 54321) and submit
        sad_inbox_id = '54321'
        page.request_inbox(sad_inbox_id)
        # THEN: user should not be redirected
        _(page.in_this_inbox_page?(sad_inbox_id)).must_equal false
        # THEN: user should see a warning message
        _(page.warning_message_present?).must_equal true
        _(page.is_warning_message?).must_equal true
      end
    end

  end

end
