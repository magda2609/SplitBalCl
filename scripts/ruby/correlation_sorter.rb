require 'mongo'

def correlation_with_positive(negative_entry, positive_array)
  positive_array.map do |positive_entry|
    normalized_positive = normalize(positive_entry.values[1..-2])
    normalized_negative = normalize(negative_entry.values[1..-2])

    pearson(normalized_negative, normalized_positive)
  end.inject(&:+)
end

def normalize(array)
  # (x - min(x)) / (max(x) - min(x))
  max = array.max
  min = array.min
  array.map { |el| (el - min) / (max - min) }
end

def pearson(x, y)
  n = x.length
  sum_x = x.inject(&:+)
  sum_y = y.inject(&:+)

  sumx_sq = x.inject(0) { |r, i| r + i**2 }
  sumy_sq = y.inject(0) { |r, i| r + i**2 }

  prods = []
  x.each_with_index { |this_x, i| prods << this_x * y[i] }
  p_sum = prods.inject(&:+)

  # Calculate Pearson score
  num = p_sum - (sum_x * sum_y / n)
  den = ((sumx_sq - (sum_x**2) / n) * (sumy_sq - (sum_y**2) / n))**0.5
  return 0 if den.zero?

  num / den
end

db_name = ARGV[0]
db_collection = ARGV[1]

client = Mongo::Client.new(['127.0.0.1:27017'], database: db_name)
collection_train = client["#{db_collection}_train".to_sym]

collection_train_negative = collection_train.find(Class: 'negative').to_a
collection_train_positive = collection_train.find(Class: 'positive').to_a

collection_train_new_negative = collection_train_negative.sort_by do |element|
  correlation_with_positive(element, collection_train_positive)
end

new_collection = collection_train_new_negative + collection_train_positive

new_collection_name = "#{db_collection}_correlation_train".to_sym

client[new_collection_name].drop if client[new_collection_name].count > 0

client[new_collection_name].create
client[new_collection_name].insert_many(new_collection)

# client["#{db_collection}_test".to_sym].copy_to("#{db_collection}_correlation_test")
client.close
