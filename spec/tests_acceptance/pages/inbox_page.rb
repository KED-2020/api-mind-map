# frozen_string_literal: true

# Page object for home page
class InboxPage
  include PageObject

  page_url MindMap::App.config.APP_HOST + '/inbox/<%=params[:inbox_id]%>'

  h1(:inbox_name_text, id: 'inbox_name')
  p(:inbox_description_text, id: 'inbox_description')

  indexed_property(
    :suggestions,
    [
      [:span, :name, { id: 'suggestion[%s].link' }],
    ]
  )

  def all_elements_has_correct_text?
    self.inbox_name_text_element.present?.eql? true
    self.inbox_description_text_element.present?.eql? true
    self.inbox_name_text.include? 'Test Inbox'
    self.inbox_description_text.include? 'A test inbox'
  end



end
