module Contacts
  class FormSubmissionService
    FORM_URL = "https://docs.google.com/forms/u/0/d/e/1FAIpQLScS9e24rAMmied6lSfZBVX2xpJPAzOpPJZrAy3-J9LSt9RLvg/formResponse".freeze
    FORM_ENTRIES = {
      name: "entry.243206244",
      email: "entry.1438955731",
      content: "entry.1389802120"
    }.freeze

    def initialize(name:, email:, content:)
      @name = name
      @email = email
      @content = content
    end

    def call
      submit_form
      true
    rescue StandardError => e
      Rails.logger.error("Contact form error: #{e.class} - #{e.message}")
      false
    end

    private

    def submit_form
      uri = URI.parse(FORM_URL)
      form_data = {
        FORM_ENTRIES[:name] => @name,
        FORM_ENTRIES[:email] => @email,
        FORM_ENTRIES[:content] => @content
      }

      Net::HTTP.post_form(uri, form_data)
    end
  end
end
