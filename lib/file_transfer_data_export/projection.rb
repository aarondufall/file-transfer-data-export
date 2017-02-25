module FileTransferDataExport
  class Projection
    include EntityProjection
    include FileTransfer::Client::Messages::Events

    entity_name :file

    apply Initiated do |initiated|
        SetAttributes.(file, initiated, copy: [
            :file_id,
            :name,
        ])
    end

    apply CopiedToS3 do |initiated|

    end

    apply NotFound do |not_found|

    end
  end
end
