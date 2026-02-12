# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::People::PncNormalizer do
  it 'handles 2-digit year and unpadded number' do
    variants = described_class.variants('14/12018R')
    expect(variants).to include('14/0012018R')
  end

  it 'handles 4-digit year and unpadded' do
    variants = described_class.variants('2014-12018r')
    expect(variants).to include('2014/0012018R')
  end

  it 'matches 2-digit search against 4-digit DB' do
    db = create(:person, police_national_computer: '2014/0120018R')
    db.reload
    expect(Person.filter_by_pnc_canonical('14/0120018R')).to include(db)
  end

  it 'matches 4-digit search against 2-digit DB' do
    db = create(:person, police_national_computer: '14/0120018R')
    db.reload
    expect(Person.filter_by_pnc_canonical('2014/0120018R')).to include(db)
  end

  it 'matches unpadded search against padded DB' do
    db = create(:person, police_national_computer: '2014/0120018R')
    db.reload
    expect(Person.filter_by_pnc_canonical('2014/120018R')).to include(db)
  end
end
