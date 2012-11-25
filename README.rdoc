# elasticsearch demo app
elasticsearchのデモ用のプロジェクトです。
題材としてlivedoorグルメ(ロケタッチグルメ)の公開データセット利用します。
これらを検索可能にしていく中で基本的なelasticsearchの使い方を習得することが目的です。

## setup

### elasticsearch
```brew install elasticsearch``` or
download latest elasticsearch http://www.elasticsearch.org/download/
unzip and ```bin/elasticsearch -f```

### rails app
```shell
bundle install
bundle exec rails s
```

### livedoor gourmet
```shell
cd ld_gourmet_search
mkdir data
cd data
open http://blog.livedoor.jp/techblog/archives/65836960.html
#!!!READ terms of use!!!
wget ldgourmet.tar.gz # find full path from article.
tar xzvf ldgourmet.tar.gz
```

## indexing

### elasticsearch config
```shell
cd elasticsearch
touch config/synonym.txt

# cat script/livedoor_gourmet_setting.json
curl -XPUT 'localhost:9200/livedoor_gourmet/' -d'                           
{ 
  "index":{       
    "number_of_shards":2,
    "number_of_replicas":1,                               
    "analysis":{
      "filter":{
        "synonym" : {
          "type" : "synonym",
          "synonyms_path" : "synonym.txt"
        }
      },
      "tokenizer" : {
        "kuromoji" : {
          "type":"kuromoji_tokenizer",
          "mode":"search"
        }
      },
      "analyzer" : {
        "default" : {
          "type" : "custom",
          "tokenizer" : "kuromoji_tokenizer",
          "filter" : ["synonym"]
        }
      }
    }
  }
}
'

# cat script/livedoor_gourmet_mapping.json

curl -XPUT 'http://localhost:9200/livedoor_gourmet/restaurant/_mapping' -d '
{                                                   
  "restaurant" : {
    "properties" : {
      "location" : {"type" : "geo_point", "store" : "yes"}
    }
  }
}
'

### indexing via Tire gem
# 20 minutes
bundle exec rails runner script/import_restaurant.rb
bundle exec rails runner script/import_rating.rb
```

## enjoy

