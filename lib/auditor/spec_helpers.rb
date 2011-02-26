module Auditor
  module SpecHelpers
    include Auditor::Status

    def self.included(base)
      base.class_eval do
        before(:each) do
          disable_auditor
        end

        after(:each) do
          enable_auditor
        end
      end
    end

  end
end


