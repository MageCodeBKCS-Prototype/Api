# == Schema Information
#
# Table name: datasets
#
#  id                   :bigint           not null, primary key
#  file_count           :integer
#  name                 :string(255)
#  programming_language :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  user_id              :bigint           default(8746177907326382093), not null
#
# Indexes
#
#  index_datasets_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class Dataset < ApplicationRecord
  MAX_ZIP_SIZE = 10.megabytes

  has_one_attached :zipfile
  has_many :reports, dependent: :destroy

  validates :zipfile,
            attached: true,
            content_type: 'application/zip',
            size: { less_than: MAX_ZIP_SIZE }

  validates :name, presence: true, length: { minimum: 3, maximum: 255 }
  # validates :programming_language, presence: true, length: { minimum: 1, maximum: 255 }

  before_validation :ensure_name

  def purge_files!
    return unless zipfile.attached?

    zipfile.purge
  end

  def zipfile_path
    ActiveStorage::Blob.service.path_for(zipfile.key)
  end

  private

  def ensure_name
    return unless zipfile.attached?

    self.name ||= zipfile.filename.base
  end

end
