class UsersTextsWorker
  include Sidekiq::Worker

  def perform(flight_id, user_id)
    TwilioTexter.send_user_text(flight_id, user_id)
  end
end