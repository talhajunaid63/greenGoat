class Product < ApplicationRecord
  has_many_attached :images

  belongs_to :category
  belongs_to :sub_category, class_name: 'Category', foreign_key: 'sub_category_id'

  has_many :sales, dependent: :destroy
  has_many :project_products, dependent: :destroy
  has_many :projects, through: :project_products
  has_many :product_statuses, dependent: :destroy

  enum status: {
    'available' => 0,
    'listed_for_sale' => 1,
    'has_interest' => 2,
    'scheduled_buyer_meeting' => 3,
    'declined / waiting for other prospects' => 4,
    'took_deposit' => 5,
    'sold' => 6,
    'uninstalled / ready for pickup' => 7,
    'picked up' => 8,
    'returned / broken' => 9
  }

  enum payment_status: [:pending, :received]

  validates_presence_of :category_id, :title
  validates :sale_price, numericality: { other_than: 0.0 }
  validates_presence_of :weight, if: :material_types_present?

  before_save :convert_percentage_to_kg, if: :material_or_weight_changed?

  scope :available_products, ->  { joins(:product_statuses).where.not('product_statuses.new_status = ?', 6).distinct }
  scope :wating_for_uninstallation, -> { available_products.where(need_uninstallation: true) }

  def product_status
    product_statuses.last.new_status
  end

  def to_s
    title
  end

  def convert_weight_to_percentage(material_weight)
    return 0 if material_weight.blank? || material_weight == 0

    ((material_weight / weight) * 100).round(2)
  end

  def sold!
    product_statuses.create(new_status: 6)
  end

  private

  def material_types_present?
    wood || ceramic || glass || metal || stone_plastic
  end

  def weight_present?
    weight.present?
  end

  def material_or_weight_changed?
    weight_changed? || wood_changed? || ceramic_changed? || glass_changed? || metal_changed? || stone_plastic_changed?
  end

  def convert_percentage_to_kg
    return if weight.blank?

    self.wood = calculate_weight_from_precentage(wood)
    self.ceramic = calculate_weight_from_precentage(ceramic)
    self.glass = calculate_weight_from_precentage(glass)
    self.metal = calculate_weight_from_precentage(metal)
    self.stone_plastic = calculate_weight_from_precentage(stone_plastic)
    self.other = (weight - (wood + ceramic + glass + metal + stone_plastic)).round(2)
  end

  def calculate_weight_from_precentage(material_percentage)
    return 0 if material_percentage.blank? || material_percentage == 0

    (weight * (material_percentage / 100)).round(2)
  end
end
