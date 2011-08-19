module Bagatela
  module Graph
    class Stop < Hub
      has_n(:transfers).to(Stop).relationship(Transfer)
    end
  end
end
