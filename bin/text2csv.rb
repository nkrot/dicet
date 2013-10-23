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
  @right_now ||= Time.now.utc
end

def updated_at
  created_at
end

######################################################################

def upcase_utf8(str)
  ActiveSupport::Multibyte::Chars.new(str).upcase.to_s
end

######################################################################

def short_token_data(token_id, word, upcased_word, tag)
  [token_id,
   word, upcased_word, 
   tag == "NOTAG", # unknown
   nil, nil, nil,  # corpus_freq number_docs cfnd
   nil, nil, nil,  # upcased_corpus_freq upcased_number_docs upcased_cfnd
   nil,            # task_id,
   created_at, updated_at]
end

######################################################################

options = { col_sep: "\t", write_headers: false }

tokens_columns =          { headers: %w[ id text upcased_text
                                            unknown
                                            corpus_freq number_docs cfnd
                                            upcased_corpus_freq upcased_number_docs upcased_cfnd
                                            task_id created_at updated_at ] }
documents_columns =       { headers: %w[ id title                         created_at updated_at ] }
sentences_columns =       { headers: %w[ id document_id                   created_at updated_at ] }
sentence_tokens_columns = { headers: %w[ id sentence_id token_id position created_at updated_at ] }
#statistics_columns =      { headers: %w[ id token_id
#                                            corpus_freq number_docs cfnd
#                                            upcased_corpus_freq upcased_number_docs upcased_cfnd ] }


tmp_tokens      = CSV.open("tmp_tokens.csv",      "wb", options.merge(tokens_columns))
tokens          = CSV.open("tokens.csv",          "wb", options.merge(tokens_columns))
documents       = CSV.open("documents.csv",       "wb", options.merge(documents_columns))
sentences       = CSV.open("sentences.csv",       "wb", options.merge(sentences_columns))
sentence_tokens = CSV.open("sentence_tokens.csv", "wb", options.merge(sentence_tokens_columns))
#@statistics     = CSV.open("statistics.csv",      "wb", options.merge(statistics_columns))

document_id = 0
token_id = 0
sentence_id = 0
sentence_token_id = 0

# all words that were seen are stored here
# token_ids [word] = token_id
@token_ids = Hash.new
# map of upcased token to all its original case variants
# [WATER] = [id_of("water"), id_of("Water"), ...]
@upcased_token_ids = Hash.new {|h,k| h[k] = []} 
@token_id2uc_word = [] # [id_of(word)] = UPCASEDWORD

######################################################################
# Methods to serve generation of Statistics table
#
# for Statistics table we need
# statistics_id - can use token_id instead
# token_id      -
# corpus_freq   - number of all occurrences in all documents
# number_docs   - number of documents the terms occurs in
# cfnd          - this is just corpus_freq * number_docs
# upcased_corpus_freq - number of all occurrences in all documents
# upcased_number_docs - number of documents the terms occurs in
# upcased_cfnd        - this is just upcased_corpus_freq * upcased_number_docs
#

# aux structures to hold data for the table Statistics
@corpus_freqs = []
@number_docs  = []

# IDs of tokens seen in the current document
@doc_token_ids = []

def gather_statistics token_id
  # keep track of all tokens seen in the document
  @doc_token_ids << token_id

  unless @corpus_freqs[token_id]
    @corpus_freqs [token_id] = 0
    @number_docs  [token_id] = 0
  end

  @corpus_freqs [token_id] += 1
end

def set_number_docs
  @doc_token_ids.uniq.each do |token_id|
    @number_docs[token_id] += 1
  end
  @doc_token_ids.clear
end

def write_statistics
  @corpus_freqs.each_with_index do |cf, token_id|
    next  if token_id == 0

    cf = @corpus_freqs [token_id]
    nd = @number_docs  [token_id]

    uc_token_ids = all_case_variants(token_id)
    uc_cf = sum_stats(uc_token_ids, @corpus_freqs)
    uc_nd = sum_stats(uc_token_ids, @number_docs)

    @statistics << [ token_id, token_id, cf, nd, cf*nd, uc_cf, uc_nd, uc_cf*uc_nd ]
  end
end

def add_statistics(fields)
#  puts "BEFORE: #{fields.inspect}"
  token_id = fields.first.to_i

  # stats on original token
  cf = @corpus_freqs [token_id]
  nd = @number_docs  [token_id]
  cfnd = cf*nd

  # stats on uppercased token
  uc_token_ids = all_case_variants(token_id)
  uc_cf = sum_stats(uc_token_ids, @corpus_freqs)
  uc_nd = sum_stats(uc_token_ids, @number_docs)
  uc_cfnd = uc_cf * uc_nd

  fields[4] = cf      # corpus_freq
  fields[5] = nd      # number_docs
  fields[6] = cfnd    # cfnd
  fields[7] = uc_cf   # upcased_corpus_freq
  fields[8] = uc_nd   # upcased_number_docs
  fields[9] = uc_cfnd # upcased_cfnd

#  puts "AFTER: #{fields.inspect}"

  fields
end

# token_id -> [token_ids of all case variants]
def all_case_variants token_id
  @upcased_token_ids[@token_id2uc_word[token_id]]
end

def sum_stats(token_ids, stats)
  stats.values_at(*token_ids).inject(:+) || 0
end

######################################################################

# TODO: use :headers to add column names in the first string
while line = gets
  line.chomp!

  if line.empty?
    next
  end

  # TABLE: Documents
  if line =~ /DOC-SEPARATOR/
    document_id += 1
    $stderr.print "Adding document ##{document_id}   \r"
    document_title = File.basename($FILENAME) + "::" + document_id.to_s
    documents << [document_id, document_title, created_at, updated_at]

    set_number_docs
    next
  end

  # TABLE: Sentences
  sentence_id += 1
  sentences << [sentence_id, document_id, created_at, updated_at]

  words = line.split
  words.each_with_index do |tw, pos|
    # get word and tag
    undrscr = tw.rindex('_') 
    word = tw[0, undrscr]
    tag  = tw[undrscr+1..-1]

    if @token_ids.key?(word)
      token_id = @token_ids[word]
    else
      # TABLE: Tokens
      token_id = @token_ids.length+1

      @token_ids [word] = token_id

      upcased_word = upcase_utf8(word)
      tmp_tokens << short_token_data(token_id, word, upcased_word, tag)

      @token_id2uc_word [token_id] = upcased_word

      unless @upcased_token_ids[upcased_word].include?(token_id)
        @upcased_token_ids[upcased_word] << token_id
      end
    end

    # TABLE: Sentence_Tokens
    sentence_token_id += 1
    sentence_tokens << [sentence_token_id, sentence_id, token_id, pos, created_at, updated_at]

    # TABLE: Statistics
    gather_statistics(token_id)
  end
end

# finish up processing the most recent document
set_number_docs

#write_statistics

tmp_tokens.close  # temporary file
documents.close
sentences.close
sentence_tokens.close
#@statistics.close

# add statistics to each token
CSV.foreach("tmp_tokens.csv", options) do |fields|
  tokens << add_statistics(fields)
end

tokens.close

$stderr.puts "\n"

