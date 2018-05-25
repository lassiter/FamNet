class DirectoryMemberSerializer < ActiveModel::Serializer
  attributes :id, :name, :surname, :image

  def name
    object.name
  end
  def surname
    object.surname
  end
end
