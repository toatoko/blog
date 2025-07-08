# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require 'ostruct'

def seed_users
  toko = User.create(
    email: 'test@test.com',
    first_name: "Toko",
    last_name: "Toa",
    password: '123456',
    password_confirmation: '123456',
    role: User.roles[:admin]
  )

  baka = User.create(
    email: 'baka@baka.com',
    first_name: "Baka",
    last_name: "Yasso",
    password: '123456',
    password_confirmation: '123456'
  )
end
def seed_addresses
  Address.create(
    street: "123 Main St",
    city: "Anytown",
    state: "CA",
    zip: "12345",
    country: "KSA",
    user: User.first
    )
    
    Address.create(
      street: "123 Main St",
      city: "Anytown",
      state: "CA",
      zip: "12345",
      country: "KSA",
      user: User.second
    )
end    
def seed_categories
  Category.create(name: "Uncategorized")
  Category.create(name: "Medicine")
  Category.create(name: "Coding")
  Category.create(name: "Sports")

end
def seed_posts_and_comments
  10.times do |x|
    toko = User.first
    baka = User.second
    puts "Creating post #{x}"
    post = Post.create!(
      title: "Title #{x}",
      body: "Body #{x} Words go here idk",
      user: toko
    )

    5.times do |y|
      puts "Creating comment #{y} for post #{x}"
      Comment.create!(
      body: "comment #{y}",
      user: baka,
      post: post
     )
    end
  end
end
# def seed_ahoy
#   Ahoy.geocode = false
#   request = OpenStruct.new(
#     params: {},
#     referer: "https://example.com",
#     remote_ip: "0.0.0.0",
#     user_agent: "Internet Explorer",
#     original_url: "rails"
#   )

#   visit_properties = Ahoy::VisitProperties.new(request, api: nil)

#   properties = visit_properties.generate.select { |_,v| v}

#   example_visit = Ahoy::Visit.create!(properties.merge(
#     visit_token: SecureRandom.uuid,
#     visitor_token: SecureRandom.uuid,
#   ))

#   2.months.ago.to_date.upto(Date.today) do |date|
#     Post.all.each do |post|
#       rand(1..5).times do |x|
#         Ahoy::Event.create!(name: "Viewed Post",
#         visit: example_visit,
#         properties: {post_id: post.id},
#         time: date.to_time + rand(0..23).hours + rand(0..59).minutes)
#       end
#     end
#   end
# end


elapsed = Benchmark.measure do
  puts "Seeding development data..."
  seed_users
  seed_addresses
  seed_categories
  seed_posts_and_comments
  # seed_ahoy
end
puts "Seeded DB in #{elapsed.real} seconds"
