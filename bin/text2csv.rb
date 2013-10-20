#!/usr/bin/env ruby

# # #
# 
#

require 'csv'
require 'active_support'
require 'optparse'

Encoding::default_internal = "UTF-8"
Encoding::default_external = "UTF-8"

OptionParser.new do |opts|
  opts.banner = "
  This script generates CSV files for importing into corresponding tables.
The following files will be generated (the file names are hardcoded):
  documents.csv, sentences.csv, tokens.csv, sentence_tokens.csv
Input data is expected to be in UTF-8 encoding.
This script should be run for all necessary files at once in order to correctly
compute primary keys for the table data.
USAGE: #{File.basename($0)} [OPTIONS] text_file(s)
OPTIONS:"

  opts.on('-h', '--help', 'display this message and exit') do
    puts opts
    exit 0
  end

  opts.separator "Details:"
  opts.separator "==DOC-SEPARATOR== markers are used to determine the boundaries of individual"
  opts.separator "subdocuments in the file. Subdocuments will be named according to the following"
  opts.separator "scheme text_file_name::NUMBER where NUMBER is computed by counting the current"
  opts.separator "occurrence of DOC-SEPARATOR."

  opts.separator " "
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

