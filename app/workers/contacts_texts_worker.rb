class ContactsTextsWorker
  include Sidekiq::Worker

  def perform(flight_id, contact_id, current_user_id)
    TwilioTexter.send_contact_text(flight_id, contact_id, current_user_id)
  end
end







