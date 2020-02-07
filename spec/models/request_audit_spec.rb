require 'rails_helper'

RSpec.describe RequestAudit, type: :model do
  it 'belongs to an application' do
    expect(build(:request_audit).application).not_to be_nil
  end

  it 'can be persisted' do
    expect(create(:request_audit)).not_to be_nil
  end
end
