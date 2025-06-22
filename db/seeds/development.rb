# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Seeding development data..."

Toko = User.first_or_create!(
  email: 'test@test.com',
  first_name: "Toko",
  last_name: "Toa",
  password: '123456',
  password_confirmation: '123456',
  role: User.roles[:admin]
)

Baka = User.first_or_create!(
  email: 'baka@baka.com',
  first_name: "Baka",
  last_name: "Yasso",
  password: '123456',
  password_confirmation: '123456'
)

Address.first_or_create!(
  street: "123 Main St",
  city: "Anytown",
  state: "CA",
  zip: "12345",
  country: "KSA",
  user: Toko
  )
  
  Address.first_or_create!(
    street: "123 Main St",
    city: "Anytown",
    state: "CA",
    zip: "12345",
    country: "KSA",
    user: Baka
    )
    
Category.find_or_create_by!(name: "Uncategorized")
elapsed = Benchmark.measure do

  10.times do |x|
    puts "Creating post #{x}"
    post = Post.new(
      title: "Title #{x}",
      body: "Body #{x} Words go here idk",
      user: Toko
    )

    5.times do |y|
      puts "Creating comment #{y} for post #{x}"
      post.comments.build(
        body: "comment #{y}",
        user: Baka
      )
    end

    post.save!
  end
end
puts "Seeded development DB in #{elapsed.real} seconds"
