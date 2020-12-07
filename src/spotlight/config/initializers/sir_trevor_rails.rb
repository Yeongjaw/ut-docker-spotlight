class SirTrevorRails::Block
    def self.custom_block_types
        # get sir trevor widgets from engine config in engine.rb
        Spotlight::Engine.config.sir_trevor_widgets
    end
end