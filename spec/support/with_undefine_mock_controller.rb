# frozen_string_literal: true

RSpec.shared_context 'with undefine mock controller' do
  let(:undefine_mock_controller) do
    # NB: it is important to undefine the mock controller after the test, otherwise other rspecs may fail
    Object.send(:remove_const, :MockController) if Object.const_defined?(:MockController)
    Rails.application.reload_routes!
  end
end
