module ContractRequestsHelper
  def contract_type_for_select
    t(:contract_type, :scope => :contract_requiest)
  end

  def contract_organization_for_select
    t(:contract_organization, :scope => :contract_requiest)
  end

  def contract_settlement_procedure_for_select
    t(:contract_settlement_procedure, :scope => :contract_requiest)
  end

  def author_id_for_select
    ContractRequest.select(:author_id).uniq.all.select(&:author_id).map(&:author)
  end

  def status_id_for_select
    IssueStatus.all
  end

  def time_periods
    %w{yesterday last_week this_week last_month this_month last_year this_year}
  end

  def contract_price(item)
    ActionController::Base.helpers.number_to_currency(item.contract_price,
        :unit => '',
        :separator => '.',
        :delimiter => ' ',
        :precision => 2)
  end
end
