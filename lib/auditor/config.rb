module Auditor
  class Config
    attr_reader :actions
    attr_reader :options

    def self.valid_actions
      @valid_actions ||= [:create, :find, :update, :destroy]
    end

    def initialize(*args)
      @options = (args.pop if args.last.kind_of?(Hash)) || {}
      normalize_options(@options)

      @actions = args.map(&:to_sym)
      validate_actions(@actions)
    end

  private

    def normalize_options(options)
      options.each_pair { |k, v| options[k.to_sym] = options.delete(k) unless k.kind_of? Symbol }
      options[:only] ||= []
      options[:except] ||= []
      options[:only] = Array(options[:only]).map(&:to_s)
      options[:except] = Array(options[:except]).map(&:to_s)
    end

    def validate_actions(actions)
      raise Auditor::Error.new "at least one action in #{Config.valid_actions.inspect} must be specified" if actions.empty?
      raise Auditor::Error.new "#{Config.valid_actions.inspect} are the only valid actions" unless actions.all? { |a| Config.valid_actions.include?(a.to_sym) }
    end

  end
end
