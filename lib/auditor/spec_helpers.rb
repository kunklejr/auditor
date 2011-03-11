module Auditor
  module SpecHelpers
    include Auditor::Status

    def self.included(base)
      base.class_eval do
        before(:each) do
          disable_auditing
        end

        after(:each) do
          enable_auditing
        end
      end
    end

  end
end


