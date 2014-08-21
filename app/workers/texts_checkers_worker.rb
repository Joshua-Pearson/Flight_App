class TextsCheckersWorker
  include Sidekiq::Worker
  include Sidetiq::Schedulable

  recurrence backfill: true do
    hourly.minute_of_hour(21)
  end
  
  def perform
    text_flights = Flight.where("departure_time BETWEEN ? AND ?", DateTime.now - 7.hours, DateTime.now - 1.hours)
    if text_flights.empty? == false
      text_flights.each do |flight|
        flight_id = flight.id 
        text_contacts = ContactsFlights.where(["flight_id = ?", flight_id]).map { |flight| flight.contact }
        if text_contacts.empty? == false
          text_contacts.each do |contact|
            contact_id = contact.id   
            user_id = contact.user.id 
            response = Typhoeus.get("https://api.flightstats.com/flex/flightstatus/rest/v2/json/flight/status/" + flight.airline_code.to_s + "/" + flight.flight_number.to_s + "/dep/" + flight.date_year.to_s + "/" + flight.date_month.to_s + "/" + flight.date_day.to_s + "?appId=" + ENV['API_ID'].to_s + "&appKey=" + ENV['APP_KEY'].to_s + "&utc=false")
            body = JSON.parse(response.body)
            flight.departure_terminal = body["flightStatuses"][0]["airportResources"]["departureTerminal"]
            flight.departure_gate = body["flightStatuses"][0]["airportResources"]["departureGate"]
            flight.arrival_terminal = body["flightStatuses"][0]["airportResources"]["arrivalTerminal"]
            flight.arrival_gate = body["flightStatuses"][0]["airportResources"]["arrivalGate"]
            flight.baggage_claim = body["flightStatuses"][0]["airportResources"]["baggage"]
            flight.save
            ContactsTextsWorker.perform_async(flight_id, contact_id, user_id)
            UsersTextsWorker.perform_async(flight_id, user_id)
          end
        end
      end
    end    
  end
end