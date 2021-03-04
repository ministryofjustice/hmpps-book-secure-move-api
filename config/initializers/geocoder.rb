# Configuration for Geocoder gem - see https://github.com/alexreisner/geocoder
Geocoder.configure(
  timeout: 5, # geocoding service timeout (secs)
  lookup: :postcodes_io, # name of geocoding service (symbol)
  language: :en, # ISO-639 language code
  use_https: true, # use HTTPS for lookup requests? (if supported)
  units: :mi, # :km for kilometers or :mi for miles
  distances: :spherical, # :spherical or :linear
  always_raise: :all # Exceptions that should not be rescued by default
)
