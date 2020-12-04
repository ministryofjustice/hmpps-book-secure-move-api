module FeatureFlags
  def enable_feature!(feature_name)
    allow(Flipper).to receive(:enabled?).with(feature_name).and_return(true)
  end

  def disable_feature!(feature_name)
    allow(Flipper).to receive(:enabled?).with(feature_name).and_return(false)
  end
end

RSpec.configure do |config|
  config.include FeatureFlags
end
