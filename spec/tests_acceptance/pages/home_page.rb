# frozen_string_literal: true

# Page object for home page
class HomePage
  include PageObject

  page_url MindMap::App.config.APP_HOST

  a(:home_link_hyperlink, id: 'home.link')
  text_field(:inbox_id_text, id: 'inbox-id')
  button(:inbox_submit_button, id: 'inbox-submit')
  a(:guest_inbox_hyperlink, id: 'guest-inbox')
  a(:new_inbox_hyperlink, id: 'new-inbox')

  div(:warning_message, id: 'flash_bar_danger')
  div(:success_message, id: 'flash_bar_success')

  def warning_message_present?
    self.warning_message_element.present?
  end

  def all_elements_present?
    self.home_link_hyperlink_element.present?.eql? true
    self.inbox_id_text_element.present?.eql? true
    self.inbox_submit_button_element.present?.eql? true
    self.guest_inbox_hyperlink_element.present?.eql? true
    self.new_inbox_hyperlink_element.present?.eql? true
    self.warning_message_present?.eql? false
  end

  def all_elements_has_correct_text?
    self.home_link_hyperlink_element.text.eql? 'Mind Map'
    self.inbox_id_text_element.text.eql? 'e.g 12345'
    self.inbox_submit_button_element.text.eql? 'Find Inbox'
    self.guest_inbox_hyperlink_element.text.eql? 'Continue as Guest'
    self.new_inbox_hyperlink_element.text.eql? 'Create New Inbox'
  end

  def request_inbox(inbox_id)
    self.inbox_id_text = inbox_id
    self.inbox_submit_button    # click
  end

  def request_guest_inbox
    self.guest_inbox_hyperlink    # click
  end

  def request_new_inbox
    self.new_inbox_hyperlink    # click
  end

  def is_warning_message?
    self.warning_message.downcase.include? "not found"
  end

  def in_inbox_page?
    self.current_url.include? 'inbox'
  end

  def in_guest_inbox_page?
    self.current_url.include? 'guest-inbox'
  end

  def in_this_inbox_page?(inbox_id)
    self.current_url.include? inbox_id
  end

end
