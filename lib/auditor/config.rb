module Auditor
  class Config
    attr_reader :actions
    attr_reader :options

    def self.valid_actions
      @valid_actions ||= [:create, :find, :update, :destroy]
    end

    def self.default_except
      @default_except ||= ['id', 'lock_version', 'created_at', 'created_on', 'updated_at', 'updated_on']
    end

    def initialize(args)
      @options = (args.pop if args.last.kind_of?(Hash)) || {}
      @actions = args
      normalize_options(@options)
      @options[:except].push(*Config.default_except)
      normalize_actions(@actions)
      validate_actions(@actions)
    end

    private

      def normalize_actions(actions)
        actions.each_with_index { |item, index| actions[index] = item.to_sym }
      end

      def normalize_options(options)
        if options.empty?
          options[:except] = []
          options[:only] = []
        else
          options.each_pair { |k, v| options[k.to_sym] = options.delete(k) unless k.kind_of? Symbol }
          options[:except] = options[:except] || []
          options[:only] = options[:only] || []
          options[:except] = Array(options[:except]).map(&:to_s)
          options[:only] = Array(options[:only]).map(&:to_s)
        end
      end

      def validate_actions(actions)
        raise StandardError.new "at least one action in #{Config.valid_actions.join(',')} must be specified" if actions.empty?
        raise StandardError.new "#{Config.valid_actions.join(',')} are the only valid actions" unless actions.all? { |a| Config.valid_actions.include?(a) }
      end

  end
end
