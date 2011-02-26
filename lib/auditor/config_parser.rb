module Auditor
  class ConfigParser

    def self.extract_config(args)
      options = (args.pop if args.last.kind_of?(Hash)) || {}
      normalize_config args, options
      validate_config args, options
      options = normalize_options(options)

      [args, options]
    end

    private

      def self.normalize_config(actions, options)
        actions.each_with_index { |item, index| actions[index] = item.to_sym }
        options.each_pair { |k, v| options[k.to_sym] = options.delete(k) unless k.kind_of? Symbol }
      end

      def self.normalize_options(options)
        return { :except => [], :only => [] } if options.nil? || options.empty?
        options[:except] = options[:except] || []
        options[:only] = options[:only] || []
        options[:except] = Array(options[:except]).map(&:to_s)
        options[:only] = Array(options[:only]).map(&:to_s)
        options
      end

      def self.validate_config(actions, options)
        raise StandardError.new "at least one :create, :find, :update, or :destroy action must be specified" if actions.empty?
        raise StandardError.new ":create, :find, :update, and :destroy are the only valid actions" unless actions.all? { |a| [:create, :find, :update, :destroy].include? a }
        raise StandardError.new "only one of :except and :only can be specified" if options.size > 1
      end

  end
end
