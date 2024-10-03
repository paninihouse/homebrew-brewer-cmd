# frozen_string_literal: true

require "formula"
require "json"

module Homebrew
  module Cmd
    class BrewerTapContentInfo < AbstractCommand
      cmd_args do
        description <<~EOS
          Do something. Place a description here.
        EOS
        flag "--json",
             description: "Print a JSON representation. Currently the default value for <version> is `v1` for " \
                          "<formula>. For <formula> and <cask> use `v2`. See the docs for examples of using the " \
                          "JSON output: <https://docs.brew.sh/Querying-Brew>"
        switch "--formula", "--formulae",
               description: "Treat all named arguments as formulae."
        switch "--cask", "--casks",
               description: "Treat all named arguments as casks."
        conflicts "--formula", "--cask"
        
        named_args [:tap]
      end
      
      def run
        formulae = []
        casks = []
        
        Tap.each do |tap|
          next if ["homebrew/core", "homebrew/cask"].include?(tap.name)
          
          unless args.cask?
            tap.formula_files.each do |formula_file|
              formulae << Formulary.factory(formula_file)
            end
          end
          
          unless args.formula?
            tap.cask_files.each do |cask_file|
              casks << Cask::CaskLoader::FromPathLoader.new(cask_file).load(config: nil)
            end
          end
        end
        
        json = {
          "formulae": formulae.map(&:to_hash),
          "casks": casks.map(&:to_h)
        }
        
        puts JSON.pretty_generate(json)
      end
    end
  end
end
