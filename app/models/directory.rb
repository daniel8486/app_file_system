class Directory < ApplicationRecord
  belongs_to :parent, class_name: "Directory", optional: true
  has_many :subdirectories, class_name: "Directory", foreign_key: "parent_id", dependent: :destroy, inverse_of: :parent
  has_many :storage_files, dependent: :destroy

  validates :name, presence: true, uniqueness: { scope: :parent_id }
  validates :parent, presence: true, if: -> { parent_id.present? }
  validate :validate_parent_relationship
  def dir_path
    DirectoryPathService.new(self).build
  end

  private
  def descendant_ids
   subdirectories.flat_map { |child| [ child.id ] + child.descendant_ids }
  end
  def validate_parent_relationship
    return if parent_id.blank?
    if parent.nil?
      errors.add(:parent, "deve se referir a um diretório existente")
    elsif parent == self
      errors.add(:parent, "não pode ser o próprio diretório")
    elsif parent_is_descendant?(parent)
      errors.add(:parent, "não pode ser um descendente — isso causaria um ciclo")
    end
  end

  protected
  def parent_is_descendant?(potential_ancestor)
    subdirectories.any? do |child|
      child == potential_ancestor || child.parent_is_descendant?(potential_ancestor)
    end
  end
end
