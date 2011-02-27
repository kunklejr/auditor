module Auditor
  class Config
    attr_reader :actions
    attr_reader :options

    def self.default_actions
      @default_actions ||= [:create, :find, :udate, :destroy]
    end

    def self.default_except
      @default_accept ||= [:lock_version, :created_at, :created_on, :updated_at, :updated_on]
    end

    def initialize(args)
      @options = (args.pop if args.last.kind_of?(Hash)) || {}
      @actions = args
      normalize_options(@options)
      normalize_actions(@actions)
      validate_config(@actions, @options)
    end

    private

      def normalize_actions(actions)
        actions.each_with_index { |item, index| actions[index] = item.to_sym }
      end

      def normalize_options(options)
        if options.empty?
          options[:except] = Config.default_except
          options[:only] = []
        else
          options.each_pair { |k, v| options[k.to_sym] = options.delete(k) unless k.kind_of? Symbol }
          options[:except] = Config.default_except.merge(options[:except])
          options[:only] = options[:only] || []
          options[:except] = Array(options[:except]).map(&:to_s)
          options[:only] = Array(options[:only]).map(&:to_s)
        end
      end

      def validate_config(actions, options)
        raise StandardError.new "at least one #{Config.default_actions.join(',')} action must be specified" if actions.empty?
        raise StandardError.new "#{Config.default_actions.join(',')} are the only valid actions" unless actions.all? { |a| Config.default_actions.include?(a) }
      end

  end
end
