class AccountDetailsForm
  include ActiveModel::Model

  # Max account name length allowed in AWS is 64 characters
  AWS_ROOT_ACCOUNTS_EMAIL_BASE_LENGTH = 30
  MAX_EMAIL_LENGTH = 64
  MAX_ACCOUNT_NAME_LENGTH = MAX_EMAIL_LENGTH - AWS_ROOT_ACCOUNTS_EMAIL_BASE_LENGTH

  attr_reader :account_name, :account_description

  validates_format_of :account_name, with: /\A([a-z]+-)*[a-z]+\z/, message: 'should be lower-case-separated-by-dashes'
  validates_format_of :account_name, with: /\A([a-z]+-){0,4}[a-z]+\z/, message: 'should not have more-than-five-groups-separated-by-dashes'

  validates :account_name, length: { maximum: MAX_ACCOUNT_NAME_LENGTH, message: "should not be longer than #{MAX_ACCOUNT_NAME_LENGTH} characters" }
  validates :account_description, presence: true, length: { maximum: 256 }

  validates_format_of :account_name,
                      :account_description,
                      with: AwsTagValueValidator.allowed_chars_regexp,
                      message: AwsTagValueValidator.allowed_chars_message

  def initialize(hash)
    params = hash.with_indifferent_access
    @account_name = params[:account_name]
    @account_description = params[:account_description]
  end
end
