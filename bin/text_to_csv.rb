#!/usr/bin/ruby

# # #
# 
#

require 'csv'
require 'active_support'
require 'optparse'

Encoding::default_internal = "UTF-8"
Encoding::default_external = "UTF-8"

OptionParser.new do |opts|
  opts.banner = "Hello. no help yet"
end.parse!

######################################################################

# TODO: probably need timestamp in rfc822, as produced by rails:
# Time.now.to_s(:rfc822)
def created_at
  Time.now.utc
end

def updated_at
  created_at
end

######################################################################

def upcase_utf8(str)
  ActiveSupport::Multibyte::Chars.new(str).upcase 
end

######################################################################

options = { col_sep: "\t", write_headers: false }

tokens_columns =          { headers: %w[ id text upcased_text             created_at updated_at ] }
documents_columns =       { headers: %w[ id title                         created_at updated_at ] }
sentences_columns =       { headers: %w[ id document_id                   created_at updated_at ] }
sentence_tokens_columns = { headers: %w[ id sentence_id token_id position created_at updated_at ] }

tokens          = CSV.open("tokens.csv",          "wb", options.merge(tokens_columns))
documents       = CSV.open("documents.csv",       "wb", options.merge(documents_columns))
sentences       = CSV.open("sentences.csv",       "wb", options.merge(sentences_columns))
sentence_tokens = CSV.open("sentence_tokens.csv", "wb", options.merge(sentence_tokens_columns))

document_id = 0
token_id = 0
sentence_id = 0
sentence_token_id = 0

# all words that were seen are stored here
# token_ids [word] = token_id
token_ids = Hash.new

# TODO: use :headers to add column names in the first string
while line = gets
  line.chomp!

  if line.empty?
    next
  end

  # TABLE: Documents
  if line =~ /DOC-SEPARATOR/
    document_id += 1
    document_title = File.basename($FILENAME) + "::" + document_id.to_s
    documents << [document_id, document_title, created_at, updated_at]
    next
  end

  # TABLE: Sentences
  sentence_id += 1
  sentences << [sentence_id, document_id, created_at, updated_at]

  words = line.split
  words.each_with_index do |word, pos|
    if token_ids.key?(word)
      token_id = token_ids[word]
    else
      # TABLE: Tokens
      token_id = token_ids.length+1
      token_ids[word] = token_id
      tokens << [token_id, word, upcase_utf8(word), created_at, updated_at]
    end

    # TABLE: Sentence_Tokens
    sentence_token_id += 1
    sentence_tokens << [sentence_token_id, sentence_id, token_id, pos, created_at, updated_at]
  end
end


tokens.close
documents.close
sentences.close
sentence_tokens.close

