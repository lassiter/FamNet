# 
include ActionDispatch::TestProcess
FactoryBot.define do
require 'pry'
  factory :media do
    original_filename "test.jpg"
    file { fixture_file_upload(Rails.root.to_s + '/spec/fixtures/dummy_image.jpg', 'image/jpg') }
  end
end
