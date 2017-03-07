module FileTransferDataExport
  class File
    include Schema::DataStructure

    attribute :file_id, String
    attribute :name, String
    attribute :key, String
    attribute :bucket, String
    attribute :region, String

    def not_found?
      !not_found_time.nil?
    end

    def stored_permanently?
      !permanent_storage_time.nil?
    end
  end
end
