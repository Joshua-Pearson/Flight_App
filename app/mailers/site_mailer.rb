class SiteMailer < ActionMailer::Base
  default from: ENV['EMAIL_FROM_ADDRESS']
  
  def flight_email(address, flight_id, current_user_id, contact_id)
    @user = User.find(current_user_id)
    @flight = Flight.find(flight_id)
    @contact = Contact.find(contact_id)
    mail(to: address, subject: @user.full_name.to_s.titleize + " has sent you flight info")
  end

  def confirm_user(flight_id, current_user_id)
    @flight = Flight.find(flight_id)
    @user = User.find(current_user_id)
    mail(to: @user.email, subject: "Flight confirmation")
  end

  def daily_email(flight_id, contact_id)
    @flight = Flight.find(flight_id)
    @contact = Contact.find(contact_id)
    @user = @contact.user
    mail(to: @contact.email, subject: "Just a reminder, " + @user.full_name.to_s.titleize + " is flying today")
  end
end