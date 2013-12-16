require 'aws/flow'
require 'aws-sdk'

module DomainHelper

  @@swf = AWS::SimpleWorkflow.new(:access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'])
  @@s3 = AWS::S3.new(:access_key_id => ENV['AWS_ACCESS_KEY_ID'], :secret_access_key => ENV['AWS_SECRET_ACCESS_KEY'])
  @@domain = nil

  def init_domain(domain_name)

    begin
      @@domain = @@swf.domains[domain_name]
      @@domain.status
    rescue AWS::SimpleWorkflow::Errors::UnknownResourceFault => e
      @@domain = @@swf.domains.create(domain_name, '10')
    end
  end

  def swf
    @@swf
  end

  def domain
    raise 'Domain has not been initialized' unless @@domain
    @@domain
  end

  def s3
    @@s3
  end

end