require 'set'

module Squib

  class Deck

    def group mode, opts = {}, &block
      if groups.include? mode
        puts opts[:msg] if opts.key? :msg
        block.yield
      end
    end

    def enable_group mode
      groups
      @build_groups << mode
    end

    def disable_group mode
      groups
      @build_groups.delete mode
    end

    def groups
      @build_groups ||= Set.new.add(:all)
    end

    def enable_groups_from_env!
      ENV['SQUIB_BUILD_GROUPS'].split(',').each do |grp|
        enable_group grp.strip.to_sym
      end
    end

  end
end
