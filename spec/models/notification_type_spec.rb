require 'rails_helper'

RSpec.describe NotificationType, type: :model do
  it { is_expected.to have_many(:notifications) }
  it { is_expected.to validate_presence_of(:title) }
end
