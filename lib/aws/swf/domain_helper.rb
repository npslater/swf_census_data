require 'aws/flow'

module DomainHelper

  @@swf = AWS::SimpleWorkflow.new
  @@domain = nil

  def DomainHelper.init_domain(domain_name)

    begin
      @@domain = @@swf.domains[domain_name]
      @@domain.status
    rescue AWS::SimpleWorkflow::Errors::UnknownResourceFault => e
      @@domain = @@swf.domains.create(domain_name, '10')
    end
  end

  def DomainHelper.swf
    @@swf
  end

  def DomainHelper.domain
    raise 'Domain has not been initialized' unless @@domain
    @@domain
  end

end