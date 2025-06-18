# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


User.create(email: 'test@test.com', name: "Toko", password: '123456', password_confirmation: '123456', role: User.roles[:admin])
User.create(email: 'baka@baka.com', name: "Baka", password: '123456', password_confirmation: '123456')


Toko = User.first
Baka = User.second
elapsed = Benchmark.measure do
  posts = []
  1000.times do |x|
    puts "Creating post #{x}"
    post = Post.new(
    title: "Title #{x}",
    body: "Body #{x} Words go here idk",
    user: Toko)
    
    10.times do |y|
      puts "Creating comment #{y} for post #{x}"
      # Build comments for the post
      post.comments.build(
        body: "comment #{y}",
        user: Baka)
      end
      posts.push(post)
  end
  Post.import(posts, recursive: true)
end

puts "Elapsed time is #{elapsed.real} seconds"
