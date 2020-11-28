# frozen_string_literal: true

require_relative '../helpers/acceptance_helper'
require_relative 'pages/inbox_page'
require_relative 'pages/home_page'

describe 'Project Page Acceptance Tests' do
  include PageObject::PageFactory

  DatabaseHelper.setup_database_cleaner

  before do
    # DatabaseHelper.wipe_database    # Kept as test data
    @browser = Watir::Browser.new :chrome, headless: true    # need optionally install Xvfb on Mac 
  end

  after do
    @browser.close
  end

  describe 'Visit Inbox page' do

    it '(Happy) should see search content' do
      # GIVEN: user adds an existent inbox URL and submit
      good_inbox_id = '12345'
      visit HomePage do |page|
        page.request_inbox(good_inbox_id)
      end

      
      # WHEN: user goes to the inbox page
      visit(InboxPage, using_params: { inbox_id: good_inbox_id }) do |page|
        # THEN: they should see the searching results
        _(page.all_elements_has_correct_text?).must_equal true

        suggestion_names = ['tensorflow', 'TensorFlow', 'TensorFlow-Examples']
        _(page.suggestions[0].text).must_include suggestion_names[0]
        _(page.suggestions[0].text).must_include suggestion_names[1]
        _(page.suggestions[0].text).must_include suggestion_names[2]
      end
    end

  end

end
