module FileTransferDataExport
  module Handlers
    class Events
      include Messaging::Handle
      include Messaging::StreamName
      include FileTransferComponent::Messages::Commands
      include FileTransferComponent::Messages::Events
      include Log::Dependency

      dependency :store, FileTransferComponent::Store

      def configure
        FileTransferComponent::Store.configure self
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
