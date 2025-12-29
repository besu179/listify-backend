# db/seeds.rb

puts "Seeding data..."

# Albums
thriller = Album.find_or_create_by!(title: "Thriller", artist_name: "Michael Jackson") do |a|
  a.cover_url = "https://example.com/thriller.jpg"
  a.deezer_id = 101
end

abbey_road = Album.find_or_create_by!(title: "Abbey Road", artist_name: "The Beatles") do |a|
  a.cover_url = "https://example.com/abbey_road.jpg"
  a.deezer_id = 102
end

ram = Album.find_or_create_by!(title: "Random Access Memories", artist_name: "Daft Punk") do |a|
  a.cover_url = "https://example.com/ram.jpg"
  a.deezer_id = 103
end

puts "Created Albums: #{Album.count}"

# Songs
songs_data = [
  { title: "Billie Jean", artist_name: "Michael Jackson", album: thriller, duration_ms: 294000, deezer_id: 1001, preview_url: "https://example.com/billie_jean.mp3" },
  { title: "Beat It", artist_name: "Michael Jackson", album: thriller, duration_ms: 258000, deezer_id: 1002, preview_url: "https://example.com/beat_it.mp3" },
  { title: "Thriller", artist_name: "Michael Jackson", album: thriller, duration_ms: 357000, deezer_id: 1003, preview_url: "https://example.com/thriller.mp3" },

  { title: "Come Together", artist_name: "The Beatles", album: abbey_road, duration_ms: 259000, deezer_id: 1004, preview_url: "https://example.com/come_together.mp3" },
  { title: "Something", artist_name: "The Beatles", album: abbey_road, duration_ms: 180000, deezer_id: 1005, preview_url: "https://example.com/something.mp3" },
  { title: "Here Comes The Sun", artist_name: "The Beatles", album: abbey_road, duration_ms: 185000, deezer_id: 1006, preview_url: "https://example.com/here_comes_the_sun.mp3" },

  { title: "Get Lucky", artist_name: "Daft Punk", album: ram, duration_ms: 369000, deezer_id: 1007, preview_url: "https://example.com/get_lucky.mp3" },
  { title: "Instant Crush", artist_name: "Daft Punk", album: ram, duration_ms: 337000, deezer_id: 1008, preview_url: "https://example.com/instant_crush.mp3" },
  { title: "Lose Yourself to Dance", artist_name: "Daft Punk", album: ram, duration_ms: 353000, deezer_id: 1009, preview_url: "https://example.com/lose_yourself.mp3" },

  # Singles (No Album)
  { title: "Despacito", artist_name: "Luis Fonsi", album: nil, duration_ms: 228000, deezer_id: 2001, preview_url: "https://example.com/despacito.mp3" },
  { title: "Shape of You", artist_name: "Ed Sheeran", album: nil, duration_ms: 233000, deezer_id: 2002, preview_url: "https://example.com/shape_of_you.mp3" },
  { title: "Blinding Lights", artist_name: "The Weeknd", album: nil, duration_ms: 200000, deezer_id: 2003, preview_url: "https://example.com/blinding_lights.mp3" }
]

songs_data.each do |data|
  Song.find_or_create_by!(title: data[:title], artist_name: data[:artist_name]) do |s|
    s.album = data[:album]
    s.duration_ms = data[:duration_ms]
    s.deezer_id = data[:deezer_id]
    s.preview_url = data[:preview_url]
  end
end

puts "Created Songs: #{Song.count}"
puts "Seeding complete!"
