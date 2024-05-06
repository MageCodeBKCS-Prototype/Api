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
class DatasetSerializer < ApplicationSerializer
  attributes :programming_language, :zipfile, :name

  def zipfile
    # url_for(object.zipfile)
    ActiveStorage::Blob.service.path_for(object.zipfile.key)
  end
end
