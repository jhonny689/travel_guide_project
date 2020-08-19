
Country.destroy_all
roma = Country.create(name: "Roman Republic")
carthago = Country.create(name: "Carthage")
sparta = Country.create(name: "Sparta")

City.destroy_all
City.create(name: "Roma", country_id: roma.id)
City.create(name: "Carthago", country_id: carthago.id)
City.create(name: "Spartii", country_id: sparta.id)


User.destroy_all
isa = User.create(f_name: "Isa", l_name: "Solaris", email: "isa.solaris@mail.com")
jon = User.create(f_name: "Jhonny", l_name: "Camoun", email: "jhonny.camoun@mail.com")
ellie = User.create(f_name: "Elyssa", l_name: "Hannonid", email: "dido@mail.com")

Trip.destroy_all
Trip.create(user_id: isa.id)
Trip.create(user_id: jon.id)
Trip.create(user_id: ellie.id)
Trip.create(user_id: isa.id)

Itinerary.destroy_all
Itinerary.create(country_id: Country.first.id, trip_id: Trip.first.id, itinerary_start: "2020/01/01", itinerary_end: "2020/02/01")
Itinerary.create(country_id: Country.second.id, trip_id: Trip.first.id, itinerary_start: "2020/02/01", itinerary_end: "2020/03/01")
Itinerary.create(country_id: Country.third.id, trip_id: Trip.first.id, itinerary_start: "2020/03/01", itinerary_end: "2020/04/01")
Itinerary.create(country_id: Country.first.id, trip_id: Trip.second.id, itinerary_start: "2020/01/01", itinerary_end: "2020/02/01")
Itinerary.create(country_id: Country.second.id, trip_id: Trip.second.id, itinerary_start: "2020/02/01", itinerary_end: "2020/03/01")
Itinerary.create(country_id: Country.first.id, trip_id: Trip.third.id, itinerary_start: "2020/01/01", itinerary_end: "2020/12/01")
Itinerary.create(country_id: Country.first.id, trip_id: Trip.fourth.id, itinerary_start: "2020/09/01", itinerary_end: "2020/12/01")

Trip.all.each{|e|e.sort_dates}
