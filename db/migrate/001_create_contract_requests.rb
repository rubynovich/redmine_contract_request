class CreateContractRequests < ActiveRecord::Migration
  def change
    create_table :contract_requests do |t|
      t.string :contract_type
      t.string :contract_subject
      t.integer :project_id
      t.integer :contact_id
      t.string :contract_organization
      t.string :contract_price
      t.string :contract_settlement_procedure
      t.string :contract_time
      t.text :contract_other_terms
      t.text :contract_attachments
      t.integer :author_id
      t.integer :issue_id
      t.datetime :updated_on
      t.datetime :created_on
    end
  end
end
