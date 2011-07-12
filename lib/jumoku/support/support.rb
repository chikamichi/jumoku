module Jumoku
  # Generic error class.
  class JumokuError             < StandardError; end
  # Generic error class for raw builders.
  class RawTreeError            < JumokuError;   end
  # Node-related error class for raw builders.
  class RawTreeNodeError        < RawTreeError;  end
  # Raised when a branch already exist, causing an operation to abort.
  class BranchAlreadyExistError < JumokuError;   end
  # Raised when breaking the connexion constraint, causing an operation to abort.
  class ForbiddenCycle          < JumokuError;   end
  # Raised when a referenced node does not exist.
  class UndefinedNode           < JumokuError;   end
end
