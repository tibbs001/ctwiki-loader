class ApplicationMailer < ActionMailer::Base
  default from: ENV['WIKI_OWNER_EMAIL']
  layout 'mailer'

  def self.admin_addresses
    ENV['WIKI_ADMIN_EMAILS'].split(",")
  end

end
