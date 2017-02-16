puts RUBY_DESCRIPTION

require_relative 'logger_settings'

require_relative '../init.rb'

require 'test_bench'; TestBench.activate

require 'file_transfer_data_export/controls'

require 'pp'

include FileTransferDataExport
