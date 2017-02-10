module FileTransferComponent
  module Handlers
    class Commands
      include Messaging::Handle
      include Messaging::StreamName
      include FileTransferComponent::Messages::Commands
      include FileTransferComponent::Messages::Events
      include Log::Dependency

      dependency :write, Messaging::Postgres::Write
      dependency :clock, Clock::UTC

      def configure
        Messaging::Postgres::Write.configure self
        Clock::UTC.configure self
      end

      category :file


=begin

  Now draw the rest of the owl :)

      _________
     /_  ___   \
    /@ \/@  \   \
    \__/\___/   /
     \_\/______/
     /     /\\\\\
    |     |\\\\\\
     \      \\\\\\\
       \______/\\\\\
        _||_||_
=end

    end
  end
end
