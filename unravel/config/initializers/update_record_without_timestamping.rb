module ActiveRecord
  class Base

    def update_record_without_timestamping(with_validation = true)
      class << self
        def record_timestamps; false; end
      end

      save(with_validation)

      class << self
        def record_timestamps; super ; end
      end
    end

  end
end
