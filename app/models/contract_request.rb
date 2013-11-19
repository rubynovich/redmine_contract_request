class ContractRequest < ActiveRecord::Base
  unloadable

  belongs_to :issue, :dependent => :destroy
  belongs_to :project
  belongs_to :author, :class_name => "User", :foreign_key => "author_id"
  belongs_to :contact
  has_one :status, :through => :issue
  has_one :priority, :through => :issue

  validates_presence_of :contract_type, :contract_subject, :project_id,
    :contact_id, :contract_organization, :contract_price,
    :contract_settlement_procedure, :contract_time, :author_id

  after_create :create_issue

  attr_accessor :priority_id

  acts_as_attachable

  scope :visible, lambda{
    if !User.current.admin? && !User.current.contract_manager?
      where("#{self.table_name}.author_id = ?", User.current.id)
    end
  }

  scope :issue_status, lambda {|q|
    if q.present?
      {:conditions =>
        ["#{self.table_name}.issue_id IN (SELECT #{Issue.table_name}.id FROM #{Issue.table_name} WHERE status_id=:status_id)",
        {:status_id => q}]}
    end
  }

  scope :issue_priority, lambda {|q|
    if q.present?
      {:conditions =>
        ["#{self.table_name}.issue_id IN (SELECT #{Issue.table_name}.id FROM #{Issue.table_name} WHERE priority_id=:priority_id)",
        {:priority_id => q}]}
    end
  }

  scope :like_field, lambda {|q, field|
    if q.present?
      {:conditions =>
        ["LOWER(:field) LIKE :p OR :field LIKE :p",
        {:field => field, :p => "%#{q.to_s.downcase}%"}]}
    end
  }

  scope :eql_field, lambda {|q, field|
    if q.present? && field.present?
      where(field => q)
    end
  }

  scope :time_period, lambda {|q, field|
    today = Date.today
    if q.present? && field.present?
      period_start, period_end = case q
                                 when "yesterday"
                                   [ 1.day.ago.beginning_of_day, 1.day.ago.end_of_day ]
                                 when "today"
                                   [ today.beginning_of_day, today.end_of_day ]
                                 when "last_week"
                                   [ 1.week.ago.beginning_of_week, 1.week.ago.end_of_week ]
                                 when "this_week"
                                   [ today.beginning_of_week, today.end_of_week]
                                 when "last_month"
                                   [1.month.ago.beginning_of_month, 1.month.ago.end_of_month]
                                 when "this_month"
                                   [today.beginning_of_month, today.end_of_month]
                                 when "last_year"
                                   [1.year.ago.beginning_of_year, 1.year.ago.end_of_year ]
                                 when "this_year"
                                   [today.beginning_of_year, today.end_of_year ]
                                 end

      {:conditions => ["#{field} BETWEEN ? AND ?", period_start , period_end] }

    end
  }

  def create_issue
    setting = Setting[:plugin_redmine_contract_request]
    issue = Issue.new(
      :status => IssueStatus.default,
      :tracker_id => setting[:tracker_id],
      :project_id => setting[:project_id],
      :assigned_to_id => setting[:assigned_to_id],
      :author => User.current,
      :start_date => Date.today,
      :due_date => Date.today + setting[:duration].to_i.days,
      :priority_id => self.priority_id,
      :subject => ::I18n.t('message_contract_request_issue_subject', :subject => self.contract_subject),
      :description =>
        [:contract_type, :project, :contact, :contract_organization,
        :contract_price, :contract_settlement_procedure,
        :contract_time].map do |item|
          "*#{::I18n.t('field_' + item.to_s, :default => item.to_s.humanize)}:* #{self.send(item)}" if self.send(item).present?
        end.compact.join("\n") + "\n\n" +
        [:contract_other_terms, :contract_attachments].map do |item|
          "*#{::I18n.t('field_' + item.to_s, :default => item.to_s.humanize)}:*\n#{self.send(item)}" if self.send(item).present?
        end.join("\n\n")
    )
    if issue.save
      self.attachments.each do |attachment|
        attachment.copy(
          :container_id => issue.id,
          :container_type => issue.class.name
        ).save
      end

      self.update_attribute(:issue_id, issue.id)
    end
  end

  def attachments_visible?(user=User.current)
    true
#    (respond_to?(:visible?) ? visible?(user) : true) &&
#      user.allowed_to?(self.class.attachable_options[:view_permission], self.project)
  end
end
