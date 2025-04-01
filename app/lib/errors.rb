module Errors
  class EmailTooLongError < StandardError
  end

  class AccountAlreadyExistsError < StandardError
  end

  def self.log_error(description, error = nil)
    Rails.logger.error({
                         '@timestamp': Time.now.iso8601,
                        description: description,
                        message: error ? error.message : nil,
                        backtrace: error ? error.backtrace.join("\n") : nil
                       }.to_json)
    nil
  end
end
