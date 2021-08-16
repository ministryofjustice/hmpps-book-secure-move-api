# frozen_string_literal: true

require 'rails_helper'

RSpec.describe V2::People::Finder do
  subject(:finder) { described_class.new(filter_params) }

  let!(:person) { (create :person) }
  let(:filter_params) { {} }

  describe 'filtering' do
    describe 'by police_national_computer' do
      context 'with matching police_national_computer' do
        let(:filter_params) { { police_national_computer: 'AB/00006' } }
        let!(:person) { create(:person, police_national_computer: 'AB/00006') }

        it 'returns people matching police_national_computer' do
          expect(finder.call).to contain_exactly(person)
        end
      end

      context 'with multiple police_national_computer values' do
        let(:filter_params) { { police_national_computer: 'AB/00006,AB/00007' } }
        let!(:person1) { create(:person, police_national_computer: 'AB/00006') }
        let!(:person2) { create(:person, police_national_computer: 'AB/00007') }

        it 'returns people matching police_national_computer' do
          expect(finder.call).to contain_exactly(person1, person2)
        end
      end

      context 'with mis-matching police_national_computer' do
        let(:filter_params) { { police_national_computer: 'foo' } }

        it 'returns empty results set' do
          expect(finder.call).to be_empty
        end
      end

      context 'with nil police_national_computer' do
        let(:filter_params) { { police_national_computer: nil } }
        let!(:person) { create(:person, police_national_computer: nil) }

        it 'returns only people without a police_national_computer' do
          expect(finder.call).to contain_exactly(person)
        end
      end
    end

    describe 'by criminal_records_office' do
      context 'with matching criminal_records_office' do
        let(:filter_params) { { criminal_records_office: 'CR00006' } }
        let!(:person) { create(:person, criminal_records_office: 'CR00006') }

        it 'returns people matching criminal_records_office' do
          expect(finder.call).to contain_exactly(person)
        end
      end

      context 'with multiple criminal_records_offices' do
        let(:filter_params) { { criminal_records_office: 'CR00006,CR00007' } }
        let!(:person1) { create(:person, criminal_records_office: 'CR00006') }
        let!(:person2) { create(:person, criminal_records_office: 'CR00007') }

        it 'returns people matching criminal_records_office' do
          expect(finder.call).to contain_exactly(person1, person2)
        end
      end

      context 'with mis-matching criminal_records_office' do
        let(:filter_params) { { criminal_records_office: 'foo' } }

        it 'returns empty results set' do
          expect(finder.call).to be_empty
        end
      end

      context 'with nil criminal_records_office' do
        let(:filter_params) { { criminal_records_office: nil } }
        let!(:person) { create(:person, criminal_records_office: nil) }

        it 'returns only people without a criminal_records_office' do
          expect(finder.call).to contain_exactly(person)
        end
      end
    end

    describe 'by prison_number' do
      context 'with matching prison_number' do
        let(:filter_params) { { prison_number: 'd00006' } }
        let!(:person) { create(:person, prison_number: 'D00006') }

        it 'returns people matching prison_number' do
          expect(finder.call).to contain_exactly(person)
        end
      end

      context 'with multiple prison_numbers' do
        let(:filter_params) { { prison_number: 'D00006,D00007' } }
        let!(:person1) { create(:person, prison_number: 'D00006') }
        let!(:person2) { create(:person, prison_number: 'D00007') }

        it 'returns people matching prison_number' do
          expect(finder.call).to contain_exactly(person1, person2)
        end
      end

      context 'with mis-matching prison_number' do
        let(:filter_params) { { prison_number: 'foo' } }

        it 'returns empty results set' do
          expect(finder.call).to be_empty
        end
      end

      context 'with nil prison_number' do
        let(:filter_params) { { prison_number: nil } }
        let!(:person) { create(:person, prison_number: nil) }

        it 'returns only people without a prison_number' do
          expect(finder.call).to contain_exactly(person)
        end
      end
    end

    context 'with multiple matching filters' do
      let(:filter_params) do
        {
          police_national_computer: 'ab/00006',
          prison_number: 'd00007',
          criminal_records_office: 'cr00006',
        }
      end

      let!(:person) do
        create(:person, police_national_computer: 'AB/00006', prison_number: 'D00007', criminal_records_office: 'CR00006')
      end

      it 'does not return people if filters do not all match records' do
        expect(finder.call).to contain_exactly(person)
      end
    end

    context 'with multiple mismatching filters' do
      let(:filter_params) do
        {
          police_national_computer: 'AB/00006',
          prison_number: 'D00007',
          criminal_records_office: 'CR00006',
        }
      end

      before do
        create(:person, police_national_computer: 'AB/00006')
        create(:person, prison_number: 'D00007')
        create(:person, criminal_records_office: 'CR00006')
      end

      it 'does not return people if filters do not all match records' do
        expect(finder.call).to be_empty
      end
    end
  end
end
