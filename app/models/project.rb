class Project < ApplicationRecord
  has_many :tasks
  has_many :products
  has_many :group_items

  belongs_to :pm, class_name: 'AdminUser', foreign_key: 'pm_id'
  belongs_to :appraiser, class_name: 'AdminUser', foreign_key: 'appraiser_id'
  belongs_to :contractor, class_name: 'AdminUser', foreign_key: 'contractor_id'

  accepts_nested_attributes_for :tasks, allow_destroy: true
  accepts_nested_attributes_for :group_items, allow_destroy: true

  enum type_of_project: [:gut, :full, :kitchen, :other]
  enum status: [:not_pursuing, :appraisal_notes, :propsal, :contract]
end
