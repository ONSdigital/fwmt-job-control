# frozen_string_literal: true

class ContactGenerator
  def self.form_config(form)
    form.field :contact_name,         present: false, filters: :strip
    form.field :contact_surname,      present: false, filters: :strip
    form.field :contact_email,        present: false, filters: :strip
    form.field :contact_phone_number, present: false, filters: :strip
  end

  def initialize(forename, surname, email, phone_number)
    @forename = forename if not forename.nil? and forename.length > 0
    @surname = surname if not surname.nil? and surname.length > 0
    @email = email if not email.nil? and email.length > 0
    @phone_number = phone_number if not phone_number.nil? and phone_number.length > 0
  end

  def generate
    contact = {}
    contact['forename'] = @forename if not @forename.nil?
    contact['surname'] = @surname if not @surname.nil?
    contact['email'] = @email if not @email.nil?
    contact['phoneNumber'] = @phone_number if not @phone_number.nil?
    return contact.length > 0 ? contact : nil
  end
end
