class FixGuildfordPoliceStationNomisId < ActiveRecord::Migration[5.2]
  def up
    guildford_police = Location.find_by(location_type: 'police', nomis_agency_id: 'GLFD')
    guildford_police&.update!(nomis_agency_id: 'SRY016', key: 'sry016')
  end

  # We don't want to ever revert back to the original value
  def down; end
end
