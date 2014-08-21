class FlightsController < ApplicationController

  def new
    @flight = Flight.new
  end

  def create
    @flight = Flight.new flight_params
    @flight.user = current_user
    if @flight.save
      flight = @flight
      UserEmailsWorker.perform_async(flight.id, current_user.id)
      recipients = params["flight"]["contacts"]
      if recipients != nil
        recipients.each do |id|
          ContactsFlights.create(contact_id: id, flight_id: flight.id)
          contact = Contact.find(id)
          address = contact.email
          ContactsEmailsWorker.perform_async(address, flight.id, current_user.id, contact.id)
        end
      end
    end
    respond_to do |format|
      if @flight.save
        format.json { render json: @flight, status: :created }
      else
        format.json { render json: @flight.errors, status: :unprocessable_entity }
      end
    end
  end

private
  def flight_params
    params.require(:flight).permit(:flight_number, :airline_name, :date_year, :date_month, :date_day, :departure_airport, :arrival_airport, :stops, :departure_time, :arrival_time, :airline_code, :departure_city, :arrival_city)
  end
end
