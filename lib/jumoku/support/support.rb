module Jumoku
  class JumokuError             < StandardError; end
  class RawTreeError            < JumokuError;   end
  class RawTreeNodeError        < RawTreeError;  end
  class BranchAlreadyExistError < JumokuError;   end
  class ForbiddenCycle          < JumokuError;   end
  class UndefinedNode           < JumokuError;   end
end
