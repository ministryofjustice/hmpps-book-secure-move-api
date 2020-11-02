class SplitWhodunnitFromVersions < ActiveRecord::Migration[6.0]
  def up
    count = 0

    PaperTrail::Version.all.each do |version|
      next if version.whodunnit.blank?

      begin
        Supplier.find(version.whodunnit)
      rescue ActiveRecord::RecordNotFound
        next
      end

      version.update_attributes(supplier_id: version.whodunnit, whodunnit: nil)
      count += 1
    end

    p "Changed #{count} PaperTrail::Versions from whodunnit to supplier_id"
  end

  def down
    count = 0

    PaperTrail::Version.where.not(supplier_id: nil).each do |version|
      version.update_attributes(supplier_id: nil, whodunnit: version.supplier_id)
      count += 1
    end

    p "Changed #{count} PaperTrail::Versions from supplier_id to whodunnit"
  end
end
