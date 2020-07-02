# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'dashboard outgoing moves' do
  scenario 'as a police user I want to view the outgoing moves today' do

    puts "HELLO"

    # given_I_am_a_police_user
    # given there are two moves in the system for today

    # GET http://localhost:5000/api/v1/moves?filter[status]=requested%2Caccepted%2Ccompleted&filter[date_from]=2020-07-01&filter[date_to]=2020-07-01&filter[from_location_id]=0ee995d1-9390-4e85-9f5a-c6a436716234&include=allocation%2Ccourt_hearings%2Cdocuments%2Cfrom_location%2Cfrom_location.suppliers%2Cprison_transfer_reason%2Cprofile%2Cprofile.person%2Cprofile.person.ethnicity%2Cprofile.person.gender%2Cto_location&page=1&per_page=1 HTTP/1.1
    # GET http://localhost:5000/api/v1/moves?filter[status]=requested%2Caccepted%2Ccompleted&filter[date_from]=2020-07-01&filter[date_to]=2020-07-01&filter[to_location_id]=0ee995d1-9390-4e85-9f5a-c6a436716234&include=allocation%2Ccourt_hearings%2Cdocuments%2Cfrom_location%2Cfrom_location.suppliers%2Cprison_transfer_reason%2Cprofile%2Cprofile.person%2Cprofile.person.ethnicity%2Cprofile.person.gender%2Cto_location&page=1&per_page=1 HTTP/1.1
    # GET http://localhost:5000/api/v1/moves?filter[status]=requested%2Caccepted%2Ccompleted&filter[has_relationship_to_allocation]=false&filter[from_location_id]=0ee995d1-9390-4e85-9f5a-c6a436716234&filter[created_at_from]=2020-06-29&filter[created_at_to]=2020-07-05&filter[move_type]=prison_transfer&sort[by]=created_at&sort[direction]=desc&include=allocation%2Ccourt_hearings%2Cdocuments%2Cfrom_location%2Cfrom_location.suppliers%2Cprison_transfer_reason%2Cprofile%2Cprofile.person%2Cprofile.person.ethnicity%2Cprofile.person.gender%2Cto_location&page=1&per_page=1 HTTP/1.1
    # GET http://localhost:5000/api/v1/moves?filter[status]=proposed&filter[has_relationship_to_allocation]=false&filter[from_location_id]=0ee995d1-9390-4e85-9f5a-c6a436716234&filter[created_at_from]=2020-06-29&filter[created_at_to]=2020-07-05&filter[move_type]=prison_transfer&sort[by]=created_at&sort[direction]=desc&include=allocation%2Ccourt_hearings%2Cdocuments%2Cfrom_location%2Cfrom_location.suppliers%2Cprison_transfer_reason%2Cprofile%2Cprofile.person%2Cprofile.person.ethnicity%2Cprofile.person.gender%2Cto_location&page=1&per_page=1 HTTP/1.1
    # GET http://localhost:5000/api/v1/moves?filter[status]=cancelled&filter[cancellation_reason]=rejected&filter[has_relationship_to_allocation]=false&filter[from_location_id]=0ee995d1-9390-4e85-9f5a-c6a436716234&filter[created_at_from]=2020-06-29&filter[created_at_to]=2020-07-05&filter[move_type]=prison_transfer&sort[by]=created_at&sort[direction]=desc&include=allocation%2Ccourt_hearings%2Cdocuments%2Cfrom_location%2Cfrom_location.suppliers%2Cprison_transfer_reason%2Cprofile%2Cprofile.person%2Cprofile.person.ethnicity%2Cprofile.person.gender%2Cto_location&page=1&per_page=1 HTTP/1.1
    # GET http://localhost:5000/api/v1/allocations?filter[status]=unfilled&filter[from_locations]=0ee995d1-9390-4e85-9f5a-c6a436716234&filter[date_from]=2020-06-29&filter[date_to]=2020-07-05&page=1&per_page=1&include=from_location%2Cmoves%2Cmoves.profile%2Cmoves.profile.person%2Cmoves.profile.person.ethnicity%2Cmoves.profile.person.gender%2Cto_location HTTP/1.1
    # GET http://localhost:5000/api/v1/allocations?filter[status]=filled%2Cunfilled&filter[from_locations]=0ee995d1-9390-4e85-9f5a-c6a436716234&filter[date_from]=2020-06-29&filter[date_to]=2020-07-05&page=1&per_page=1&include=from_location%2Cmoves%2Cmoves.profile%2Cmoves.profile.person%2Cmoves.profile.person.ethnicity%2Cmoves.profile.person.gender%2Cto_location HTTP/1.1
    # GET http://localhost:5000/api/v1/allocations?filter[status]=filled&filter[from_locations]=0ee995d1-9390-4e85-9f5a-c6a436716234&filter[date_from]=2020-06-29&filter[date_to]=2020-07-05&page=1&per_page=1&include=from_location%2Cmoves%2Cmoves.profile%2Cmoves.profile.person%2Cmoves.profile.person.ethnicity%2Cmoves.profile.person.gender%2Cto_location HTTP/1.1
    # GET http://localhost:5000/api/v1/moves?filter[status]=cancelled&filter[date_from]=2020-07-01&filter[date_to]=2020-07-01&filter[from_location_id]=0ee995d1-9390-4e85-9f5a-c6a436716234&include=allocation%2Ccourt_hearings%2Cdocuments%2Cfrom_location%2Cfrom_location.suppliers%2Cprison_transfer_reason%2Cprofile%2Cprofile.person%2Cprofile.person.ethnicity%2Cprofile.person.gender%2Cto_location&page=1&per_page=100 HTTP/1.1
    # GET http://localhost:5000/api/v1/moves?filter[status]=requested%2Caccepted%2Ccompleted&filter[date_from]=2020-07-01&filter[date_to]=2020-07-01&filter[from_location_id]=0ee995d1-9390-4e85-9f5a-c6a436716234&include=allocation%2Ccourt_hearings%2Cdocuments%2Cfrom_location%2Cfrom_location.suppliers%2Cprison_transfer_reason%2Cprofile%2Cprofile.person%2Cprofile.person.ethnicity%2Cprofile.person.gender%2Cto_location&page=1&per_page=100 HTTP/1.1
    # GET http://localhost:5000/api/v1/people/19fa7c4f-133f-4768-bf37-3b3f75fb8b40/images HTTP/1.1
    # GET http://localhost:5000/api/v1/people/a7aac748-faf6-4302-828d-6f1d7a53e6ed/images HTTP/1.1


  end
end
