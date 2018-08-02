# frozen_string_literal: true

require 'nokogiri'

# Utility module for dealing with XML messages.
module Message
  def get_message_id(message)
    xml = Nokogiri::XML(message)
    # We don't care about the XML namespaces in the response XML - we just want to get the message ID.
    xml.remove_namespaces!
    xml.css('Id').text
  end
end
