# TODO: Remove this once we've migrated all documents that were previously in a Move
# to their Profile
class DocumentMover
  def initialize(document)
    @document = document
    @documentable = @document&.documentable
    @move = @document&.move
    @profile = @move&.profile
  end

  def call
    # Means we already have a documentable
    return true if @documentable
    # Means one or all of: no document, no move and no profile
    return true unless @profile

    @document.update!(move: nil, documentable: @profile)
  end
end
