module Danger
  # This is your plugin class. Any attributes or methods you expose here will
  # be available from within your Dangerfile.
  #
  # To be published on the Danger plugins site, you will need to have
  # the public interface documented. Danger uses [YARD](http://yardoc.org/)
  # for generating documentation from your plugin source, and you can verify
  # by running `danger plugins lint` or `bundle exec rake spec`.
  #
  # You should replace these comments with a public description of your library.
  #
  # @example Ensure people are well warned about merging on Mondays
  #
  #          my_plugin.warn_on_mondays
  #
  # @see  imairi/danger-conflict_checker
  # @tags monday, weekends, time, rattata
  #
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8

  class DangerConflictChecker < Plugin

    # An attribute that you can read/write from your Dangerfile
    #
    # @return   [Array<String>]
    attr_accessor :targetBranch

    @@outputs = ""

    def initialize(dangerfile)
      super
      # Your code
    end
  
    def detect(args=nil)
      puts "Starting detect conflicts."

      puts "Fetch remote branches for comparing to current."
      'git fetch'

      remoteBranches = `git branch -r`
  
      splittedRemoteBranches = remoteBranches.split(/\r\n|\r|\n/)
  
      splittedRemoteBranches.each do |remoteBranch|
         remoteBranch = remoteBranch.delete(" ")
  
         unless targetBranch === remoteBranch.sub(/^origin\//, "") then
             puts "\n\n"
             puts "Skip try merging '#{remoteBranch}' ."
             next
         end
  
         puts "\n\n"
         puts "Try merging '#{remoteBranch}' ."
  
         mergeResults = `git merge #{remoteBranch} --no-commit --no-ff`
  
         splittedResults = mergeResults.split(/\r\n|\r|\n/).compact.delete_if(&:empty?)
         mergeFailedMessage = splittedResults.find { |r| r.match('^Automatic merge failed.*$') }
  
         if !"#{mergeFailedMessage}".empty? then
            puts "   -> It will be conflicted, be careful."
            @@outputs << "#{remoteBranch}\n"
         elsif
            puts "   -> It will be merged safely."
         end

         puts "Reset merge operation."
         `git reset --merge`
      end

      if !@@outputs.empty? then
          puts "\n\n"
          dangerMessage = "WARN: this branch will be conflicted if merge with the below branches.\n"
          dangerMessage << "#{@@outputs}"
          puts dangerMessage
          return dangerMessage
      end
    end  
  end
end
